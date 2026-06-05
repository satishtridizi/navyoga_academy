import 'package:flutter/material.dart';
import 'package:navyoga_academy/utils/auth_manager.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:navyoga_academy/routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    checkLogin();
  }

  Future<void> checkLogin() async {
    await Future.delayed(const Duration(seconds: 1));

    final token = await AuthManager.getToken();

    if (!mounted) return;

    /// ✅ TOKEN EXISTS
    if (token != null && token.isNotEmpty) {
      Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
    }
    /// ❌ NOT LOGGED IN
    else {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Image.asset("assets/images/logo.png", height: 120, width: 120),

            const SizedBox(height: 20),

            const Text(
              "NavYoga Academy",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange,
              ),
            ),

            const SizedBox(height: 30),

            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
