import 'package:flutter/material.dart';
import 'package:navyoga_academy/models/achievement_model.dart';
import 'package:navyoga_academy/models/goal_model.dart';
import 'package:navyoga_academy/models/profile_field_model.dart';
import '../models/profile_stat_model.dart';

class ProfileData {
  static const stats = [
    ProfileStat(
      title: 'Member Since',
      value: '—',
      icon: Icons.menu_book,
      color: Colors.deepOrange,
    ),
    ProfileStat(
      title: 'Total Classes',
      value: '—',
      icon: Icons.track_changes,
      color: Colors.purple,
    ),
    ProfileStat(
      title: 'Achievements',
      value: '—',
      icon: Icons.emoji_events,
      color: Colors.green,
    ),
    ProfileStat(
      title: 'Skill Level',
      value: '—',
      icon: Icons.trending_up,
      color: Colors.amber,
    ),
  ];

  static List<ProfileFieldModel> personalInfo = [
    ProfileFieldModel(
      label: 'Full Name',
      value: '',
      helperText: 'Enter your full name',
    ),
    ProfileFieldModel(
      label: 'Email Address',
      value: '',
      icon: Icons.email_outlined,
      helperText: 'Enter your email address',
    ),
    ProfileFieldModel(
      label: 'Phone Number',
      value: '',
      icon: Icons.phone_outlined,
      helperText: 'Enter your phone number',
    ),
    ProfileFieldModel(
      label: 'City',
      value: '',
      icon: Icons.location_city_outlined,
      helperText: 'Enter your city',
    ),
    ProfileFieldModel(
      label: 'Country',
      value: '',
      icon: Icons.public,
      helperText: 'Enter your country',
    ),
  ];

  static List<ProfileFieldModel> medicalInfo = [
    ProfileFieldModel(
      label: 'Age',
      value: '',
      helperText: 'Enter your age',
    ),
    ProfileFieldModel(
      label: 'Blood Group',
      value: '',
      helperText: 'Enter your blood group',
    ),
    ProfileFieldModel(
      label: 'Emergency Contact',
      value: '',
      icon: Icons.phone_outlined,
      helperText: 'Enter emergency contact number',
    ),
    ProfileFieldModel(
      label: 'Medical Conditions',
      value: '',
      isMultiline: true,
      helperText: 'List medical conditions or allergies',
    ),
  ];

  static List<ProfileFieldModel> preferences = [
    ProfileFieldModel(
      label: 'Yoga Experience',
      value: '',
      helperText: 'Example: 2 years',
    ),
    ProfileFieldModel(
      label: 'Current Level',
      value: '',
      helperText: 'Beginner, Intermediate or Advanced',
    ),
    ProfileFieldModel(
      label: 'Areas of Interest',
      value: '',
      isMultiline: true,
      helperText: 'Hatha, Vinyasa, Pranayama, etc.',
    ),
  ];

  static List<AchievementModel> achievements = [];
  static List<GoalModel> goals = [];
}
