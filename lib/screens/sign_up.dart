import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:navyoga_academy/widgets/animatedItem.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  bool rememberMe = false;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> _handleForgotPassword() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      _showSnack("Enter your email first");
      return;
    }

    if (!_isValidEmail(email)) {
      _showSnack("Enter a valid email");
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await Future.delayed(const Duration(seconds: 2));

      Navigator.pop(context);

      _showSnack("Password reset link sent to $email");
    } catch (e) {
      Navigator.pop(context);
      _showSnack("Something went wrong. Try again.");
    }
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

              const SizedBox(height: 20),

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
                  _showSnack("Call feature coming soon");
                },
              ),

              ListTile(
                leading: const Icon(Icons.chat),
                title: const Text("Chat Support"),
                onTap: () {
                  Navigator.pop(context);
                  _showSnack("Chat support coming soon");
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
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
          Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Container(
                      width: 380,
                      padding: const EdgeInsets.all(24),
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
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color.fromARGB(255, 255, 174, 0),
                                  Color(0xFF6A11CB),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Icon(
                              Icons.auto_awesome_outlined,
                              color: Colors.white,
                              size: 35,
                            ),
                          ),

                          const SizedBox(height: 18),

                          const Text(
                            "Sign up",
                            style: TextStyle(
                              fontSize: 28,
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

                          const SizedBox(height: 30),

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
                                    labelText: "Email Address",
                                    hintText: "your.email@navyoga.com",

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

                          const SizedBox(height: 20),

                          buildLabel("Password", Icons.lock_outline),
                          const SizedBox(height: 8),
                          Column(
                            children: [
                              AnimatedItem(
                                index: 1,
                                child: TextFormField(
                                  controller: passwordController,
                                  obscureText: true,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: "Password",
                                    hintText: "Enter 6-digit password",

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
                                      return "Password is required";
                                    }

                                    if (!RegExp(
                                      r'^[0-9]{6}$',
                                    ).hasMatch(value)) {
                                      return "Password must be exactly 6 digits";
                                    }

                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

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

                          const SizedBox(height: 18),

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
                                    onPressed: () {
                                      /// ✅ Validate form
                                      if (!_formKey.currentState!.validate()) {
                                        return;
                                      }

                                      /// ✅ Success
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Account created successfully",
                                          ),
                                        ),
                                      );

                                      /// ✅ Navigate back
                                      Future.delayed(
                                        const Duration(milliseconds: 500),
                                        () {
                                          Navigator.pop(context);
                                        },
                                      );
                                    },
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
                                    child: const Text(
                                      "Sign In",
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

                          const SizedBox(height: 20),

                          /// DIVIDER
                          Container(
                            height: 1,
                            width: double.infinity,
                            color: Colors.orange.withValues(alpha: 0.3),
                          ),

                          const SizedBox(height: 12),

                          /// FOOTER TEXT
                          Column(
                            children: [
                              AnimatedItem(
                                index: 4,
                                child: RichText(
                                  text: TextSpan(
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 39, 39, 39),
                                    ),
                                    children: [
                                      TextSpan(text: "Don't have an account? "),
                                      TextSpan(
                                        text: "Contact Admin",
                                        style: TextStyle(
                                          color: Color.fromARGB(
                                            255,
                                            50,
                                            0,
                                            104,
                                          ),
                                          fontWeight: FontWeight.w600,
                                          decoration: TextDecoration.underline,
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = _handleContactAdmin,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// © COPYRIGHT
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
          ),
        ],
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

  static Widget buildField({
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color.fromARGB(255, 85, 84, 84)),
        filled: true,
        fillColor: const Color.fromARGB(255, 255, 255, 255),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 08,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF6A11CB), width: 1.2),
        ),
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
