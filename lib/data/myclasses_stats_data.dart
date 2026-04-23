import 'package:flutter/material.dart';
import '../models/myclasses_stats_model.dart';

List<StatsModel> statsData = [
  StatsModel(
    title: "Enrolled Classes",
    value: "8",
    color: Colors.deepOrange,
    icon: Icons.menu_book,
  ),

  StatsModel(
    title: "Completed",
    value: "3",
    color: Colors.green,
    icon: Icons.star,
  ),
  StatsModel(
    title: "In Progress",
    value: "5",
    color: Colors.purple,
    icon: Icons.access_time,
  ),
  StatsModel(
    title: "Avg. Attendance",
    value: "92%",
    color: Colors.orange,
    icon: Icons.calendar_today,
  ),
];
