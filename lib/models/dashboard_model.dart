class DashboardModel {
  final int enrolledClasses;
  final int enrolledChangeMonth;
  final int hoursCompleted;
  final int hoursChangeWeek;
  final int recordingsWatched;
  final int recordingsChangeWeek;
  final int attendanceRate;
  final int attendanceImprovement;

  DashboardModel({
    required this.enrolledClasses,
    required this.enrolledChangeMonth,
    required this.hoursCompleted,
    required this.hoursChangeWeek,
    required this.recordingsWatched,
    required this.recordingsChangeWeek,
    required this.attendanceRate,
    required this.attendanceImprovement,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      enrolledClasses: json["enrolledClasses"] ?? 0,
      enrolledChangeMonth: json["enrolledChangeMonth"] ?? 0,
      hoursCompleted: json["hoursCompleted"] ?? 0,
      hoursChangeWeek: json["hoursChangeWeek"] ?? 0,
      recordingsWatched: json["recordingsWatched"] ?? 0,
      attendanceRate: json["attendanceRate"] ?? 0,
      attendanceImprovement: json["attendanceImprovement"] ?? 0,
      recordingsChangeWeek: json["recordingsChangeWeek"] ?? 0,
    );
  }
}
