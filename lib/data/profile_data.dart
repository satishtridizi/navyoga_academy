import 'package:flutter/material.dart';
import 'package:navyoga_academy/models/achievement_model.dart';
import 'package:navyoga_academy/models/goal_model.dart';
import 'package:navyoga_academy/models/profile_field_model.dart';
import '../models/profile_stat_model.dart';

class ProfileData {
  /// 📊 STATS (keep as is)
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

  /// 👤 PERSONAL INFO (dynamic + safe structure)
  static List<ProfileFieldModel> personalInfo = [
    ProfileFieldModel(
      label: "Full Name",
      value: "",
      helperText: "Enter your full name",
    ),
    ProfileFieldModel(
      label: "Email Address",
      value: "",
      icon: Icons.email_outlined,
      helperText: "Enter your email address",
    ),
    ProfileFieldModel(
      label: "Phone Number",
      value: "",
      icon: Icons.phone_outlined,
      helperText: "Enter your phone number",
    ),
    ProfileFieldModel(
      label: "Address",
      value: "",
      icon: Icons.location_on_outlined,
      isMultiline: true,
      helperText: "Enter your address",
    ),
  ];

  /// 🏆 ACHIEVEMENTS (keep model type)
  static List<AchievementModel> achievements = [
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
      subtitle: "Completed 20 sessions",
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

  /// 🎯 GOALS (keep model type)
  static List<GoalModel> goals = [
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

  /// 🏥 MEDICAL INFO (ADD THIS)
  static List<ProfileFieldModel> medicalInfo = [
    ProfileFieldModel(label: "Age", value: "", helperText: "Enter your age"),
    ProfileFieldModel(
      label: "Blood Group",
      value: "",
      helperText: "Enter your blood group (e.g. O+)",
    ),
    ProfileFieldModel(
      label: "Emergency Contact",
      value: "",
      icon: Icons.phone_outlined,
      helperText: "Enter emergency contact number",
    ),
    ProfileFieldModel(
      label: "Medical Conditions (if any)",
      value: "",
      isMultiline: true,
      helperText: "List any medical conditions or allergies",
    ),
  ];

  /// ⚙️ PREFERENCES (convert to model — not Map)
  static List<ProfileFieldModel> preferences = [
    ProfileFieldModel(
      label: "Yoga Experience",
      value: "2 years",
      helperText: "Enter your yoga experience",
    ),
    ProfileFieldModel(
      label: "Current Level",
      value: "Intermediate",
      helperText: "Select your level",
    ),
    ProfileFieldModel(
      label: "Areas of Interest",
      value: "Hatha, Vinyasa, Pranayama, etc.",
      isMultiline: true,
      helperText: "Enter your interests",
    ),
    ProfileFieldModel(
      label: "Fitness Goals",
      value: "",
      isMultiline: true,
      helperText: "What do you want to achieve?",
    ),
  ];
}
