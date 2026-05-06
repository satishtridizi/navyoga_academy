import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:navyoga_academy/widgets/app_background.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),

        title: const Text(
          "Terms of Service",
          style: TextStyle(
            color: Colors.deepOrange,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: AppBackground(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              /// HEADER CARD
              Container(
                padding: const EdgeInsets.all(22),

                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xff7B1FA2), Color(0xff9C27B0)],
                  ),

                  borderRadius: BorderRadius.circular(26),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),

                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),

                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(18),
                      ),

                      child: const Icon(
                        Icons.description_outlined,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),

                    const SizedBox(width: 16),

                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(
                            "Terms & Conditions",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          SizedBox(height: 6),

                          Text(
                            "Please read these terms carefully before using NavYoga Academy.",
                            style: TextStyle(
                              color: Colors.white70,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fade(duration: 500.ms).slideY(begin: 0.2),

              const SizedBox(height: 24),

              /// CONTENT CARD
              Container(
                padding: const EdgeInsets.all(22),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),

                  border: Border.all(
                    color: Colors.deepOrange.withOpacity(0.15),
                  ),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    _sectionTitle("1. Acceptance of Terms"),

                    _paragraph(
                      "By accessing and using NavYoga Academy, you agree to comply with and be bound by these Terms of Service.",
                    ),

                    const SizedBox(height: 20),

                    _sectionTitle("2. User Responsibilities"),

                    _paragraph(
                      "Users are responsible for maintaining the confidentiality of their account credentials and for all activities under their account.",
                    ),

                    const SizedBox(height: 20),

                    _sectionTitle("3. Subscription & Payments"),

                    _paragraph(
                      "Subscription plans are billed according to the selected plan cycle. Payments are non-refundable unless stated otherwise.",
                    ),

                    const SizedBox(height: 20),

                    _sectionTitle("4. Content Usage"),

                    _paragraph(
                      "All recordings, yoga materials, and content provided by NavYoga Academy are protected by copyright and may not be redistributed.",
                    ),

                    const SizedBox(height: 20),

                    _sectionTitle("5. Account Termination"),

                    _paragraph(
                      "We reserve the right to suspend or terminate accounts that violate our policies or misuse the platform.",
                    ),

                    const SizedBox(height: 20),

                    _sectionTitle("6. Changes to Terms"),

                    _paragraph(
                      "NavYoga Academy may update these terms periodically. Continued use of the platform indicates acceptance of updated terms.",
                    ),
                  ],
                ),
              ).animate().fade(duration: 600.ms).slideY(begin: 0.15),

              const SizedBox(height: 30),

              /// FOOTER
              Center(
                child: Text(
                  "Last updated: May 2026",
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// SECTION TITLE
  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.deepOrange,
      ),
    );
  }

  /// PARAGRAPH
  Widget _paragraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),

      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.blueGrey,
          height: 1.7,
        ),
      ),
    );
  }
}
