import 'package:flutter/material.dart';

class AttendanceStatModel {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const AttendanceStatModel({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });
}
