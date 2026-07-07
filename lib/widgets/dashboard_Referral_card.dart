import 'package:flutter/material.dart';

class ReferralCard extends StatelessWidget {
  final String value, title, badge;
  final Color color;

  const ReferralCard(
    this.value,
    this.title,
    this.color,
    this.badge, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        /// 🔥 BACKGROUND
        gradient: LinearGradient(
          colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
        ),

        borderRadius: BorderRadius.circular(24),

        /// 🎯 BORDER
        border: Border.all(color: color.withOpacity(0.4), width: 1.5),

        /// 🎯 SHADOW
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.25),
            blurRadius: 20,
            spreadRadius: 1,
            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.topLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔥 TOP ROW (ICON + BADGE)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                /// ICON BOX
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color.withOpacity(0.9), color],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: color.withOpacity(0.4), blurRadius: 10),
                    ],
                  ),
                  child: Icon(_getIcon(title), color: Colors.white, size: 18),
                ),

                /// BADGE
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            /// VALUE
            Text(
              value,
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: Color(0xff2f3542),
              ),
            ),

            const SizedBox(height: 2),

            /// TITLE
            Text(
              title,
              style: const TextStyle(color: Colors.blueGrey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  /// 🎯 ICON MAPPING
  IconData _getIcon(String title) {
    if (title.contains("Referrals")) return Icons.group;
    if (title.contains("Earned")) return Icons.currency_rupee;
    if (title.contains("Badges")) return Icons.emoji_events;
    return Icons.star;
  }
}
