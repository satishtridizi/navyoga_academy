import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:navyoga_academy/routes/app_routes.dart';
import 'package:navyoga_academy/screens/forgot_password_dialog.dart';
import 'package:navyoga_academy/services/auth_service.dart';
import 'package:navyoga_academy/utils/api_helper.dart';
import 'package:navyoga_academy/widgets/animatedItem.dart';
import 'package:navyoga_academy/widgets/app_background.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:navyoga_academy/utils/app_snackbar.dart';
import 'package:navyoga_academy/utils/auth_manager.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  bool rememberMe = false;
  bool _obscurePassword = true;
  bool _isSubmitting = false;

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final referralCodeController = TextEditingController();
  Future<void> _handleForgotPassword() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const ForgotPasswordDialog(),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadRememberMe();
  }

  Future<void> _loadRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      rememberMe = prefs.getBool('remember_me') ?? false;
    });
  }

  Future<void> _toggleRememberMe(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('remember_me', value);

    setState(() {
      rememberMe = value;
    });
  }

  void _handleContactAdmin() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Contact Admin",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              ListTile(
                leading: const Icon(Icons.email),
                title: const Text("Email Support"),
                onTap: () {
                  Navigator.pop(context);
                  launchUrl(Uri.parse("mailto:support@navyoga.com"));
                },
              ),

              ListTile(
                leading: const Icon(Icons.phone),
                title: const Text("Call Admin"),
                onTap: () {
                  Navigator.pop(context);
                  AppSnackbar.showWarning(context, "Call feature coming soon");
                },
              ),

              ListTile(
                leading: const Icon(Icons.chat),
                title: const Text("Chat Support"),
                onTap: () {
                  Navigator.pop(context);
                  AppSnackbar.showWarning(context, "Chat support coming soon");
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _createAccount() async {
    if (_isSubmitting || !_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    try {
      final response = await AuthService().studentRegister(
        name: nameController.text.trim(),
        phone: phoneController.text.replaceAll(RegExp(r'\D'), ''),
        email: emailController.text.trim(),
        password: passwordController.text,
        referralCode: referralCodeController.text.trim(),
      );

      if (!mounted) return;
      if (!ApiHelper.isSuccess(response)) {
        AppSnackbar.showError(
          context,
          response['message']?.toString() ?? 'Unable to create account.',
        );
        return;
      }

      final rawData = response['data'];
      String? token;
      if (rawData is Map) {
        token = rawData['token']?.toString() ??
            rawData['accessToken']?.toString();
      }
      token ??= response['token']?.toString() ??
          response['accessToken']?.toString();

      if (token == null || token.trim().isEmpty) {
        AppSnackbar.showSuccess(
          context,
          'Account created. Please log in to continue.',
        );
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.login,
          (_) => false,
        );
        return;
      }

      await AuthManager.saveToken(token);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('show_onboarding', true);

      if (!mounted) return;
      AppSnackbar.showSuccess(context, 'Account created successfully');
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.dashboard,
        (_) => false,
      );
    } catch (error) {
      if (mounted) {
        AppSnackbar.showError(context, 'Unable to create account: $error');
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 236, 227, 215),
                    Color.fromARGB(255, 255, 255, 255),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 98,
              left: 60,
              child: _circle(70, const Color.fromARGB(255, 255, 102, 0)),
            ),
            Positioned(
              bottom: 134,
              right: 50,
              child: _circle(90, const Color.fromARGB(255, 255, 180, 69)),
            ),
            SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: 20,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 25,
                            color: Colors.black.withValues(alpha: 0.08),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.only(top: 8),

                            child: Image.asset(
                              "assets/logo/logo_transparent_clean.png",
                              height: 80,
                              fit: BoxFit.contain,
                            ),
                          ),

                          const SizedBox(height: 8),

                          const Text(
                            "Sign up",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 67, 0, 119),
                            ),
                          ),

                          const SizedBox(height: 10),

                          const Text(
                            "Enter your credentials to access your account",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              color: Color.fromARGB(255, 45, 45, 45),
                            ),
                          ),

                          const SizedBox(height: 16),
                          buildLabel("Full Name", Icons.person_outline),
                          const SizedBox(height: 8),

                          TextFormField(
                            controller: nameController,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              labelText: "Full Name",
                              hintText: "Enter your full name",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: Colors.deepOrange,
                                  width: 2,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Name is required";
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 12),

                          buildLabel("Phone Number", Icons.phone_outlined),
                          const SizedBox(height: 8),

                          TextFormField(
                            controller: phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              labelText: "Phone Number",
                              hintText: "919876543210",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: Colors.deepOrange,
                                  width: 2,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Phone number is required";
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 12),
                          buildLabel("Email Address", Icons.email_outlined),
                          const SizedBox(height: 8),
                          Column(
                            children: [
                              AnimatedItem(
                                index: 0,
                                child: TextFormField(
                                  controller: emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    labelText: "Email Address",
                                    hintText: "Enter your email address",

                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),

                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(
                                        color: Colors.deepOrange,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Email is required";
                                    }

                                    final emailRegex = RegExp(
                                      r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
                                    );

                                    if (!emailRegex.hasMatch(value)) {
                                      return "Enter a valid email address";
                                    }

                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          buildLabel("Password", Icons.lock_outline),
                          const SizedBox(height: 8),
                          Column(
                            children: [
                              AnimatedItem(
                                index: 1,
                                child: TextFormField(
                                  controller: passwordController,
                                  obscureText: _obscurePassword,
                                  keyboardType: TextInputType.text,
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    labelText: "Password",
                                    hintText: "Enter your password",

                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),

                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(
                                        color: Colors.deepOrange,
                                        width: 2,
                                      ),
                                    ),

                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                  ),

                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Password is required";
                                    }

                                    if (value.length < 8) {
                                      return "Password must be at least 8 characters";
                                    }

                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          buildLabel(
                            "Referral Code (Optional)",
                            Icons.card_giftcard,
                          ),

                          const SizedBox(height: 8),

                          TextFormField(
                            controller: referralCodeController,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              hintText: "ARJU-AB12CD",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: Colors.deepOrange,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),

                          AnimatedItem(
                            index: 2,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Checkbox(
                                      value: rememberMe,
                                      onChanged: (value) {
                                        if (value != null) {
                                          _toggleRememberMe(value);
                                        }
                                      },
                                    ),
                                    const Text("Remember me"),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: _handleForgotPassword,
                                  child: const Text(
                                    "Forgot password?",
                                    style: TextStyle(
                                      color: Colors.deepOrange,
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 12),

                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color.fromARGB(255, 246, 103, 1),
                                  Color.fromARGB(255, 85, 0, 177),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color.fromARGB(
                                    255,
                                    0,
                                    0,
                                    0,
                                  ).withValues(alpha: 0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                AnimatedItem(
                                  index: 3,
                                  child: ElevatedButton(
                                    onPressed:
                                        _isSubmitting ? null : _createAccount,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 10,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: _isSubmitting
                                        ? const SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Text(
                                            "Create Account",
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 12),


                          Container(
                            height: 1,
                            width: double.infinity,
                            color: Colors.orange.withValues(alpha: 0.3),
                          ),

                          const SizedBox(height: 12),


                          const SizedBox(height: 20),

                          AnimatedItem(
                            index: 4,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Already have an account? ",
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Color(0xFF4B5563),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),

                                GestureDetector(
                                  onTap: () {
                                    Navigator.pop(
                                      context,
                                    );
                                  },
                                  child: const Text(
                                    "Sign in",
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Color.fromARGB(255, 67, 0, 119),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),


                    const Text(
                      "© 2026 NavYoga Academy. All rights reserved.",
                      style: TextStyle(
                        color: Color.fromARGB(255, 47, 47, 47),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget buildLabel(String text, IconData icon) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color.fromARGB(255, 255, 162, 0)),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color.fromARGB(255, 47, 0, 98),
            ),
          ),
        ],
      ),
    );
  }


  Widget _circle(double size, Color color) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
