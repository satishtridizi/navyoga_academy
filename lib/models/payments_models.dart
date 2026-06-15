import 'package:flutter/material.dart';

class Subscription {
  final String planName;
  final String activeSince;
  final String price;
  final String nextBilling;
  final String billingCycle;
  final bool isActive;
  final List<String> features;

  Subscription({
    required this.planName,
    required this.activeSince,
    required this.price,
    required this.nextBilling,
    required this.billingCycle,
    required this.isActive,
    required this.features,
  });
}

class Plan {
  final String id;
  final String name;
  final String price;
  final String yearly;
  final Color color;
  final bool isPopular;
  final bool isCurrent;
  final IconData icon;
  final List<String> features;

  Plan({
    required this.id,
    required this.name,
    required this.price,
    required this.yearly,
    required this.color,
    this.isPopular = false,
    this.isCurrent = false,
    required this.icon,
    required this.features,
  });
}

class PaymentMethod {
  final String brand;
  final String number;
  final String expiry;
  final bool isDefault;

  PaymentMethod({
    required this.brand,
    required this.number,
    required this.expiry,
    this.isDefault = false,
  });
}

class PaymentHistory {
  final String title;
  final String date;
  final String amount;

  PaymentHistory({
    required this.title,
    required this.date,
    required this.amount,
  });
}
