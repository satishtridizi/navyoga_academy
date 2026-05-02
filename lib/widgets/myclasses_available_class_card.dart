import 'package:flutter/material.dart';
import 'package:navyoga_academy/models/class_model.dart';
import '../routes/app_routes.dart';

class AvailableClassCard extends StatelessWidget {
  final ClassModel data;

  const AvailableClassCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final Color mainColor = data.color;

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),

        /// 🔥 TOP BORDER COLOR (IMPORTANT)
        border: Border(top: BorderSide(color: mainColor, width: 5)),

        boxShadow: [
          BoxShadow(
            color: mainColor.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// TITLE
          Text(
            data.title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 6),

          /// TRAINER
          Text(data.trainer, style: const TextStyle(color: Colors.blueGrey)),

          const SizedBox(height: 12),

          /// TAGS
          Wrap(
            spacing: 8,
            children: [
              chip(data.level, mainColor.withOpacity(0.15), mainColor),
              chip("⏱ ${data.duration}", Colors.grey.shade200, Colors.black),
            ],
          ),

          const SizedBox(height: 12),

          /// SCHEDULE
          Text(data.schedule, style: const TextStyle(color: Colors.blueGrey)),

          const SizedBox(height: 12),

          /// RATING + STUDENTS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              chip("⭐ ${data.rating}", Colors.yellow.shade100, Colors.black),
              chip("👥 ${data.students}", Colors.grey.shade200, Colors.black),
            ],
          ),

          const SizedBox(height: 16),

          /// ENROLL BUTTON
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.enrollClass,
                  arguments: data,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 6,
              ),
              icon: const Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 18,
              ),
              label: const Text(
                "Enroll Now",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget chip(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: TextStyle(color: fg)),
    );
  }
}
