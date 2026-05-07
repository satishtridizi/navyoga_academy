class AttendanceApiModel {
  final int attendanceRate;
  final int classesAttended;
  final int missedClasses;
  final int streak;

  AttendanceApiModel({
    required this.attendanceRate,
    required this.classesAttended,
    required this.missedClasses,
    required this.streak,
  });

  factory AttendanceApiModel.fromJson(Map<String, dynamic> json) {
    return AttendanceApiModel(
      attendanceRate: json["attendanceRate"] ?? 0,

      classesAttended: json["classesAttended"] ?? 0,

      missedClasses: json["missedClasses"] ?? 0,

      streak: json["streak"] ?? 0,
    );
  }
}
