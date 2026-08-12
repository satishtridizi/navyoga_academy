import 'package:flutter/material.dart';

class ClassCard extends StatelessWidget {
   const ClassCard(
    this.title,
    this.instructor,
    this.duration, {
    super.key,
    required this.onJoin,
    this.joinButtonText = 'View Class',
    this.isLive = false,
  });

  final String title;
  final String instructor;
  final String duration;
  final VoidCallback onJoin;
  final String joinButtonText;
  final bool isLive;

  @override
  Widget build(BuildContext context) {
    final Color accent = _getColor(title);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 30, end: 0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,

      builder: (context, value, child) {
        return Transform.translate(offset: Offset(0, value), child: child);
      },

      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xfff7f7f7),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),

        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// LEFT CONTENT
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// TITLE + DOT
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),

                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xff2f3542),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  /// SUBTITLE
                  Text(
                    instructor,
                    style: const TextStyle(
                      color: Colors.blueGrey,
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// DURATION CHIP
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      duration,
                      style: TextStyle(
                        color: accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            /// JOIN BUTTON
            ElevatedButton(
              onPressed: onJoin,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 91, 0, 111),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                elevation: 4,
              ),
              child: const Text(
                "Join",
                style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🎨 COLOR MAPPING
  Color _getColor(String title) {
    if (title.contains("Hatha")) return Colors.deepOrange;
    if (title.contains("Pranayama")) return Colors.purple;
    if (title.contains("Meditation")) return Colors.green;
    if (title.contains("Power")) return Colors.orange;
    return Colors.blue;
  }
}
