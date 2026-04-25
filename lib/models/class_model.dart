import 'package:flutter/material.dart';

class ClassModel {
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
}
