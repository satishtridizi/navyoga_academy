import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/auth_manager.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final currentController = TextEditingController();
  final newController = TextEditingController();

  bool loading = false;

  Future<void> changePassword() async {
    final token = await AuthManager.getToken();

    if (token == null) return;

    setState(() {
      loading = true;
    });

    final res = await AuthService().changePassword(
      token: token,
      currentPassword: currentController.text.trim(),
      newPassword: newController.text.trim(),
    );

    setState(() {
      loading = false;
    });

    if (res["success"] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password updated successfully")),
      );

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res["message"] ?? "Failed to update password")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Change Password")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: currentController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Current Password"),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: newController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "New Password"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: loading ? null : changePassword,
              child: loading
                  ? const CircularProgressIndicator()
                  : const Text("Update Password"),
            ),
          ],
        ),
      ),
    );
  }
}
