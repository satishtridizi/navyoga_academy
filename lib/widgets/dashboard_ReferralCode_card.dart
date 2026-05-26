import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

class ReferralCodeCard extends StatelessWidget {
  const ReferralCodeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xff7b1fa2), Color(0xff9c27b0)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// TOP ROW
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              /// SHARE ICON
              GestureDetector(
                onTap: () {
                  const referralCode = "NAVYOGA-SARAH-2026";

                  Share.share(
                    "Join NavYoga Academy using my referral code: $referralCode\n\nGet discounts on your subscription 🎉",
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.share, color: Colors.white),
                ),
              ),

              /// COPY BUTTON
              GestureDetector(
                onTap: () {
                  const code = "NAVYOGA20";

                  Clipboard.setData(const ClipboardData(text: code));

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Referral code copied 🎉")),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.copy, color: Colors.white, size: 16),
                      SizedBox(width: 6),
                      Text("Copy", style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          /// CODE
          const Text(
            "NAVYOGA20",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            "Your Referral Code",
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
