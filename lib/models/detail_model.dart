import 'package:flutter/material.dart';

class DetailModel {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const DetailModel({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}
