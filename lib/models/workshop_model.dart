class WorkshopModel {
  final String id;
  final String title;
  final String description;
  final String thumbnail;
  final String yogaType;
  final String level;
  final String mode;
  final String instructorName;
  final double price;
  final bool isEnrolled;

  WorkshopModel({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnail,
    required this.yogaType,
    required this.level,
    required this.mode,
    required this.instructorName,
    required this.price,
    required this.isEnrolled,
  });

  factory WorkshopModel.fromJson(Map<String, dynamic> json) {
    return WorkshopModel(
      id: json["id"] ?? "",
      title: json["title"] ?? "",
      description: json["description"] ?? "",
      thumbnail: json["thumbnail"] ?? "",
      yogaType: json["yogaType"] ?? "",
      level: json["level"] ?? "",
      mode: json["mode"] ?? "",
      instructorName: json["instructorName"] ?? "",
      price: double.tryParse(json["price"].toString()) ?? 0,
      isEnrolled: json["isEnrolled"] ?? false,
    );
  }
}
