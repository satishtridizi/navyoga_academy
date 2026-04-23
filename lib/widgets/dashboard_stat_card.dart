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
      borderRadius: BorderRadius.circular(20),

      child: Container(
        padding: const EdgeInsets.all(14),

        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),

          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,

            colors: [color.withOpacity(.16), color.withOpacity(.07)],
          ),
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// TOP ROW
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),

                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                  ),

                  child: Icon(_getIcon(title), color: Colors.white, size: 14),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Text(
                    title,
                    maxLines: 2,

                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xff64748B),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),

            const Spacer(),

            /// BOTTOM ROW
            Row(
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff1E1B39),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: color,
                      fontWeight: FontWeight.w500,
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

  IconData _getIcon(String title) {
    return Icons.star;
  }
}
