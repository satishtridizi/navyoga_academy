class ClassWiseStatModel {
  final String className;
  final int minutes;
  final int attended;
  final int totalClasses;
  final double progress;

  ClassWiseStatModel({
    required this.className,
    required this.minutes,
    required this.attended,
    required this.totalClasses,
    required this.progress,
  });

  factory ClassWiseStatModel.fromJson(Map<String, dynamic> json) {
    return ClassWiseStatModel(
      className: json["className"],
      minutes: json["minutes"],
      attended: json["attended"],
      totalClasses: json["totalClasses"],
      progress: (json["progress"] as num).toDouble(),
    );
  }
}
