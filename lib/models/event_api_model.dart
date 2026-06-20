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
  final bool featured;
  final int occupancy;
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
    required this.featured,
    required this.occupancy,
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
      price: double.tryParse(json["price"]?.toString() ?? "0") ?? 0,
      isEnrolled: json["isEnrolled"] ?? false,
      featured: json["featured"] ?? false,
      occupancy: json["occupancy"] ?? 0,
    );
  }
}
