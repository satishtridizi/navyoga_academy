import 'package:flutter/material.dart';
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
  ];

  static const classes = [
    ClassModel(
      title: "Advanced Hatha Yoga",
      subtitle: "Priya Sharma • Today at 6:00 PM",
      duration: "60 min",
    ),
  ];

  static const videos = [
    VideoModel(
      title: "Introduction to Ashtanga",
      subtitle: "Priya Sharma • 45:30",
      views: "234 views",
      date: "Mar 8",
    ),
  ];
}
