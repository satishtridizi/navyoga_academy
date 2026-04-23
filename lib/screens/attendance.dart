import 'package:flutter/material.dart';
import 'package:navyoga_academy/Dashboard/dashboard_menu.dart';
import 'package:navyoga_academy/data/attendance_data.dart';
import 'package:navyoga_academy/widgets/attendance_stat_card.dart';
import 'package:navyoga_academy/widgets/attandance_detail_card.dart';
import 'package:navyoga_academy/widgets/attandance_insight_card.dart';
import 'package:navyoga_academy/widgets/attandance_progress_row.dart';
import 'package:navyoga_academy/widgets/attandance_class_progress_row.dart';
import 'package:navyoga_academy/widgets/attandance_section_card.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      backgroundColor: const Color(0xffF7F7F7),

      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),

            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        title: const Text(
          "NavYoga Academy",
          style: TextStyle(color: Colors.deepOrange),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          /// HEADER
          const Text(
            "My Attendance &\nTime Tracking",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.deepOrange,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            "Track your class attendance, practice time, and progress metrics",
            style: TextStyle(color: Colors.blueGrey),
          ),

          const SizedBox(height: 20),

          /// STATS GRID
          _buildStatsGrid(),

          const SizedBox(height: 20),

          /// DETAILS
          ...AttendanceData.details.map((e) => DetailCard(e)),

          const SizedBox(height: 6),

          /// INSIGHTS (top)
          ...AttendanceData.insights.map((e) => InsightCard(data: e)),

          const SizedBox(height: 20),

          /// MONTHLY
          _buildSection(
            "Monthly Statistics",
            AttendanceData.monthly.map((e) => ProgressRow(e)).toList(),
          ),

          const SizedBox(height: 20),

          /// CLASS-WISE
          _buildSection(
            "Class-wise Time & Attendance",
            AttendanceData.classWise.map((e) => ClassProgressRow(e)).toList(),
          ),

          const SizedBox(height: 20),

          /// EXTRA INSIGHTS
          InsightCard(data: AttendanceData.practiceStreak),
          const SizedBox(height: 20),

          InsightCard(data: AttendanceData.goalProgress),
          const SizedBox(height: 20),

          InsightCard(data: AttendanceData.excellentAttendance),
        ],
      ),
    );
  }

  /// 🔹 Reusable grid
  Widget _buildStatsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: AttendanceData.stats.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.25,
      ),
      itemBuilder: (_, i) => StatCard(AttendanceData.stats[i]),
    );
  }

  /// 🔹 Reusable section
  Widget _buildSection(String title, List<Widget> children) {
    return SectionCard(title: title, children: children);
  }
}
