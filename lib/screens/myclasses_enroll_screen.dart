import 'package:flutter/material.dart';
import 'package:navyoga_academy/models/class_model.dart';
import 'package:navyoga_academy/routes/app_routes.dart';
import 'package:navyoga_academy/widgets/animatedItem.dart';
import 'package:navyoga_academy/services/enrollment_service.dart';
import 'package:navyoga_academy/widgets/app_scaffold.dart';

class EnrollScreen extends StatelessWidget {
  const EnrollScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final classData = ModalRoute.of(context)!.settings.arguments as ClassModel;

    return AppScaffold(
      currentIndex: 0,


      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        title: const Text(
          "Enroll Class",
          style: TextStyle(
            color: Colors.deepOrange,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            AnimatedItem(
              index: 0,

              child: Container(
                padding: const EdgeInsets.all(22),

                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      classData.color.withOpacity(0.15),
                      classData.color.withOpacity(0.05),
                    ],
                  ),

                  borderRadius: BorderRadius.circular(28),

                  boxShadow: [
                    BoxShadow(
                      color: classData.color.withOpacity(0.15),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      classData.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      classData.trainer,
                      style: const TextStyle(color: Colors.blueGrey),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        _chip(classData.level),
                        const SizedBox(width: 10),
                        _chip(classData.duration),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            AnimatedItem(
              index: 1,

              child: const Text(
                "Confirm Enrollment",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange,
                ),
              ),
            ),

            const SizedBox(height: 14),

            AnimatedItem(
              index: 2,

              child: const Text(
                "By enrolling, you will gain access to live sessions, recordings, attendance tracking, and instructor guidance.",
                style: TextStyle(color: Colors.blueGrey, height: 1.6),
              ),
            ),

            const SizedBox(height: 40),

            AnimatedItem(
              index: 3,

              child: SizedBox(
                width: double.infinity,

                child: ElevatedButton.icon(
                  onPressed: () {
                    final alreadyEnrolled = EnrollmentService.enrolledClasses
                        .any((e) => e.title == classData.title);

                    if (!alreadyEnrolled) {
                      EnrollmentService.enrolledClasses.add(classData);
                    }

                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.myClasses,
                      (route) => false,
                    );
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    elevation: 6,

                    padding: const EdgeInsets.symmetric(vertical: 18),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),

                  icon: const Icon(Icons.check_circle),

                  label: const Text(
                    "Confirm Enrollment",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),

      decoration: BoxDecoration(
        color: Colors.deepOrange.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),

      child: Text(
        text,
        style: const TextStyle(
          color: Colors.deepOrange,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
