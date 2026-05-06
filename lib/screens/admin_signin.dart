import 'package:flutter/material.dart';
import 'package:navyoga_academy/widgets/app_background.dart';
import 'package:navyoga_academy/widgets/app_background.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool rememberMe = false;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: Stack(
          children: [
            /// 🌈 BACKGROUND GRADIENT (PURPLE)
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF6A0572),
                    Color.fromARGB(255, 164, 80, 164),
                    Color(0xFF6A0572),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),

            /// 🎨 FLOATING DOTS
            Positioned(top: 80, left: 40, child: circle(10, Colors.orange)),

            Positioned(
              bottom: 80,
              left: 80,
              child: circle(12, Colors.white.withValues(alpha: 0.6)),
            ),

            /// 📦 CARD CONTENT
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDE7F6).withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /// 🔶 LOGO ICON
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color.fromARGB(255, 154, 0, 177),
                            Color.fromARGB(250, 83, 0, 91),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.auto_awesome_outlined,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),

                    const SizedBox(height: 16),

                    /// TITLE
                    const Text(
                      "NavYoga Academy",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF6A00),
                      ),
                    ),

                    const SizedBox(height: 6),

                    /// SUBTITLE
                    const Text(
                      "Login Portal",
                      style: TextStyle(color: Colors.orangeAccent),
                    ),

                    const SizedBox(height: 24),

                    /// EMAIL
                    buildLabel("Email Address", Icons.email_outlined),
                    const SizedBox(height: 6),
                    buildField(
                      controller: emailController,
                      hint: "admin@navyoga.com",
                    ),

                    const SizedBox(height: 16),

                    /// PASSWORD
                    buildLabel("Password", Icons.lock_outline),
                    const SizedBox(height: 6),
                    buildField(
                      controller: passwordController,
                      hint: "Enter your password",
                      obscure: true,
                    ),

                    const SizedBox(height: 12),

                    /// REMEMBER + FORGOT
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            // Checkbox(
                            //   value: rememberMe,
                            //   activeColor: const Color(0xFF6A11CB),
                            //   onChanged: (val) {
                            //     setState(() {
                            //       rememberMe = val!;
                            //     });
                            //   },
                            // ),
                            const Text("Remember me"),
                          ],
                        ),
                        const Text(
                          "Forgot password?",
                          style: TextStyle(color: Colors.deepOrange),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    /// 🔘 BUTTON
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color.fromARGB(255, 149, 7, 177),
                            Color.fromARGB(255, 129, 4, 136),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.deepPurple.withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          "Sign In as Admin",
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
            ),
          ],
        ),
      ),
    );
  }

  /// 🔘 LABEL
  static Widget buildLabel(String text, IconData icon) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.deepOrange),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  /// 🔤 FIELD
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
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.orange.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.deepPurple),
        ),
      ),
    );
  }

  /// 🎨 Circle
  Widget circle(double size, Color color) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
