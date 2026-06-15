class MonthlyStatModel {
  final String month;
  final int minutes;
  final int attended;
  final int totalClasses;
  final double progress;

  MonthlyStatModel({
    required this.month,
    required this.minutes,
    required this.attended,
    required this.totalClasses,
    required this.progress,
  });

  factory MonthlyStatModel.fromJson(Map<String, dynamic> json) {
    return MonthlyStatModel(
      month: json["month"],
      minutes: json["minutes"],
      attended: json["attended"],
      totalClasses: json["totalClasses"],
      progress: (json["progress"] as num).toDouble(),
    );
  }
}
