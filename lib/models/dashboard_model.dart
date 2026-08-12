class DashboardModel {
  final DashboardMetrics metrics;
  final List<UpcomingClassModel> upcomingClasses;
  final List<DashboardAchievementModel> achievements;
  final ReferralStatsModel referralStats;

  const DashboardModel({
    required this.metrics,
    required this.upcomingClasses,
    required this.achievements,
    required this.referralStats,
  });

  DashboardModel copyWith({
    DashboardMetrics? metrics,
    List<UpcomingClassModel>? upcomingClasses,
    List<DashboardAchievementModel>? achievements,
    ReferralStatsModel? referralStats,
  }) {
    return DashboardModel(
      metrics: metrics ?? this.metrics,
      upcomingClasses: upcomingClasses ?? this.upcomingClasses,
      achievements: achievements ?? this.achievements,
      referralStats: referralStats ?? this.referralStats,
    );
  }

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    final rawUpcomingClasses = json['upcomingClasses'] ??
        json['upcoming_classes'] ??
        json['upcoming'] ??
        json['classes'] ??
        json['liveClasses'] ??
        json['myClasses'];
    final rawAchievements = json['achievements'];

    return DashboardModel(
      metrics: DashboardMetrics.fromJson(
        _asMap(json['metrics']),
      ),
      upcomingClasses: rawUpcomingClasses is List
          ? rawUpcomingClasses
              .whereType<Map>()
              .map(
                (item) => UpcomingClassModel.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList()
          : const [],
      achievements: rawAchievements is List
          ? rawAchievements
              .whereType<Map>()
              .map(
                (item) => DashboardAchievementModel.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList()
          : const [],
      referralStats: ReferralStatsModel.fromJson(
        _asMap(json['referralStats']),
      ),
    );
  }

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return <String, dynamic>{};
  }
}

class DashboardMetrics {
  final int enrolledClasses;
  final int enrolledChangeMonth;
  final num hoursCompleted;
  final num hoursChangeWeek;
  final int recordingsWatched;
  final int recordingsChangeWeek;
  final num attendanceRate;
  final num attendanceImprovement;

  const DashboardMetrics({
    required this.enrolledClasses,
    required this.enrolledChangeMonth,
    required this.hoursCompleted,
    required this.hoursChangeWeek,
    required this.recordingsWatched,
    required this.recordingsChangeWeek,
    required this.attendanceRate,
    required this.attendanceImprovement,
  });

  factory DashboardMetrics.fromJson(Map<String, dynamic> json) {
    return DashboardMetrics(
      enrolledClasses: _toInt(json['enrolledClasses']),
      enrolledChangeMonth: _toInt(json['enrolledChangeMonth']),
      hoursCompleted: _toNum(json['hoursCompleted']),
      hoursChangeWeek: _toNum(json['hoursChangeWeek']),
      recordingsWatched: _toInt(json['recordingsWatched']),
      recordingsChangeWeek: _toInt(json['recordingsChangeWeek']),
      attendanceRate: _toNum(json['attendanceRate']),
      attendanceImprovement: _toNum(json['attendanceImprovement']),
    );
  }
}

class UpcomingClassModel {
  final String id;
  final String name;
  final String instructor;
  final int duration;
  final String status;
  final DateTime? startTime;
  final String meetingUrl;
  final Map<String, dynamic> rawData;

  const UpcomingClassModel({
    required this.id,
    required this.name,
    required this.instructor,
    required this.duration,
    required this.status,
    required this.startTime,
    required this.meetingUrl,
    required this.rawData,
  });

  factory UpcomingClassModel.fromJson(Map<String, dynamic> json) {
    return UpcomingClassModel(
      id: _toStringValue(
        json['id'] ?? json['_id'] ?? json['classId'],
      ),
      name: _toStringValue(
        json['name'] ?? json['title'] ?? json['className'],
        fallback: 'Yoga Class',
      ),
      instructor: _parseInstructor(json),
      duration: _toInt(
        json['duration'] ??
            json['durationMinutes'] ??
            json['minutes'],
      ),
      status: _toStringValue(json['status']),
      startTime: _toDateTime(
        json['startTime'] ??
            json['scheduledAt'] ??
            json['dateTime'],
      ),
      meetingUrl: _toStringValue(
        json['meetingUrl'] ??
            json['joinUrl'] ??
            json['liveUrl'],
      ),
      rawData: Map<String, dynamic>.from(json),
    );
  }
}

class DashboardAchievementModel {
  final String id;
  final String title;
  final String description;
  final String icon;
  final bool unlocked;

  const DashboardAchievementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.unlocked,
  });

  factory DashboardAchievementModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return DashboardAchievementModel(
      id: _toStringValue(json['id'] ?? json['_id']),
      title: _toStringValue(
        json['title'] ?? json['name'],
      ),
      description: _toStringValue(json['description']),
      icon: _toStringValue(
        json['icon'] ?? json['image'],
      ),
      unlocked:
          json['unlocked'] == true ||
          json['isUnlocked'] == true,
    );
  }
}

class ReferralStatsModel {
  final String referralCode;
  final int totalReferrals;
  final int activeReferrals;
  final num totalEarned;
  final num availableBalance;
  final int unlockedBadges;

  const ReferralStatsModel({
    required this.referralCode,
    required this.totalReferrals,
    required this.activeReferrals,
    required this.totalEarned,
    required this.availableBalance,
    required this.unlockedBadges,
  });

  factory ReferralStatsModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ReferralStatsModel(
      referralCode: _toStringValue(
        json['referralCode'],
      ),
      totalReferrals: _toInt(
        json['totalReferrals'] ??
            json['referralsCount'],
      ),
      activeReferrals: _toInt(
        json['activeReferrals'] ??
            json['activeCount'],
      ),
      totalEarned: _toNum(
        json['totalEarned'] ??
            json['totalRewards'],
      ),
      availableBalance: _toNum(
        json['availableBalance'] ??
            json['balance'],
      ),
      unlockedBadges: _toInt(
        json['unlockedBadges'] ??
            json['achievementBadges'],
      ),
    );
  }
}

String _parseInstructor(Map<String, dynamic> json) {
  final instructor = json['instructor'];

  if (instructor is Map) {
    return _toStringValue(
      instructor['name'] ??
          instructor['fullName'] ??
          instructor['firstName'],
      fallback: 'Instructor',
    );
  }

  return _toStringValue(
    instructor ??
        json['instructorName'] ??
        json['trainerName'] ??
        json['tutorName'],
    fallback: 'Instructor',
  );
}

int _toInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();

  return int.tryParse(value?.toString() ?? '') ?? 0;
}

num _toNum(dynamic value) {
  if (value is num) return value;

  return num.tryParse(value?.toString() ?? '') ?? 0;
}

String _toStringValue(
  dynamic value, {
  String fallback = '',
}) {
  final result = value?.toString().trim() ?? '';

  return result.isEmpty ? fallback : result;
}

DateTime? _toDateTime(dynamic value) {
  if (value == null) return null;

  return DateTime.tryParse(value.toString());
}
