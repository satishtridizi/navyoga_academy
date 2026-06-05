import 'package:flutter/material.dart';

class RecordingModel {
  final String title;
  final String trainer;
  final String duration;
  final String views;
  final String rating;
  final String date;
  final String category;
  final String videoUrl;

  final Color color;
  final bool isCompleted;

  const RecordingModel({
    required this.title,
    required this.trainer,
    required this.duration,
    required this.views,
    required this.rating,
    required this.date,
    required this.category,
    required this.videoUrl,
    required this.color,
    this.isCompleted = false,
  });
}
