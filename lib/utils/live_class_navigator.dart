import 'package:flutter/material.dart';

import 'package:navyoga_academy/models/live_class_arguments.dart';
import 'package:navyoga_academy/routes/app_routes.dart';
import 'package:navyoga_academy/utils/app_snackbar.dart';

class LiveClassNavigator {
  LiveClassNavigator._();

  static Future<void> open({
    required BuildContext context,
    required String classId,
    required String studentName,
    required String title,
    required int duration,
    String? tutorName,
    String? yogaType,
    DateTime? scheduledAt,
    Map<String, dynamic> rawData =
        const <String, dynamic>{},
  }) async {
    final joinWindowStart =
        scheduledAt?.subtract(const Duration(minutes: 15));
    if (joinWindowStart != null && DateTime.now().isBefore(joinWindowStart)) {
      AppSnackbar.showError(
        context,
        'The waiting room opens 15 minutes before the class starts.',
      );
      return;
    }

    if (classId.trim().isEmpty) {
      AppSnackbar.showError(
        context,
        'Live-class ID is unavailable.',
      );

      return;
    }

    if (studentName.trim().isEmpty) {
      AppSnackbar.showError(
        context,
        'Student information is unavailable.',
      );

      return;
    }

    await Navigator.pushNamed(
      context,
      AppRoutes.liveClass,
      arguments: LiveClassArguments(
        classId: classId,
        studentName: studentName,
        title: title,
        tutorName: tutorName,
        yogaType: yogaType,
        scheduledAt: scheduledAt,
        duration: duration,
        rawData: rawData,
      ),
    );
  }
}
