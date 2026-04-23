import 'package:flutter/material.dart';

class InsightModel {
  final String title;
  final String value;
  final String unit;
  final String subtitle;
  final String extra;
  final IconData icon;
  final Color color;
  final String type;
  final double? progress;

  const InsightModel({
    required this.title,
    required this.value,
    required this.unit,
    required this.subtitle,
    required this.extra,
    required this.icon,
    required this.color,
    required this.type,
    this.progress,
  });
}
