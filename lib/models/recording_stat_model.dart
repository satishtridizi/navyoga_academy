import 'package:flutter/material.dart';

class RecordingStatModel {
  final String title;
  final String value;
  final Color color;
  final IconData icon;
  final String? route;

  const RecordingStatModel({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
    this.route,
  });
}
