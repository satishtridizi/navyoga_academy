import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: NavaYugaSigninScreen(),
    );
  }
}

class NavaYugaSigninScreen extends StatefulWidget {
  const NavaYugaSigninScreen({super.key});

  @override
  State<NavaYugaSigninScreen> createState() => _NavaYugaSigninScreen();
}

class _NavaYugaSigninScreen extends State<NavaYugaSigninScreen> {
  bool rememberMe = false;
  bool obscurePassword = true;

  final emailController = TextEditingController(text: "you@navyoga.com");
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3F7),
      body: Center(
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
                /// 🔶 LOGO
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6A1A),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.auto_awesome_outlined,
                    color: Colors.white,
                    size: 28,
                  ),
                ),

                const SizedBox(height: 16),

                /// TITLE
                const Text(
                  "NavYoga Academy",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 72, 0, 113),
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  "Welcome back",
                  style: TextStyle(color: Color.fromARGB(255, 69, 69, 69)),
                ),

                const SizedBox(height: 24),

                /// EMAIL
                buildLabel("Email"),
                const SizedBox(height: 6),
                buildInput(
                  controller: emailController,
                  hint: "you@navyoga.com",
                  icon: Icons.email_outlined,
                ),

                const SizedBox(height: 18),

                /// PASSWORD
                buildLabel("Password"),
                const SizedBox(height: 6),
                buildInput(
                  controller: passwordController,
                  hint: "Enter your password",
                  icon: Icons.lock_outline,
                  obscure: obscurePassword,
                  suffix: IconButton(
                    icon: Icon(
                      obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                  ),
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
                        //   activeColor: const Color(0xFFFF6A1A),
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
                      style: TextStyle(
                        color: Color(0xFFFF6A1A),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                /// 🔘 SIGN IN BUTTON
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
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
                          "Sign In",
                          style: TextStyle(fontSize: 16, color: Colors.white),
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

                const SizedBox(height: 50),

                /// DIVIDER WITH TEXT
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 2,
                      ),
                      color: const Color.fromARGB(255, 255, 255, 255),
                      child: const Text("or continue with"),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),

                const SizedBox(height: 18),

                /// SOCIAL BUTTONS
                Row(
                  children: [
                    Expanded(
                      child: socialButton(
                        icon: Icons.g_mobiledata,
                        text: "Google",
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: socialButton(
                        icon: Icons.facebook,
                        text: "Facebook",
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                /// SIGN UP
                RichText(
                  text: const TextSpan(
                    style: TextStyle(color: Color.fromARGB(255, 66, 66, 66)),
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

                const SizedBox(height: 40),

                /// COPYRIGHT
                const Text(
                  "© 2026 NavYoga Academy. All rights reserved.",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// LABEL
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

  /// INPUT
  Widget buildInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
  }) {
    return TextField(
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
      ),
    );
  }

  /// SOCIAL BUTTON
  Widget socialButton({required IconData icon, required String text}) {
    return Container(
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
    );
  }
}
