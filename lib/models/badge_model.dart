import 'package:flutter/material.dart';

class BadgeModel {
  final String title;
  final String subtitle;
  final String progressText;
  final String reward;
  final IconData icon;
  final Color color;
  final bool isCompleted;
  final int percent;

  const BadgeModel({
    required this.title,
    required this.subtitle,
    required this.progressText,
    required this.reward,
    required this.icon,
    required this.color,
    required this.isCompleted,
    required this.percent,
  });
}
