import 'package:navyoga_academy/api/api_constants.dart';

class CourseModel {
  final String id;
  final String title;
  final String description;
  final String instructor;
  final String duration;
  final String level;
  final double rating;
  final String image;
  final bool enrolled;
  final bool completed;
  final double progress;
  final String category;

  final String? lessonsText;
  CourseModel({
    required this.id,
    required this.title,
    required this.description,
    required this.instructor,
    required this.duration,
    required this.level,
    required this.rating,
    required this.image,
    required this.enrolled,
    required this.completed,
    required this.progress,
    this.lessonsText,
    required this.category,
  });
  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json["_id"] ?? json["id"] ?? "",
      title: json["title"] ?? "",
      description: json["description"] ?? "",

      image: (json["thumbnail"] != null && json["thumbnail"] != "")
          ? "${ApiConstants.baseUrl}${json["thumbnail"]}"
          : "https://images.unsplash.com/photo-1544367567-0f2fcb009e0b",

      instructor: json["instructor"] ?? "NavYoga",
      duration: json["duration"] ?? "Self-paced",
      level: json["level"] ?? "All Levels",


      rating:
          double.tryParse(
            json["rating"]?.toString().replaceAll(RegExp(r'[^0-9.]'), '') ??
                "4.5",
          ) ??
          4.5,

      enrolled: json["enrolled"] ?? false,
      completed: json["completed"] ?? false,
      progress: (json["progress"] ?? 0).toDouble(),

      lessonsText: json["lessonsText"],
      category: json["category"] ?? "All",
    );
  }
}
