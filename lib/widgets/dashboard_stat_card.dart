import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final Color color;
  final VoidCallback? onTap;

  const StatCard(
    this.title,
    this.value,
    this.subtitle,
    this.color, {
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),

      child: Container(
        padding: const EdgeInsets.all(16),

        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),

          /// 🌈 SOFT GRADIENT BACKGROUND
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
          ),

          /// 🌫 SOFT SHADOW (NEUMORPHIC FEEL)
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.6),
              blurRadius: 8,
              offset: const Offset(-2, -2),
            ),
          ],
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔝 TOP ROW
            Row(
              children: [
                /// 🔥 ICON BOX (FLOATING STYLE)
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(14),

                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(_getIcon(title), color: Colors.white, size: 16),
                ),

                const SizedBox(width: 10),

                /// TITLE
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xff64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

            const Spacer(),

            /// 🔻 VALUE + SUBTITLE
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff1E1B39),
                  ),
                ),

                const SizedBox(width: 8),

                Flexible(
                  child: Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.visible,

                    style: TextStyle(
                      fontSize: 12,
                      color: color,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 🎯 ICON MAPPING (UPDATED LIKE IMAGE)
  IconData _getIcon(String title) {
    if (title.contains("Enrolled")) return Icons.menu_book;
    if (title.contains("Hours")) return Icons.access_time;
    if (title.contains("Recordings")) return Icons.videocam;
    if (title.contains("Attendance")) return Icons.trending_up;
    return Icons.star;
  }
}
