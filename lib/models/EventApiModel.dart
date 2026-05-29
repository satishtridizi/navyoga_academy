class EventApiModel {
  final String id;
  final String title;
  final String description;
  final String thumbnail;
  final String date;
  final String duration;
  final String location;
  final int capacity;
  final double price;
  final bool isEnrolled;

  EventApiModel({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnail,
    required this.date,
    required this.duration,
    required this.location,
    required this.capacity,
    required this.price,
    required this.isEnrolled,
  });

  factory EventApiModel.fromJson(Map<String, dynamic> json) {
    return EventApiModel(
      id: json["id"] ?? "",
      title: json["title"] ?? "",
      description: json["description"] ?? "",
      thumbnail: json["thumbnail"] ?? "",
      date: json["date"] ?? "",
      duration: json["duration"] ?? "",
      location: json["location"] ?? "",
      capacity: json["capacity"] ?? 0,
      price: (json["price"] ?? 0).toDouble(),
      isEnrolled: json["isEnrolled"] ?? false,
    );
  }
}
