import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:navyoga_academy/widgets/app_scaffold.dart';
import 'package:navyoga_academy/utils/app_snackbar.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentIndex: 4,

      //backgroundColor: Colors.transparent,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "Privacy Policy",
          style: TextStyle(
            color: Colors.deepOrange,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔥 HEADER CARD
            Animate(
              effects: const [
                FadeEffect(duration: Duration(milliseconds: 500)),

                SlideEffect(
                  begin: Offset(0, 0.2),
                  end: Offset(0, 0),
                  duration: Duration(milliseconds: 500),
                ),
              ],

              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xffFF6B35), Color(0xffFF8C42)],
                  ),

                  borderRadius: BorderRadius.circular(28),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),

                child: const Row(
                  children: [
                    Icon(Icons.privacy_tip, color: Colors.white, size: 34),

                    SizedBox(width: 14),

                    Expanded(
                      child: Text(
                        "Your privacy and data security are important to us.",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          height: 1.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            /// 🔥 SECTION 1
            _policySection(
              index: 0,
              title: "1. Information We Collect",
              content:
                  "We may collect your personal details such as name, email address, phone number, class activity, and payment information while using NavYoga Academy.",
            ),

            /// 🔥 SECTION 2
            _policySection(
              index: 1,
              title: "2. How We Use Your Data",
              content:
                  "Your data is used to improve your learning experience, manage subscriptions, provide customer support, and enhance platform security.",
            ),

            /// 🔥 SECTION 3
            _policySection(
              index: 2,
              title: "3. Payment Security",
              content:
                  "All payment transactions are processed securely through trusted payment gateways. We do not store sensitive card details on our servers.",
            ),

            /// 🔥 SECTION 4
            _policySection(
              index: 3,
              title: "4. Data Protection",
              content:
                  "We use industry-standard security measures to protect your information from unauthorized access or misuse.",
            ),

            /// 🔥 SECTION 5
            _policySection(
              index: 4,
              title: "5. Contact Us",
              content:
                  "If you have questions regarding our privacy practices, you may contact the NavYoga Academy support team anytime.",
            ),

            const SizedBox(height: 30),

            /// 🔥 FOOTER
            Center(
              child: Text(
                "Last Updated • July 2026",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _policySection({
    required int index,
    required String title,
    required String content,
  }) {
    return Animate(
      delay: Duration(milliseconds: 150 * index),

      effects: const [
        FadeEffect(duration: Duration(milliseconds: 500)),

        SlideEffect(
          begin: Offset(0, 0.15),
          end: Offset(0, 0),
          duration: Duration(milliseconds: 500),
        ),
      ],

      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        padding: const EdgeInsets.all(18),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),

          border: Border.all(color: Colors.deepOrange.withOpacity(0.12)),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.deepOrange,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              content,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.blueGrey,
                height: 1.7,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
