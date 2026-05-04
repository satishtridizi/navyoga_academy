import 'package:flutter/material.dart';

class CourseModel {
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
}
