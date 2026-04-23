import 'package:flutter/material.dart';

class HowItWorksSection extends StatelessWidget {
  const HowItWorksSection({super.key});

  Widget step(int number, String title, String subtitle, Color color) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: color,
          child: Text("$number", style: const TextStyle(color: Colors.white)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(subtitle, style: const TextStyle(color: Colors.blueGrey)),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xffF2DED2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "How It Works",
            style: TextStyle(
              color: Colors.deepOrange,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          step(
            1,
            "Share Your Code",
            "Send your unique referral code to friends",
            Colors.orange,
          ),
          const SizedBox(height: 10),

          step(
            2,
            "Friend Joins",
            "They sign up using your referral code",
            Colors.purple,
          ),
          const SizedBox(height: 10),

          step(
            3,
            "Get Rewarded",
            "Earn ₹300 when they subscribe",
            Colors.green,
          ),
          const SizedBox(height: 10),

          step(
            4,
            "They Get Discount",
            "Your friend gets 10% off their first month",
            Colors.deepPurple,
          ),
        ],
      ),
    );
  }
}
