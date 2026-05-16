import 'package:flutter/material.dart';
import 'package:navyoga_academy/models/class_model.dart';
import 'package:navyoga_academy/models/dashboard_achievemnt_model.dart';
import 'package:navyoga_academy/models/dashboard_action_model.dart';
import 'package:navyoga_academy/models/dashboard_referral_model.dart';
import 'package:navyoga_academy/models/dashboard_stat_model.dart';

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
      id: "1",
      title: "Advanced Hatha Yoga",
      trainer: "Priya Sharma",
      rating: "4.8",
      level: "Advanced",
      duration: "60 min",
      students: "24/30",
      progress: 0.7,
      schedule: "Today at 6:00 PM",
      next: "Now",
      color: Colors.orange,
    ),

    ClassModel(
      id: "2",
      title: "Pranayama Basics",
      trainer: "Rahul Kumar",
      rating: "4.9",
      level: "Beginner",
      duration: "45 min",
      students: "18/25",
      progress: 0.5,
      schedule: "Tomorrow at 7:00 AM",
      next: "Upcoming",
      color: Colors.green,
    ),

    ClassModel(
      id: "3",
      title: "Meditation & Mindfulness",
      trainer: "Anita Verma",
      rating: "5.0",
      level: "All Levels",
      duration: "30 min",
      students: "32/40",
      progress: 0.8,
      schedule: "Mar 12 at 8:00 AM",
      next: "Upcoming",
      color: Colors.purple,
    ),

    ClassModel(
      id: "4",
      title: "Power Yoga Flow",
      trainer: "Vikram Singh",
      rating: "4.7",
      level: "Intermediate",
      duration: "75 min",
      students: "20/25",
      progress: 0.4,
      schedule: "Mar 13 at 6:30 PM",
      next: "Upcoming",
      color: Colors.deepOrange,
    ),
  ];

  static const videos = [
    VideoModel(
      title: "Introduction to Ashtanga",
      trainer: "Priya Sharma",
      duration: "45:30",
      views: "234 views",
      date: "Mar 8",
    ),
    VideoModel(
      title: "Breathing Techniques",
      trainer: "Rahul Kumar",
      duration: "30:15",
      views: "189 views",
      date: "Mar 7",
    ),
    VideoModel(
      title: "Morning Stretch Routine",
      trainer: "Anita Verma",
      duration: "25:00",
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
  static const referrals = [
    ReferralModel(
      value: "12",
      title: "Total Referrals",
      color: Colors.orange,
      status: "Active",
    ),
    ReferralModel(
      value: "₹ 3600",
      title: "Total Earned",
      color: Colors.purple,
      status: "Earned",
    ),
    ReferralModel(
      value: "3/6",
      title: "Achievement Badges",
      color: Colors.orange,
      status: "Unlocked",
    ),
  ];
}
