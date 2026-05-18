import 'package:flutter/material.dart';

class ClassModel {
  final String id;
  final String title;
  final String trainer;
  final String rating;
  final String level;
  final String duration;
  final String students;
  final double progress;
  final String schedule;
  final String next;
  final Color color;

  final bool isCompleted;
  final bool isGradient;
  final bool isGradientProgress;

  const ClassModel({
    required this.id,
    required this.title,
    required this.trainer,
    required this.rating,
    required this.level,
    required this.duration,
    required this.students,
    required this.progress,
    required this.schedule,
    required this.next,
    required this.color,
    this.isCompleted = false,
    this.isGradient = false,
    this.isGradientProgress = false,
  });
  factory ClassModel.fromJson(Map<String, dynamic> json) {
    return ClassModel(
      id: json["id"] ?? "",
      title: json["title"] ?? "",

      // ✅ FIXED MAPPING
      trainer: json["yogaType"] ?? "Yoga Instructor",

      rating: "0",
      level: json["level"] ?? "",

      duration: "60", // fallback (API not giving)
      students: "0",

      progress: 0.0,

      schedule: json["createdAt"] ?? "",
      next: "",

      color: Colors.deepPurple,
    );
  }
}
