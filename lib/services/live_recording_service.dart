import '../api/api_constants.dart';
import '../api/api_service.dart';
import '../models/live_recording_model.dart';

class LiveRecordingException implements Exception {
  const LiveRecordingException(this.message);
  final String message;

  @override
  String toString() => message;
}

class LiveRecordingService {
  final ApiService _api = ApiService();

  Future<LiveRecordingAccess> getAvailableRecordings(String token) async {
    final responses = await Future.wait([
      _api.getRequest(url: ApiConstants.myClassesUrl, token: token),
      _api.getRequest(url: ApiConstants.myEnrollmentUrl, token: token),
    ]);

    final classesResponse = _asMap(responses[0]);
    final enrollmentResponse = _asMap(responses[1]);
    if (classesResponse['success'] != true ||
        enrollmentResponse['success'] != true) {
      throw LiveRecordingException(
        classesResponse['message']?.toString() ??
            enrollmentResponse['message']?.toString() ??
            'Unable to load recordings.',
      );
    }

    final classesData = _asMap(classesResponse['data']);
    final enrollmentData = _asMap(enrollmentResponse['data']);
    final enrollment = _asMap(enrollmentData['enrollment']);
    final plan = _asMap(enrollment['plan']);
    final enrolled = enrollmentData['enrolled'] == true &&
        enrollment['status']?.toString().toUpperCase() == 'ACTIVE';
    final recordingDays = _asInt(
      classesData['recordingDays'] ?? plan['recordingAccess'],
    );
    final cutoff = DateTime.now().subtract(Duration(days: recordingDays));
    final rawClasses = classesData['classes'] as List? ?? const [];

    final recordings = rawClasses
        .whereType<Map>()
        .map((item) => LiveRecording.fromJson(
              Map<String, dynamic>.from(item),
            ))
        .where((item) => item.videoUrl.isNotEmpty)
        .where((item) => recordingDays <= 0 ||
            item.scheduledAt == null ||
            !item.scheduledAt!.isBefore(cutoff))
        .toList()
      ..sort((a, b) => (b.scheduledAt ?? DateTime(1970))
          .compareTo(a.scheduledAt ?? DateTime(1970)));

    return LiveRecordingAccess(
      enrolled: enrolled,
      recordingDays: recordingDays,
      planName: plan['name']?.toString() ?? 'Live Yoga Plan',
      recordings: enrolled ? recordings : const [],
    );
  }

  Map<String, dynamic> _asMap(dynamic value) => value is Map
      ? Map<String, dynamic>.from(value)
      : <String, dynamic>{};

  int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
