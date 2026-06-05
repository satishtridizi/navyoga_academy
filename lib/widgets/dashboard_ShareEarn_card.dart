import 'package:flutter/material.dart';
import 'package:navyoga_academy/routes/app_routes.dart';

class ShareEarnCard extends StatelessWidget {
  const ShareEarnCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xffffefe6),
        borderRadius: BorderRadius.circular(24),

        /// BORDER
        border: Border.all(color: Colors.deepOrange, width: 1.5),

        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.2),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ICON
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.deepOrange,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.deepOrange.withOpacity(0.4),
                  blurRadius: 10,
                ),
              ],
            ),
            child: const Icon(Icons.star_border, color: Colors.white),
          ),

          const SizedBox(height: 16),

          /// TITLE
          const Text(
            "Share & Earn Rewards!",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.deepOrange,
            ),
          ),

          const SizedBox(height: 10),

          /// DESCRIPTION
          const Text(
            "Invite friends and earn ₹300 per referral + unlock achievement badges",
            style: TextStyle(color: Colors.blueGrey),
          ),

          const SizedBox(height: 20),

          /// BUTTON
          Center(
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.referral);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 5,
              ),
              icon: const Icon(Icons.card_giftcard, color: Colors.white),
              label: const Text(
                "View Referral Program",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
