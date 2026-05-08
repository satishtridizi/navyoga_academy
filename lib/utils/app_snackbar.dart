import 'package:flutter/material.dart';

class AppSnackbar {
  /// ✅ SUCCESS
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),

        backgroundColor: Colors.green,

        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// ❌ ERROR
  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),

        backgroundColor: Colors.red,

        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// ⚠️ WARNING
  static void showWarning(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),

        backgroundColor: Colors.orange,

        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
