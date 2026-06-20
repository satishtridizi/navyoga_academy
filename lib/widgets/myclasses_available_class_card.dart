import 'package:flutter/material.dart';
import 'package:navyoga_academy/models/live_enrollment_model.dart';
import '../routes/app_routes.dart';
import 'package:navyoga_academy/services/enrollment_service.dart';

class AvailableClassCard extends StatelessWidget {
  final LiveEnrollmentModel data;

  const AvailableClassCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    const bool isEnrolled = true;
    const Color mainColor = Colors.deepOrange;
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

          const SizedBox(height: 16),

          /// ENROLL BUTTON
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.enrollmentsuccess,
                  arguments: data,
                );
              },

              style: ElevatedButton.styleFrom(
                backgroundColor: isEnrolled ? Colors.green : Colors.deepOrange,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 6,
              ),

              icon: Icon(
                isEnrolled ? Icons.check_circle : Icons.auto_awesome,
                color: Colors.white,
                size: 18,
              ),

              label: Text(
                isEnrolled ? "Watch Class" : "Enroll Now",
                style: const TextStyle(
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
