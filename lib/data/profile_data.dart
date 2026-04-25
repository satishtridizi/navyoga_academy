import 'package:flutter/material.dart';
import 'package:navyoga_academy/models/achievement_model.dart';
import 'package:navyoga_academy/models/goal_model.dart';
import '../models/profile_stat_model.dart';

class ProfileData {
  static const stats = [
    ProfileStat(
      title: "Member Since",
      value: "Jan 2025",
      icon: Icons.menu_book,
      color: Colors.deepOrange,
    ),
    ProfileStat(
      title: "Total Classes",
      value: "124",
      icon: Icons.track_changes,
      color: Colors.purple,
    ),
    ProfileStat(
      title: "Achievements",
      value: "12",
      icon: Icons.emoji_events,
      color: Colors.green,
    ),
    ProfileStat(
      title: "Skill Level",
      value: "Intermediate",
      icon: Icons.trending_up,
      color: Colors.amber,
    ),
  ];
  static const personalInfo = [
    {"label": "Full Name", "value": "Rajesh Kumar"},
    {
      "label": "Email Address",
      "value": "rajesh.kumar@email.com",
      "icon": Icons.email_outlined,
    },
    {
      "label": "Phone Number",
      "value": "+91 98765 43210",
      "icon": Icons.phone_outlined,
    },
    {
      "label": "Address",
      "value": "Enter your address",
      "icon": Icons.location_on_outlined,
      "isMultiline": true,
    },
  ];

  static const achievements = [
    AchievementModel(
      emoji: "🔥",
      title: "30-Day Streak",
      subtitle: "Attended classes for 30 consecutive days",
      date: "Earned on Mar 1, 2026",
    ),
    AchievementModel(
      emoji: "🌅",
      title: "Early Bird",
      subtitle: "Attended 10 morning classes",
      date: "Earned on Feb 15, 2026",
    ),
    AchievementModel(
      emoji: "🧘",
      title: "Meditation Master",
      subtitle: "Completed 20 meditation sessions",
      date: "Earned on Feb 28, 2026",
    ),
    AchievementModel(
      emoji: "💪",
      title: "Flexible Warrior",
      subtitle: "Achieved advanced flexibility poses",
      date: "Earned on Jan 20, 2026",
    ),
    AchievementModel(
      emoji: "⚡",
      title: "Power House",
      subtitle: "Completed 15 power yoga sessions",
      date: "Earned on Feb 10, 2026",
    ),
    AchievementModel(
      emoji: "🌬",
      title: "Breath Master",
      subtitle: "Mastered 10 pranayama techniques",
      date: "Earned on Jan 30, 2026",
    ),
  ];
  static const goals = [
    GoalModel(
      title: "Improve Flexibility",
      progress: 0.75,
      subtitle: "Achieve full splits by June 2026",
    ),
    GoalModel(
      title: "Build Core Strength",
      progress: 0.60,
      subtitle: "Hold plank for 5 minutes",
    ),
    GoalModel(
      title: "Master Meditation",
      progress: 0.85,
      subtitle: "30 minutes daily meditation",
    ),
    GoalModel(
      title: "Weight Management",
      progress: 0.45,
      subtitle: "Reach ideal body weight",
    ),
  ];
  static const medicalInfo = [
    {"label": "Age", "value": "32"},
    {"label": "Blood Group", "value": "O+"},
    {"label": "Emergency Contact", "value": "+91 98765 12345"},
    {
      "label": "Medical Conditions (if any)",
      "value": "List any medical conditions or allergies",
      "isMultiline": true,
    },
  ];

  static const preferences = [
    {"label": "Yoga Experience", "value": "2 years"},
    {"label": "Current Level", "value": "Intermediate"},
    {
      "label": "Areas of Interest",
      "value": "Hatha, Vinyasa, Pranayama, etc.",
      "isMultiline": true,
    },
    {
      "label": "Fitness Goals",
      "value": "What do you want to achieve?",
      "isMultiline": true,
    },
  ];
}
