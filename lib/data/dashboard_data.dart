import 'package:flutter/material.dart';
import 'package:navyoga_academy/models/dashboard_achievemnt_model.dart';
import 'package:navyoga_academy/models/dashboard_action_model.dart';
import 'package:navyoga_academy/models/dashboard_stat_model.dart';
import 'package:navyoga_academy/models/dashboard_class_model.dart';
import 'package:navyoga_academy/models/dashboard_video_model.dart';

class HomeData {
  static const stats = [
    StatModel(
      title: "Enrolled Classes",
      value: "8",
      subtitle: "+2 this month",
      color: Colors.deepOrange,
    ),

    StatModel(
      title: "Hours Completed",
      value: "124",
      subtitle: "+18 this week",
      color: Colors.purple,
    ),
    StatModel(
      title: "Recordings Watched",
      value: "45",
      subtitle: "+8 this week",
      color: Colors.green,
    ),
    StatModel(
      title: "Attendance Rate",
      value: "92",
      subtitle: "+5 this week",
      color: Colors.orange,
    ),
  ];

  static const classes = [
    ClassModel(
      title: "Advanced Hatha Yoga",
      subtitle: "Priya Sharma • Today at 6:00 PM",
      duration: "60 min",
    ),
    ClassModel(
      title: "Advanced Hatha Yoga",
      subtitle: "Priya Sharma • Today at 6:00 PM",
      duration: "60 min",
    ),
    ClassModel(
      title: "Meditation and Mindfulness",
      subtitle: "Anita Verma • March 12",
      duration: "30 min",
    ),
    ClassModel(
      title: "Power Yoga Flow",
      subtitle: "Vikram Singh • March 13",
      duration: "75 min",
    ),
  ];

  static const videos = [
    VideoModel(
      title: "Introduction to Ashtanga",
      subtitle: "Priya Sharma • 45:30",
      views: "234 views",
      date: "Mar 8",
    ),
    VideoModel(
      title: "Breathing Techniques",
      subtitle: "Rahul Kumar • 30:15",
      views: "189 views",
      date: "Mar 7",
    ),
    VideoModel(
      title: "Morning Stretch Routine",
      subtitle: "Anita Verma • 25:00",
      views: "312 views",
      date: "Mar 6",
    ),
  ];
  static final achievements = [
    AchievementData(
      title: "30-Day Streak",
      subtitle: "Attended classes for 30 days",
      color: Colors.orange,
      earned: true,
    ),
    AchievementData(
      title: "Early Bird",
      subtitle: "Attended 10 morning classes",
      color: Colors.green,
      earned: true,
    ),
    AchievementData(
      title: "Meditation Master",
      subtitle: "Completed 20 sessions",
      color: const Color.fromARGB(255, 192, 191, 191),
      earned: true,
    ),
  ];
  static final actions = [
    ActionData(
      title: "Browse Classes",
      subtitle: "Explore courses",
      color: Colors.deepOrange,
    ),
    ActionData(
      title: "Self Paced",
      subtitle: "Learn at your pace",
      color: Colors.deepPurple,
    ),
    ActionData(
      title: "Watch Recordings",
      subtitle: "Catch up on sessions",
      color: Colors.pink,
    ),
    ActionData(
      title: "View Attendanced",
      subtitle: "Track your progress",
      color: Colors.green,
    ),
    ActionData(
      title: "My Profile",
      subtitle: "Update your details",
      color: Colors.orange,
    ),
  ];
}
