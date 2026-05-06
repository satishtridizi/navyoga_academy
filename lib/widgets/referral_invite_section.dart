import 'package:flutter/material.dart';
import 'package:navyoga_academy/routes/app_routes.dart';
import 'package:share_plus/share_plus.dart';

class InviteSection extends StatelessWidget {
  const InviteSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [Colors.deepPurple, Colors.purple],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.person_add, color: Colors.white, size: 28),

          const SizedBox(height: 10),

          const Text(
            "Invite More Friends!",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            "The more you share, the more you earn. No limits on referrals!",
            style: TextStyle(color: Colors.white70),
          ),

          const SizedBox(height: 16),

          AnimatedScale(
            duration: const Duration(milliseconds: 150),
            scale: 1,

            child: InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: () {
                Share.share(
                  "Join NavYoga Academy using my referral code NAVYOGA-SARAH-2026\n\nhttps://navyoga.academy/join/NAVY",
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                alignment: Alignment.center,
                child: const Text(
                  "Share Now",
                  style: TextStyle(color: Colors.deepPurple),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
