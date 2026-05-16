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
      id: json["_id"] ?? json["id"] ?? "",
      title: json["title"] ?? "",
      trainer: json["trainer"] ?? json["instructor"] ?? "",

      rating: "${json["rating"] ?? 0}", // ✅ convert safely
      level: json["level"] ?? "",

      duration: (json["duration"] ?? 0).toString(),

      students: "${json["students"] ?? 0}", // ✅ FIX

      progress: (json["progress"] ?? 0).toDouble(),

      schedule: json["schedule"] ?? "",
      next: json["next"] ?? "",

      // ✅ SAFE COLOR (important)
      color: Colors.deepPurple,
    );
  }
}
