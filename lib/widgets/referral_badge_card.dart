import 'package:flutter/material.dart';
import '../models/badge_model.dart';

class BadgeCard extends StatelessWidget {
  final BadgeModel badge;

  const BadgeCard({super.key, required this.badge});

  double _getProgress(String text) {
    final parts = text.split('/');
    return double.parse(parts[0]) / double.parse(parts[1]);
  }

  int _getPercent(String text) {
    final parts = text.split('/');
    return ((double.parse(parts[0]) / double.parse(parts[1])) * 100).toInt();
  }

  @override
  Widget build(BuildContext context) {
    final progress = _getProgress(badge.progressText);
    final percent = _getPercent(badge.progressText);

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: badge.color.withOpacity(.08),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: badge.color.withOpacity(.35)),
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [badge.color, badge.color.withOpacity(.7)],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: badge.color.withOpacity(.3),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Icon(badge.icon, color: Colors.white, size: 28),
              ),


              if (badge.isCompleted)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(width: 14),


          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  badge.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),

                const SizedBox(height: 4),


                Text(
                  badge.subtitle,
                  style: const TextStyle(color: Colors.blueGrey),
                ),

                const SizedBox(height: 10),


                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${badge.percent}% Complete",
                      style: const TextStyle(color: Colors.blueGrey),
                    ),
                    Text(
                      badge.progressText,
                      style: TextStyle(
                        color: badge.color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),


                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation(badge.color),
                  ),
                ),

                const SizedBox(height: 12),


                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),

                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(.12),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.green.withOpacity(.4)),
                  ),

                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        size: 16,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "Earned ${badge.reward}",
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
