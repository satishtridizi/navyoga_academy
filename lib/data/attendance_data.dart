import 'package:flutter/material.dart';
import '../models/attendance_stat_model.dart';
import '../models/detail_model.dart';
import '../models/progress_model.dart';
import '../models/insight_model.dart';

class AttendanceData {

  static const List<AttendanceStatModel> stats = [
    AttendanceStatModel(
      title: "Total Classes",
      value: "124",
      icon: Icons.calendar_today,
      color: Colors.orange,
    ),

    AttendanceStatModel(
      title: "Classes Attended",
      value: "114",
      icon: Icons.check,
      color: Colors.teal,
    ),

    AttendanceStatModel(
      title: "Classes Missed",
      value: "10",
      icon: Icons.close,
      color: Colors.red,
    ),

    AttendanceStatModel(
      title: "Attendance Rate",
      value: "92%",
      icon: Icons.trending_up,
      color: Colors.deepPurple,
    ),
  ];


  static const List<DetailModel> details = [
    DetailModel(
      title: "Total Time This Month",
      value: "52h 30m",
      subtitle: "+8h from last month",
      icon: Icons.timer,
      color: Colors.orange,
    ),
  ];


  static const List<InsightModel> insights = [
    InsightModel(
      title: "Average Per Day",
      value: "1h 45m",
      unit: "",
      subtitle: "Last 30 days",
      extra: "",
      icon: Icons.access_time,
      color: Colors.teal,
      type: "simple",
    ),

    InsightModel(
      title: "Current Streak",
      value: "12",
      unit: "days",
      subtitle: "Personal best: 18 days",
      extra: "",
      icon: Icons.local_fire_department,
      color: Colors.orange,
      type: "simple",
    ),

    InsightModel(
      title: "Monthly Goal",
      value: "85%",
      unit: "",
      subtitle: "51h of 60h target",
      extra: "",
      icon: Icons.gps_fixed,
      color: Colors.deepPurple,
      type: "simple",
    ),
  ];


  static const List<ProgressModel> monthly = [
    ProgressModel(
      title: "January",
      sub1: "50h 0m",
      sub2: "28/30 classes",
      progress: 0.93,
    ),

    ProgressModel(
      title: "February",
      sub1: "48h 0m",
      sub2: "26/28 classes",
      progress: 0.93,
    ),

    ProgressModel(
      title: "March",
      sub1: "52h 30m",
      sub2: "10/11 classes",
      progress: 0.91,
    ),
  ];


  static const List<ProgressModel> classWise = [
    ProgressModel(
      title: "Advanced Hatha Yoga",
      sub1: "18h 0m",
      sub2: "12/14",
      progress: 0.86,
    ),

    ProgressModel(
      title: "Pranayama Basics",
      sub1: "10h 0m",
      sub2: "10/10",
      progress: 1.00,
    ),

    ProgressModel(
      title: "Meditation & Mindfulness",
      sub1: "8h 0m",
      sub2: "18/20",
      progress: 0.90,
    ),

    ProgressModel(
      title: "Power Yoga Flow",
      sub1: "12h 0m",
      sub2: "8/10",
      progress: 0.80,
    ),

    ProgressModel(
      title: "Restorative Yoga",
      sub1: "4h 30m",
      sub2: "15/16",
      progress: 0.94,
    ),
  ];
  static const InsightModel practiceStreak = InsightModel(
    title: "Practice Streak",
    value: "12",
    unit: "days",
    subtitle: "You're on a roll!\nKeep practicing daily.",
    extra: "Personal Best: 18 days",
    icon: Icons.local_fire_department,
    color: Colors.deepOrange,
    type: "streak",
  );
  static const InsightModel goalProgress = InsightModel(
    title: "Monthly Goal Progress",
    value: "85%",
    unit: "",
    subtitle: "51 hours of 60 hours target",
    extra: "9 hours remaining",
    icon: Icons.gps_fixed,
    color: Colors.green,
    type: "progress",
  );

  static const InsightModel excellentAttendance = InsightModel(
    title: "Excellent Attendance!",
    value: "92%",
    unit: "",
    subtitle:
        "You've maintained a 92% attendance rate with 52.5 hours of practice this month. Keep up the great work!",
    extra: "",
    icon: Icons.workspace_premium,
    color: Colors.teal,
    type: "achievement",
  );
}
