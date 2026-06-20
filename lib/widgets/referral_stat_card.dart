import 'package:flutter/material.dart';
import '../models/referral_stat_model.dart';

class ReferralStatCard extends StatelessWidget {
  final ReferralStatModel stat;

  const ReferralStatCard({super.key, required this.stat});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (stat.route != null) {
          Navigator.pushNamed(context, stat.route!);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: stat.borderColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stat.title,
                  style: const TextStyle(color: Colors.blueGrey, fontSize: 13),
                ),
                SizedBox(height: 4),
                Text(
                  stat.value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            CircleAvatar(
              backgroundColor: stat.iconBg,
              radius: 22,
              child: Icon(stat.icon, color: stat.iconColor, size: 22),
            ),
          ],
        ),
      ),
    );
  }
}
