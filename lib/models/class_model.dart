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
  final String description;
  final String video;
  final String thumbnail;
  final int durationMinutes;
  final bool isCompleted;
  final bool isGradient;
  final bool isGradientProgress;

  const ClassModel({
    required this.id,
    required this.description,
    required this.video,
    required this.thumbnail,
    required this.durationMinutes,
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
    final thumb = json["thumbnail"]?.toString() ?? "";

    return ClassModel(
      id: json["id"] ?? "",
      title: json["title"] ?? "",
      trainer: "",
      rating: "",
      level: "",
      duration: "${json["duration"] ?? 0} min",
      students: "",
      progress: 0,
      schedule: "",
      next: "",
      color: Colors.deepPurple,

      description: json["description"] ?? "",
      video: json["video"] ?? "",

      thumbnail: thumb.startsWith("http") ? thumb : "",

      durationMinutes: json["duration"] ?? 0,
    );
  }
}
