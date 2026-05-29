class LiveEnrollmentModel {
  final String id;
  final String courseId;
  final String planName;
  final String status;

  final String title;
  final String yogaType;
  final String level;

  LiveEnrollmentModel({
    required this.id,
    required this.courseId,
    required this.planName,
    required this.status,
    required this.title,
    required this.yogaType,
    required this.level,
  });

  factory LiveEnrollmentModel.fromJson(Map<String, dynamic> json) {
    return LiveEnrollmentModel(
      id: json["id"] ?? "",
      courseId: json["courseId"] ?? "",
      planName: json["planName"] ?? "",
      status: json["status"] ?? "",
      title: json["course"]?["title"] ?? "",
      yogaType: json["course"]?["yogaType"] ?? "",
      level: json["course"]?["level"] ?? "",
    );
  }
}
