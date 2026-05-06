import 'package:flutter/material.dart';

class ActionCard extends StatelessWidget {
  final String title, subtitle;
  final Color color;
  final VoidCallback? onTap; // ✅ ADD THIS

  const ActionCard(
    this.title,
    this.subtitle,
    this.color, {
    super.key,
    this.onTap, // ✅ ADD THIS
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      // ✅ MAKE CLICKABLE
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xfff7f7f7),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),

        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.9), color],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(_getIcon(title), color: Colors.white, size: 22),
            ),

            const SizedBox(width: 14),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.blueGrey, fontSize: 13),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

IconData _getIcon(String title) {
  if (title.contains("Browse")) return Icons.menu_book;
  if (title.contains("Self")) return Icons.school;
  if (title.contains("Watch")) return Icons.videocam;
  if (title.contains("Attendance")) return Icons.calendar_today;
  if (title.contains("Profile")) return Icons.workspace_premium;
  return Icons.star;
}
