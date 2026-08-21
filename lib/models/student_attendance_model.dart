class StudentAttendanceResponse {
  const StudentAttendanceResponse({
    required this.summary,
    required this.records,
  });

  final AttendanceSummary summary;
  final List<AttendanceRecord> records;

  factory StudentAttendanceResponse.fromJson(Map<String, dynamic> json) {
    final records = ((json['records'] ??
                    json['attendance'] ??
                    json['classes']) as List? ??
            const [])
        .whereType<Map>()
        .map((item) => AttendanceRecord.fromJson(
              Map<String, dynamic>.from(item),
            ))
        .toList();
    final summaryJson = Map<String, dynamic>.from(
      json['summary'] as Map? ?? {},
    );
    final parsedSummary = AttendanceSummary.fromJson(summaryJson);
    final now = DateTime.now();
    final attendedThisMonth = records.where((record) {
      final date = record.joinedAt ?? record.liveClass.scheduledAt;
      return date != null && date.year == now.year && date.month == now.month;
    }).length;

    return StudentAttendanceResponse(
      summary: AttendanceSummary(
        totalAttended: parsedSummary.totalAttended > 0
            ? parsedSummary.totalAttended
            : records.length,
        attendedThisMonth: parsedSummary.attendedThisMonth > 0
            ? parsedSummary.attendedThisMonth
            : attendedThisMonth,
        lastAttendedAt: parsedSummary.lastAttendedAt,
      ),
      records: records,
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
      totalAttended: _asInt(
        json['totalAttended'] ?? json['totalClassesAttended'] ?? json['total'],
      ),
      attendedThisMonth: _asInt(
        json['attendedThisMonth'] ?? json['monthlyAttended'] ?? json['thisMonth'],
      ),
      lastAttendedAt: _asDate(
        json['lastAttendedAt'] ?? json['lastAttendanceAt'],
      ),
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
      id: (json['id'] ?? json['_id'])?.toString() ?? '',
      joinedAt: _asDate(
        json['joinedAt'] ?? json['joined_at'] ?? json['attendanceDate'],
      ),
      liveClass: AttendedLiveClass.fromJson(
        Map<String, dynamic>.from(
          (json['liveClass'] ?? json['class'] ?? json['classDetails']) as Map? ??
              {},
        ),
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
      id: (json['id'] ?? json['_id'])?.toString() ?? '',
      title: (json['title'] ?? json['className'])?.toString() ??
          'Live Yoga Class',
      yogaType: (json['yogaType'] ?? json['yoga_type'])?.toString() ?? '',
      duration: _asInt(json['durationMinutes'] ?? json['duration']),
      tutorName: (tutor['name'] ?? json['tutorName'] ?? json['trainerName'])
              ?.toString() ??
          'Trainer',
      scheduledAt: _asDate(
        json['scheduledAt'] ?? json['scheduled_at'] ?? json['classDate'],
      ),
      batchName: (batch['name'] ?? json['batchName'])?.toString(),
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
