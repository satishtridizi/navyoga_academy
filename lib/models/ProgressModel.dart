class ProgressModel {
  final String classId;
  final int progress;
  final bool isCompleted;

  ProgressModel({
    required this.classId,
    required this.progress,
    required this.isCompleted,
  });

  factory ProgressModel.fromJson(Map<String, dynamic> json) {
    return ProgressModel(
      classId: json["classId"] ?? "",
      progress: json["progress"] ?? 0,
      isCompleted: json["isCompleted"] ?? false,
    );
  }
}
