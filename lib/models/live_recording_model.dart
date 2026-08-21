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
    this.durationSeconds = 0,
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
  final int durationSeconds;
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
        : (recordingMap['videoUrl'] ??
                recordingMap['video_url'] ??
                recordingMap['url'] ??
                recordingMap['path'] ??
                recordingMap['recordingUrl'])
            ?.toString() ??
            (json['recordingUrl'] ??
                    json['recording_url'] ??
                    json['videoUrl'] ??
                    json['video_url'])
                ?.toString() ??
            '';

    return LiveRecording(
      id: (json['id'] ?? json['_id'])?.toString() ?? '',
      title: (json['title'] ?? json['className'])?.toString() ??
          'Recorded Live Class',
      yogaType: (json['yogaType'] ?? json['yoga_type'])?.toString() ?? 'Yoga',
      difficulty: (json['difficulty'] ?? json['level'])?.toString() ?? '',
      // Do not use the scheduled class duration here. A 60-minute class can
      // produce a much shorter recording. Only accept recording-specific
      // duration metadata when the backend supplies it.
      duration: _recordingDurationMinutes(json, recordingMap),
      durationSeconds: _recordingDurationSeconds(json, recordingMap),
      tutorName: (tutor['name'] ?? json['tutorName'] ?? json['trainerName'])
              ?.toString() ??
          'NavYoga Trainer',
      videoUrl: ApiConstants.buildLiveMediaUrl(recordingPath),
      description: json['description']?.toString(),
      scheduledAt: DateTime.tryParse(
        (json['scheduledAt'] ?? json['scheduled_at'] ?? json['classDate'])
                ?.toString() ??
            '',
      )?.toLocal(),
    );
  }
}

int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

int _recordingDurationMinutes(
  Map<String, dynamic> json,
  Map<String, dynamic> recording,
) {
  final minutes = _asInt(
    recording['durationMinutes'] ??
        recording['duration_minutes'] ??
        json['recordingDurationMinutes'] ??
        json['recording_duration_minutes'],
  );
  if (minutes > 0) return minutes;

  final seconds = _recordingDurationSeconds(json, recording);
  return seconds > 0 ? (seconds / 60).ceil() : 0;
}

int _recordingDurationSeconds(
  Map<String, dynamic> json,
  Map<String, dynamic> recording,
) {
  final seconds = _asInt(
    recording['durationSeconds'] ??
        recording['duration_seconds'] ??
        json['recordingDurationSeconds'] ??
        json['recording_duration_seconds'],
  );
  if (seconds > 0) return seconds;

  final minutes = _asInt(
    recording['durationMinutes'] ??
        recording['duration_minutes'] ??
        json['recordingDurationMinutes'] ??
        json['recording_duration_minutes'],
  );
  return minutes > 0 ? minutes * 60 : 0;
}
