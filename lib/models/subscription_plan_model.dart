import 'package:flutter/material.dart';

enum SubscriptionCategory {
  live,
  selfPaced,
  teacherTraining,
}

enum TeacherTrainingType {
  recorded,
  live,
}

class SubscriptionPlanModel {
  final String id;
  final String? courseId;
  final String name;
  final String description;
  final int validity;
  final double price;
  final double? originalPrice;
  final List<String> features;
  final bool isActive;
  final SubscriptionCategory category;
  final TeacherTrainingType? trainingType;

  const SubscriptionPlanModel({
    required this.id,
    required this.name,
    required this.description,
    required this.validity,
    required this.price,
    required this.features,
    required this.isActive,
    required this.category,
    this.courseId,
    this.originalPrice,
    this.trainingType,
  });

  factory SubscriptionPlanModel.fromJson(
    Map<String, dynamic> json, {
    required SubscriptionCategory category,
    TeacherTrainingType? trainingType,
  }) {
    final rawFeatures = json['features'];

    return SubscriptionPlanModel(
      id: json['id']?.toString() ?? '',
      courseId: json['courseId']?.toString(),
      name: json['name']?.toString() ?? 'Plan',
      description: json['description']?.toString() ?? '',
      validity: _toInt(json['validity']),
      price: _toDouble(json['price']),
      originalPrice: json['originalPrice'] == null
          ? null
          : _toDouble(json['originalPrice']),
      features: rawFeatures is List
          ? rawFeatures
              .map((item) => item.toString().trim())
              .where((item) => item.isNotEmpty)
              .toList()
          : const [],
      isActive: json['isActive'] != false,
      category: category,
      trainingType: trainingType,
    );
  }

  String get validityLabel {
    if (validity <= 0) return '';

    if (validity == 30) return 'for month';
    if (validity == 90) return 'for 3 months';
    if (validity == 180) return 'for 6 months';
    if (validity == 365) return 'for 12 months';

    return 'for $validity days';
  }

  String get categoryKey {
    switch (category) {
      case SubscriptionCategory.live:
        return 'live';

      case SubscriptionCategory.selfPaced:
        return 'selfPaced';

      case SubscriptionCategory.teacherTraining:
        return trainingType == TeacherTrainingType.live
            ? 'yttLive'
            : 'yttRecorded';
    }
  }

  IconData get icon {
    switch (category) {
      case SubscriptionCategory.live:
        return Icons.bolt_rounded;

      case SubscriptionCategory.selfPaced:
        return Icons.favorite_border_rounded;

      case SubscriptionCategory.teacherTraining:
        return Icons.school_outlined;
    }
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();

    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class PlatformConfigModel {
  final String centerName;
  final String email;
  final String phone;
  final String address;
  final double gstPercentage;

  const PlatformConfigModel({
    required this.centerName,
    required this.email,
    required this.phone,
    required this.address,
    required this.gstPercentage,
  });

  factory PlatformConfigModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return PlatformConfigModel(
      centerName:
          json['centerName']?.toString() ?? 'Navyoga Wellness',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      gstPercentage:
          double.tryParse(json['gstPercentage']?.toString() ?? '') ??
              0,
    );
  }
}

class ActivePlanModel {
  final String enrollmentId;
  final String planId;
  final String name;
  final String status;
  final String? batchName;
  final DateTime? startDate;
  final DateTime? endDate;
  final SubscriptionCategory category;
  final TeacherTrainingType? trainingType;

  const ActivePlanModel({
    required this.enrollmentId,
    required this.planId,
    required this.name,
    required this.status,
    required this.category,
    this.batchName,
    this.startDate,
    this.endDate,
    this.trainingType,
  });

  bool get isActive {
    final validStatus = const {
      'ACTIVE',
      'TRIAL',
      'TRIALING',
    }.contains(status.toUpperCase());

    if (!validStatus) return false;

    if (endDate != null && endDate!.isBefore(DateTime.now())) {
      return false;
    }

    return true;
  }
}