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

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      enrolledClasses: json["enrolledClasses"] ?? 0,

      practiceHours: json["practiceHours"] ?? 0,

      recordingsWatched: json["recordingsWatched"] ?? 0,

      attendanceRate: json["attendanceRate"] ?? 0,
    );
  }
}
