import 'package:flutter/material.dart';

class ShareSection extends StatelessWidget {
  const ShareSection({super.key});

  Widget _socialButton(String text, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [color.withOpacity(.9), color]),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 6),
            Text(text, style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
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
            "Share Your Referral Code",
            style: TextStyle(
              color: Colors.deepOrange,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Share your unique code with friends and family",
            style: TextStyle(color: Colors.blueGrey),
          ),

          const SizedBox(height: 16),

          /// CODE
          const Text("Your Referral Code"),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: const Text("NAVYOGA-SARAH-2026"),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.deepPurple, Colors.purple],
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  "Copy",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          /// LINK
          const Text("Your Referral Link"),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: const Text(
                    "https://navyoga.academy/join/NAVY",
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text("Copy"),
              ),
            ],
          ),

          const SizedBox(height: 18),

          const Text("Share on Social Media"),

          const SizedBox(height: 10),

          Row(
            children: [
              _socialButton("WhatsApp", Colors.green, Icons.chat),
              const SizedBox(width: 10),
              _socialButton("Email", Colors.blue, Icons.email),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              _socialButton("Facebook", Colors.blueAccent, Icons.facebook),
              const SizedBox(width: 10),
              _socialButton("Twitter", Colors.lightBlue, Icons.flutter_dash),
            ],
          ),
        ],
      ),
    );
  }
}
