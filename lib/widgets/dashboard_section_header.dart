import 'package:flutter/material.dart';

Widget sectionHeader(
  IconData icon,
  String title, {
  bool showViewAll = true,
  VoidCallback? onViewAllTap,
  String viewAllText = "View All →",
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
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

          if (showViewAll)
            GestureDetector(
              onTap: onViewAllTap,
              child: Text(
                viewAllText,
                style: const TextStyle(
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ),
        ],
      ),
    ],
  );
}
