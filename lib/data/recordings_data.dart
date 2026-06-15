import 'package:flutter/material.dart';
import 'package:navyoga_academy/models/recording_model.dart';
import 'package:navyoga_academy/models/recording_stat_model.dart';
import 'package:navyoga_academy/routes/app_routes.dart';

class RecordingsData {
  static List<RecordingModel> recordings = [];

  static List<RecordingStatModel> get stats {
    final totalRecordings = recordings.length;

    final completed = recordings.where((e) => e.isCompleted).length;

    final totalMinutes = recordings.fold<int>(0, (sum, e) {
      final parts = e.duration.split(":");

      if (parts.length == 2) {
        return sum + int.parse(parts[0]);
      }

      return sum;
    });

    final totalHours = (totalMinutes / 60).toStringAsFixed(1);

    return [
      RecordingStatModel(
        title: "Total Recordings",
        value: totalRecordings.toString(),
        color: Colors.deepOrange,
        icon: Icons.videocam,
      ),

      RecordingStatModel(
        title: "Completed",
        value: completed.toString(),
        color: Colors.green,
        icon: Icons.star,
      ),

      RecordingStatModel(
        title: "Hours Watched",
        value: totalHours,
        color: Colors.purple,
        icon: Icons.access_time,
      ),

      RecordingStatModel(
        title: "Avg. Attendance",
        value: "N/A",
        color: Colors.pink,
        icon: Icons.favorite,
        route: AppRoutes.attendance,
      ),
    ];
  }
}
