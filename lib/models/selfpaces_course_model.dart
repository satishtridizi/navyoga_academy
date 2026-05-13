import 'package:flutter/material.dart';

class CourseModel {
  final String id; // ✅ ADD HERE
  final String title;
  final String description;
  final String instructor;
  final String duration;
  final String level;
  final String rating;
  final String image;

  final bool enrolled;
  final bool completed;

  final double? progress;
  final String? lessonsText;

  final bool showProgress;
  final bool showEnrollButton;

  final String actionText;

  const CourseModel({
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
    required this.lessonsText,

    required this.showProgress,
    required this.showEnrollButton,

    required this.actionText,
  });
  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json["id"] ?? "",
      title: json["title"] ?? "",
      description: json["description"] ?? "",
      instructor: json["instructor"] ?? "",
      duration: json["duration"] ?? "",
      image: json["image"] ?? "",
      level: json["level"] ?? "",

      // ✅ FIX: rating must be String
      rating: "${json["rating"] ?? 0}",

      // ✅ required fields
      enrolled: json["enrolled"] ?? false,
      completed: json["completed"] ?? false,

      // ✅ optional fields
      progress: (json["progress"] ?? 0).toDouble(),
      lessonsText: json["lessonsText"] ?? "",

      // ✅ UI logic fallback (important)
      showProgress: json["progress"] != null,
      showEnrollButton: !(json["enrolled"] ?? false),

      // ✅ CTA text logic
      actionText: json["completed"] == true
          ? "Review Course"
          : (json["enrolled"] == true ? "Continue Learning" : "Enroll Now"),
    );
  }
}
