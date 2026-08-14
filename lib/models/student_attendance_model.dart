class StudentAttendanceResponse {
  const StudentAttendanceResponse({
    required this.summary,
    required this.records,
  });

  final AttendanceSummary summary;
  final List<AttendanceRecord> records;

  factory StudentAttendanceResponse.fromJson(Map<String, dynamic> json) {
    return StudentAttendanceResponse(
      summary: AttendanceSummary.fromJson(
        Map<String, dynamic>.from(json['summary'] as Map? ?? {}),
      ),
      records: (json['records'] as List? ?? const [])
          .whereType<Map>()
          .map((item) => AttendanceRecord.fromJson(
                Map<String, dynamic>.from(item),
              ))
          .toList(),
    );
  }
}

class AttendanceSummary {
  const AttendanceSummary({
    required this.totalAttended,
    required this.attendedThisMonth,
    this.lastAttendedAt,
  });

  final int totalAttended;
  final int attendedThisMonth;
  final DateTime? lastAttendedAt;

  factory AttendanceSummary.fromJson(Map<String, dynamic> json) {
    return AttendanceSummary(
      totalAttended: _asInt(json['totalAttended']),
      attendedThisMonth: _asInt(json['attendedThisMonth']),
      lastAttendedAt: _asDate(json['lastAttendedAt']),
    );
  }
}

class AttendanceRecord {
  const AttendanceRecord({
    required this.id,
    required this.joinedAt,
    required this.liveClass,
  });

  final String id;
  final DateTime? joinedAt;
  final AttendedLiveClass liveClass;

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id']?.toString() ?? '',
      joinedAt: _asDate(json['joinedAt']),
      liveClass: AttendedLiveClass.fromJson(
        Map<String, dynamic>.from(json['liveClass'] as Map? ?? {}),
      ),
    );
  }
}

class AttendedLiveClass {
  const AttendedLiveClass({
    required this.id,
    required this.title,
    required this.yogaType,
    required this.duration,
    required this.tutorName,
    this.scheduledAt,
    this.batchName,
  });

  final String id;
  final String title;
  final String yogaType;
  final int duration;
  final String tutorName;
  final DateTime? scheduledAt;
  final String? batchName;

  factory AttendedLiveClass.fromJson(Map<String, dynamic> json) {
    final tutor = Map<String, dynamic>.from(json['tutor'] as Map? ?? {});
    final batch = Map<String, dynamic>.from(json['batch'] as Map? ?? {});
    return AttendedLiveClass(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Live Yoga Class',
      yogaType: json['yogaType']?.toString() ?? '',
      duration: _asInt(json['duration']),
      tutorName: tutor['name']?.toString() ?? 'Trainer',
      scheduledAt: _asDate(json['scheduledAt']),
      batchName: batch['name']?.toString(),
    );
  }
}

int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

DateTime? _asDate(dynamic value) {
  final raw = value?.toString();
  if (raw == null || raw.isEmpty) return null;
  return DateTime.tryParse(raw)?.toLocal();
}
