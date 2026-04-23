import 'package:flutter/material.dart';

Widget sectionHeader(IconData icon, String title, {bool showViewAll = true}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.orange,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: Colors.white),
      ),

      const SizedBox(width: 10),

      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.deepOrange,
            ),
          ),

          /// 👇 SHOW ONLY WHEN NEEDED
          if (showViewAll) ...[
            const SizedBox(height: 4),
            const Text(
              "View All →",
              style: TextStyle(
                color: Colors.deepPurple,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ],
      ),
    ],
  );
}
