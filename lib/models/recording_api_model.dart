import 'package:flutter/material.dart';

class RecordingApiModel {
  final String title;
  final String trainer;
  final String duration;
  final String category;
  final String views;
  final String rating;
  final String date;

  RecordingApiModel({
    required this.title,
    required this.trainer,
    required this.duration,
    required this.category,
    required this.views,
    required this.rating,
    required this.date,
  });

  factory RecordingApiModel.fromJson(Map<String, dynamic> json) {
    return RecordingApiModel(
      title: json["title"] ?? "",

      trainer: json["trainer"] ?? "",

      duration: json["duration"] ?? "",

      category: json["category"] ?? "",

      views: json["views"].toString(),

      rating: json["rating"].toString(),

      date: json["date"] ?? "",
    );
  }
}
