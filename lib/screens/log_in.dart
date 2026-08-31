import 'package:flutter/material.dart';
import 'package:navyoga_academy/routes/app_routes.dart';
import 'package:navyoga_academy/screens/Sign_up.dart';
import 'package:navyoga_academy/screens/dashboard.dart';
import 'package:navyoga_academy/services/auth_service.dart';
import 'package:navyoga_academy/utils/api_helper.dart';
import 'package:navyoga_academy/widgets/animatedItem.dart';
import 'package:navyoga_academy/widgets/app_background.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:navyoga_academy/utils/app_snackbar.dart';
import 'package:navyoga_academy/utils/auth_manager.dart';
import 'package:navyoga_academy/services/google_auth_service.dart';
import 'package:navyoga_academy/screens/forgot_password_dialog.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreen();
}

class _LoginScreen extends State<LoginScreen> {
  final GoogleAuthService googleAuthService = GoogleAuthService();
  final AuthService authService = AuthService();
  bool rememberMe = false;
  bool obscurePassword = true;
  double _scale = 1;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadRememberMe();
  }

  Future<void> _loadRememberMe() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      rememberMe = prefs.getBool('remember_me') ?? false;
      emailController.text = prefs.getString('saved_email') ?? '';
      passwordController.text = prefs.getString('saved_password') ?? '';
    });
  }

  Future<void> _toggleRememberMe(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('remember_me', value);

    setState(() {
      rememberMe = value;
    });
  }

  Future<void> _handleForgotPassword() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const ForgotPasswordDialog(),
    );
  }

  Future<void> _handleGoogleLogin() async {
    try {
      print("STEP 1");

      final result = await googleAuthService.signInWithGoogle();

      print("STEP 2");
      print(result);
      print("mounted = $mounted");
      if (result != null) {
        print("STEP 3");

        await AuthManager.saveToken("test_token");

        print("TOKEN SAVED");

        Future.delayed(const Duration(milliseconds: 300), () {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
            (route) => false,
          );
        });
      }
    } catch (e) {
      print("GOOGLE ERROR = $e");
    }
  }

  void _handleFacebookLogin() {
    _showSnack("Facebook login coming soon");

  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _showLoader() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Container(
              width: 380,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F7FB),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Column(
                children: [

                  Image.asset(
                    "assets/logo/logo_transparent_clean.png",
                    height: 120,
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    "Welcome back",
                    style: TextStyle(color: Color.fromARGB(255, 16, 16, 16)),
                  ),

                  const SizedBox(height: 24),


                  buildLabel("Email"),
                  const SizedBox(height: 6),
                  buildInput(
                    controller: emailController,
                    hint: "Enter your email",
                    icon: Icons.email_outlined,
                    index: 0,
                  ),

                  const SizedBox(height: 18),


                  buildLabel("Password"),
                  const SizedBox(height: 6),
                  buildInput(
                    controller: passwordController,
                    hint: "Enter your password",
                    icon: Icons.lock_outline,
                    obscure: obscurePassword,
                    suffix: IconButton(
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                    ),
                    index: 1,
                  ),

                  const SizedBox(height: 12),


                  AnimatedItem(
                    index: 2,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: rememberMe,
                                  activeColor: const Color(0xFFFF6A1A),
                                  onChanged: (val) {
                                    if (val != null) _toggleRememberMe(val);
                                  },
                                ),
                                const Text("Remember me"),
                              ],
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: _handleForgotPassword,
                          child: const Text(
                            "Forgot password?",
                            style: TextStyle(
                              color: Color(0xFFFF6A1A),
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),


                  SizedBox(
                    width: double.infinity,
                    child: AnimatedItem(
                      index: 3,
                      child: GestureDetector(
                        onTapDown: (_) => setState(() => _scale = 0.95),
                        onTapUp: (_) => setState(() => _scale = 1),
                        onTapCancel: () => setState(() => _scale = 1),

                        child: AnimatedScale(
                          scale: _scale,
                          duration: const Duration(milliseconds: 150),

                          child: ElevatedButton(
                            onPressed: () async {
                              final email = emailController.text.trim();
                              final password = passwordController.text.trim();

                              if (email.isEmpty || password.isEmpty) {
                                AppSnackbar.showWarning(
                                  context,
                                  "Please enter email and password",
                                );
                                return;
                              }

                              _showLoader();

                              try {
                                final response = await authService.studentLogin(
                                  email: email,
                                  password: password,
                                );


                                Navigator.pop(context);

                               if (ApiHelper.isSuccess(response)) {
  final dynamic responseData = response["data"];

  String? token;

  if (responseData is Map<String, dynamic>) {
    token =
        responseData["token"]?.toString() ??
        responseData["accessToken"]?.toString() ??
        responseData["access_token"]?.toString();
  }

  token ??=
      response["token"]?.toString() ??
      response["accessToken"]?.toString() ??
      response["access_token"]?.toString();

  if (token == null || token.trim().isEmpty) {
    if (!mounted) return;

    AppSnackbar.showError(
      context,
      "Login succeeded, but no authentication token was received.",
    );
    return;
  }

  await AuthManager.saveToken(token);

  final prefs = await SharedPreferences.getInstance();

  if (rememberMe) {
    await prefs.setString('saved_email', email);


    await prefs.remove('saved_password');
  } else {
    await prefs.remove('saved_email');
    await prefs.remove('saved_password');
  }

  if (!mounted) return;

  AppSnackbar.showSuccess(
    context,
    "Login successful",
  );

  Navigator.pushNamedAndRemoveUntil(
    context,
    AppRoutes.dashboard,
    (route) => false,
  );
} else {
                                  AppSnackbar.showError(
                                    context,
                                    response["message"] ?? "Login failed",
                                  );
                                }
                              } catch (e) {
                                Navigator.pop(context);
                                AppSnackbar.showError(
                                  context,
                                  "Login failed: $e",
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF6A1A),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Log In",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 6),
                                Icon(
                                  Icons.arrow_forward,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),


                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignupScreen()),
                      );
                    },
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          color: Color.fromARGB(255, 66, 66, 66),
                        ),
                        children: [
                          TextSpan(text: "Don't have an account? "),
                          TextSpan(
                            text: "Sign up",
                            style: TextStyle(
                              color: Color.fromARGB(255, 56, 11, 84),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),


                  const Text(
                    "© 2026 NavYoga Academy. All rights reserved.",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


  Widget buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
    );
  }


  Widget buildInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required int index,
    bool obscure = false,
    Widget? suffix,
  }) {
    return AnimatedItem(
      index: index,
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.grey),
          suffixIcon: suffix,
          hintText: hint,
          filled: true,
          fillColor: const Color(0xFFF1EFF5),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),


          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFFF6A1A), width: 2),
          ),
        ),
      ),
    );
  }


  Widget socialButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.black54),
            const SizedBox(width: 6),
            Text(text),
          ],
        ),
      ),
    );
  }
}
