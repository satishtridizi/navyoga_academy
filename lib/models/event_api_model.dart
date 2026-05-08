class EventApiModel {
  final String title;
  final String date;
  final String time;
  final String trainer;
  final String type;

  EventApiModel({
    required this.title,
    required this.date,
    required this.time,
    required this.trainer,
    required this.type,
  });

  factory EventApiModel.fromJson(Map<String, dynamic> json) {
    return EventApiModel(
      title: json["title"] ?? "",

      date: json["date"] ?? "",

      time: json["time"] ?? "",

      trainer: json["trainer"] ?? "",

      type: json["type"] ?? "",
    );
  }
}
