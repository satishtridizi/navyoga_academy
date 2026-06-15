import 'package:flutter/material.dart';
import 'package:navyoga_academy/models/class_model.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/live_enrollment_model.dart';
import '../routes/app_routes.dart';

class LiveEnrollmentCard extends StatelessWidget {
  final LiveEnrollmentModel enrollment;

  const LiveEnrollmentCard({super.key, required this.enrollment});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.live_tv, color: Colors.grey, size: 28),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  enrollment.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  enrollment.yogaType,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRoutes.liveClass,
                arguments: ClassModel(
                  description: "",
                  video: "",
                  thumbnail: "",
                  durationMinutes: 60,
                  id: enrollment.id,
                  title: enrollment.title,
                  trainer: enrollment.trainer,
                  rating: "0",
                  level: enrollment.level,
                  duration: enrollment.duration.toString(),
                  students: "0",
                  progress: 0.0,
                  schedule: "",
                  next: "",
                  color: Colors.deepPurple,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              shape: const StadiumBorder(),
            ),
            child: const Text("Join", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
