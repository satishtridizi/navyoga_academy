import 'package:flutter/material.dart';
import '../models/recording_model.dart';
import '../models/recording_stat_model.dart';

class RecordingsData {
  static List<RecordingStatModel> stats = [
    RecordingStatModel(
      title: "Total Recordings",
      value: "156",
      color: Colors.deepOrange,
      icon: Icons.videocam,
    ),

    RecordingStatModel(
      title: "Completed",
      value: "3",
      color: Colors.green,
      icon: Icons.star,
    ),

    RecordingStatModel(
      title: "Hours Matched",
      value: "5",
      color: Colors.purple,
      icon: Icons.access_time,
    ),

    RecordingStatModel(
      title: "Avg. Attendance",
      value: "23",
      color: Colors.pink,
      icon: Icons.favorite,
    ),
  ];

  static List<RecordingModel> recordings = [
    RecordingModel(
      title: "Introduction to Ashtanga Yoga",
      trainer: "Priya Sharma",
      duration: "45:30",
      views: "234",
      rating: "4.8",
      date: "Mar 8",
      category: "Hatha Yoga",
      color: Colors.deepOrange,
      isCompleted: true,
    ),

    RecordingModel(
      title: "Advanced Breathing",
      trainer: "Rahul Kumar",
      duration: "30:15",
      views: "189",
      rating: "4.9",
      date: "Mar 7",
      category: "Pranayama",
      color: Colors.purple,
      isCompleted: true,
    ),

    RecordingModel(
      title: "Morning Stretch Routine",
      trainer: "Anita Verma",
      duration: "25:00",
      views: "312",
      rating: "5",
      date: "Mar 6, 2026",
      category: "Flexibility",
      color: Colors.green,
      isCompleted: false,
    ),

    RecordingModel(
      title: "Power Yoga for Strength",
      trainer: "Vikram Singh",
      duration: "60:00",
      views: "278",
      rating: "4.7",
      date: "Mar 5, 2026",
      category: "Power Yoga",
      color: Colors.pink,
      isCompleted: false,
    ),

    RecordingModel(
      title: " Meditation for Beginners",
      trainer: " Anita Verma",
      duration: " 20:30",
      views: " 445",
      rating: "4.9",
      date: "Mar 4, 2026",
      category: "Meditation",
      color: Colors.purple,
      isCompleted: true,
    ),

    RecordingModel(
      title: " Restorative Evening Practice",
      trainer: "  Priya Sharma",
      duration: " 40:15",
      views: " 203",
      rating: "4.8",
      date: "Mar 3, 2026",
      category: "Restorative",
      color: Colors.blue,
      isCompleted: false,
    ),

    RecordingModel(
      title: "  Core Strengthening Flow",
      trainer: " Vikram Singh",
      duration: "35:45",
      views: " 267",
      rating: "4.6",
      date: "Mar 2, 2026",
      category: "Power Yoga",
      color: Colors.red,
      isCompleted: false,
    ),

    RecordingModel(
      title: " Yin Yoga Deep Stretch",
      trainer: " Anita Verma",
      duration: "50:00",
      views: " 198",
      rating: "5",
      date: "Mar 1, 2026",
      category: "Yin Yoga",
      color: Colors.orange,
      isCompleted: false,
    ),
  ];
}
