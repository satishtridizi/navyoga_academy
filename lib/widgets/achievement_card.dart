import 'package:flutter/material.dart';
import '../models/achievement_model.dart';

class AchievementCard extends StatelessWidget {
  final AchievementModel data;

  const AchievementCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // ✅ THIS FIXES WIDTH
      width: double.infinity,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 18),

        decoration: BoxDecoration(
          color: const Color(0xfff7f7f7),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.green, width: 1.5),
        ),

        child: Column(
          children: [
            Text(data.emoji, style: const TextStyle(fontSize: 36)),

            const SizedBox(height: 14),

            Text(
              data.title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              data.subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.blueGrey),
            ),

            const SizedBox(height: 14),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xffE9EDF3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(data.date),
            ),
          ],
        ),
      ),
    );
  }
}
