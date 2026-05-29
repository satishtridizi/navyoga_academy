import 'package:flutter/material.dart';
import '../models/live_enrollment_model.dart';

class LiveEnrollmentCard extends StatelessWidget {
  final LiveEnrollmentModel enrollment;

  const LiveEnrollmentCard({super.key, required this.enrollment});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      child: ListTile(
        title: Text(enrollment.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Plan: ${enrollment.planName}"),
            Text("Status: ${enrollment.status}"),
            Text("Yoga Type: ${enrollment.yogaType}"),
            Text("Level: ${enrollment.level}"),
          ],
        ),
      ),
    );
  }
}
