import 'package:flutter/material.dart';
import 'package:navyoga_academy/Dashboard/dashboard_menu.dart';
import 'package:navyoga_academy/data/attendance_data.dart';
import 'package:navyoga_academy/widgets/app_background.dart';
import 'package:navyoga_academy/widgets/attendance_stat_card.dart';
import 'package:navyoga_academy/widgets/attandance_detail_card.dart';
import 'package:navyoga_academy/widgets/attandance_insight_card.dart';
import 'package:navyoga_academy/widgets/attandance_progress_row.dart';
import 'package:navyoga_academy/widgets/attandance_class_progress_row.dart';
import 'package:navyoga_academy/widgets/attandance_section_card.dart';
import 'package:navyoga_academy/widgets/animatedItem.dart';
import 'package:navyoga_academy/widgets/app_background.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      backgroundColor: Colors.transparent,

      body: AppBackground(
        child: CustomScrollView(
          physics: const ClampingScrollPhysics(),
          slivers: [
            SliverAppBar(
              floating: true,
              snap: true,
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

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// HEADER
                    AnimatedItem(
                      index: 0,
                      child: const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "My Attendance &\nTime Tracking",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepOrange,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),

                    AnimatedItem(
                      index: 1,
                      child: const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Track your class attendance, practice time, and progress metrics",
                          style: TextStyle(color: Colors.blueGrey),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// STATS GRID
                    _buildStatsGrid(),

                    const SizedBox(height: 20),

                    /// DETAILS
                    ...AttendanceData.details.asMap().entries.map((entry) {
                      final index = entry.key;
                      final e = entry.value;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: AnimatedItem(
                          index: index + 2,
                          child: DetailCard(e),
                        ),
                      );
                    }),

                    const SizedBox(height: 6),

                    /// INSIGHTS (top)
                    ...AttendanceData.insights.asMap().entries.map((entry) {
                      final index = entry.key;
                      final e = entry.value;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: AnimatedItem(
                          index: index + 5,
                          child: InsightCard(data: e),
                        ),
                      );
                    }),

                    const SizedBox(height: 20),

                    /// MONTHLY
                    AnimatedItem(
                      index: 8,
                      child: _buildSection(
                        "Monthly Statistics",
                        AttendanceData.monthly
                            .map((e) => ProgressRow(e))
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    /// CLASS-WISE
                    AnimatedItem(
                      index: 9,
                      child: _buildSection(
                        "Class-wise Time & Attendance",
                        AttendanceData.classWise
                            .map((e) => ClassProgressRow(e))
                            .toList(),
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// EXTRA INSIGHTS
                    AnimatedItem(
                      index: 10,
                      child: InsightCard(data: AttendanceData.practiceStreak),
                    ),
                    const SizedBox(height: 20),

                    AnimatedItem(
                      index: 11,
                      child: InsightCard(data: AttendanceData.goalProgress),
                    ),
                    const SizedBox(height: 20),

                    AnimatedItem(
                      index: 12,
                      child: InsightCard(
                        data: AttendanceData.excellentAttendance,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
      itemBuilder: (_, i) =>
          AnimatedItem(index: i + 2, child: StatCard(AttendanceData.stats[i])),
    );
  }

  /// 🔹 Reusable section
  Widget _buildSection(String title, List<Widget> children) {
    return SectionCard(title: title, children: children);
  }
}
