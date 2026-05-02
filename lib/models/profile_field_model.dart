import 'package:flutter/material.dart';

class ProfileFieldModel {
  final String label;
  final String value;
  final IconData? icon;
  final bool isMultiline;
  final String? helperText;
  const ProfileFieldModel({
    required this.label,
    required this.value,
    this.icon,
    this.isMultiline = false,
    this.helperText,
  });
}
