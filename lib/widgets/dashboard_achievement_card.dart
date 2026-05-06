import 'package:flutter/material.dart';

class AchievementCard extends StatelessWidget {
  final String title, subtitle;
  final Color color;
  final bool earned;

  const AchievementCard(
    this.title,
    this.subtitle,
    this.color,
    this.earned, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.92, end: 1),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutBack,

      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },

      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          /// 🎯 BACKGROUND (KEY FIX)
          gradient: earned
              ? LinearGradient(
                  colors: [color.withOpacity(0.12), color.withOpacity(0.05)],
                )
              : null,

          color: earned ? null : Colors.grey.shade100,

          borderRadius: BorderRadius.circular(24),

          /// 🎯 BORDER
          border: Border.all(
            color: earned ? color : Colors.grey.shade300,
            width: earned ? 1.5 : 1.2,
          ),

          /// 🎯 SHADOW
          boxShadow: [
            if (earned)
              BoxShadow(
                color: color.withOpacity(0.25),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
          ],
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔥 TOP ROW (ICON + BADGE)
            Row(
              children: [
                /// ICON
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: earned ? color : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: earned
                        ? [
                            BoxShadow(
                              color: color.withOpacity(0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [],
                  ),
                  child: Icon(_getIcon(title), color: Colors.white, size: 22),
                ),

                const SizedBox(width: 12),

                /// BADGE (RIGHT OF ICON)
                if (earned)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "✓ Earned",
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 14),

            /// TITLE
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xff2f3542),
              ),
            ),

            const SizedBox(height: 6),

            /// SUBTITLE
            Text(
              subtitle,
              style: const TextStyle(color: Colors.blueGrey, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIcon(String title) {
    if (title.contains("Streak")) return Icons.local_fire_department;
    if (title.contains("Bird")) return Icons.track_changes;
    return Icons.emoji_events;
  }
}
