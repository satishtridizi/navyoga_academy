class DashboardModel {
  final int enrolledClasses;
  final int practiceHours;
  final int recordingsWatched;
  final int attendanceRate;

  DashboardModel({
    required this.enrolledClasses,
    required this.practiceHours,
    required this.recordingsWatched,
    required this.attendanceRate,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> metrics) {
    return DashboardModel(
      enrolledClasses: metrics["enrolledClasses"] ?? 0,
      practiceHours: metrics["hoursCompleted"] ?? 0,
      recordingsWatched: metrics["recordingsWatched"] ?? 0,
      attendanceRate: metrics["attendanceRate"] ?? 0,
    );
  }
}
