class LiveEnrollmentModel {
  final String id;
  final String courseId;
  final String planName;
  final String status;
  final String meetingUrl;
  final String title;
  final String yogaType;
  final String level;
  final String trainer;
  final int duration;

  LiveEnrollmentModel({
    required this.id,
    required this.courseId,
    required this.planName,
    required this.status,
    required this.meetingUrl,
    required this.title,
    required this.yogaType,
    required this.level,
    required this.trainer,
    required this.duration,
  });

  factory LiveEnrollmentModel.fromJson(Map<String, dynamic> json) {
    return LiveEnrollmentModel(
      id: json["id"] ?? "",
      courseId: json["courseId"] ?? "",
      planName: json["planName"] ?? "",
      status: json["status"] ?? "",
      meetingUrl: json["meetingUrl"] ?? "",
      title: json["course"]?["title"] ?? "",
      yogaType: json["course"]?["yogaType"] ?? "",
      level: json["course"]?["level"] ?? "",
      trainer: json["course"]?["trainer"] ?? "",
      duration: json["course"]?["duration"] ?? 0,
    );
  }
}
