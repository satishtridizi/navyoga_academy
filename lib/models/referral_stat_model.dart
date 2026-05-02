import 'package:flutter/material.dart';

class ReferralStatModel {
  final String title;
  final String value;
  final IconData icon;
  final Color borderColor;
  final Color iconBg;
  final Color iconColor;
  final String? route;

  const ReferralStatModel({
    required this.title,
    required this.value,
    required this.icon,
    required this.borderColor,
    required this.iconBg,
    required this.iconColor,
    this.route,
  });
}
