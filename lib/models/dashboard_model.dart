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
      enrolledClasses: json["cards"]?["students"]?["total"] ?? 0,
      practiceHours: json["cards"]?["classes"]?["total"] ?? 0,
      recordingsWatched: json["cards"]?["tutors"]?["total"] ?? 0,
      attendanceRate: json["performance"]?["attendance"] ?? 0,
    );
  }
}
