import 'package:flutter/material.dart';

class RewardSummarySection extends StatelessWidget {
  const RewardSummarySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF9), // lighter, cleaner
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFFE6CC), // lighter
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔹 Header
          Row(
            children: const [
              Icon(Icons.workspace_premium_outlined, color: Colors.deepPurple),
              SizedBox(width: 8),
              Text(
                "Reward Summary",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.deepPurple,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          /// 🔹 Balance Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFEDE3F7), Color(0xFFF3E5D8)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("Available Balance", style: TextStyle(fontSize: 14)),
                    SizedBox(height: 8),
                    Text(
                      "₹ 2400",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ],
                ),
                const Icon(Icons.star_border, color: Colors.orange),
              ],
            ),
          ),

          const SizedBox(height: 16),

          /// 🔹 Stats
          _rowItem("Total Earned", "₹ 3600"),
          _rowItem("Redeemed", "₹ 1200"),
          _rowItem("Pending", "₹ 600"),

          const SizedBox(height: 16),

          /// 🔹 Button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6A1B9A), Color(0xFF8E24AA)],
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.play_arrow_rounded, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text("Redeem Rewards", style: TextStyle(color: Colors.white)),
              ],
            ),
          ),

          const SizedBox(height: 12),

          /// 🔹 Footer Note
          const Center(
            child: Text(
              "Rewards can be redeemed for subscription discounts or transferred to your account",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  /// 🔹 Helper Row
  Widget _rowItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(color: Colors.grey[700])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
