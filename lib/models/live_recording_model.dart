import '../api/api_constants.dart';

class LiveRecordingAccess {
  const LiveRecordingAccess({
    required this.enrolled,
    required this.recordingDays,
    required this.planName,
    required this.recordings,
  });

  final bool enrolled;
  final int recordingDays;
  final String planName;
  final List<LiveRecording> recordings;
}

class LiveRecording {
  const LiveRecording({
    required this.id,
    required this.title,
    required this.yogaType,
    required this.difficulty,
    required this.duration,
    required this.tutorName,
    required this.videoUrl,
    this.description,
    this.scheduledAt,
  });

  final String id;
  final String title;
  final String yogaType;
  final String difficulty;
  final int duration;
  final String tutorName;
  final String videoUrl;
  final String? description;
  final DateTime? scheduledAt;

  factory LiveRecording.fromJson(Map<String, dynamic> json) {
    final tutor = Map<String, dynamic>.from(json['tutor'] as Map? ?? {});
    final rawRecording = json['recording'];
    final recordingMap = rawRecording is Map
        ? Map<String, dynamic>.from(rawRecording)
        : const <String, dynamic>{};
    final recordingPath = rawRecording is String
        ? rawRecording
        : (recordingMap['url'] ??
                recordingMap['path'] ??
                recordingMap['recordingUrl'])
            ?.toString() ??
            '';

    return LiveRecording(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Recorded Live Class',
      yogaType: json['yogaType']?.toString() ?? 'Yoga',
      difficulty: json['difficulty']?.toString() ?? '',
      duration: _asInt(json['duration']),
      tutorName: tutor['name']?.toString() ?? 'NavYoga Trainer',
      videoUrl: ApiConstants.buildLiveMediaUrl(recordingPath),
      description: json['description']?.toString(),
      scheduledAt: DateTime.tryParse(json['scheduledAt']?.toString() ?? '')
          ?.toLocal(),
    );
  }
}

int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
