import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:navyoga_academy/Dashboard/dashboard_menu.dart';
import 'package:navyoga_academy/data/attendance_data.dart';
import 'package:navyoga_academy/models/attendance_stat_model.dart';
import 'package:navyoga_academy/widgets/app_scaffold.dart';
import 'package:navyoga_academy/widgets/attendance_stat_card.dart';
import 'package:navyoga_academy/widgets/attandance_detail_card.dart';
import 'package:navyoga_academy/widgets/attandance_insight_card.dart';
import 'package:navyoga_academy/widgets/attandance_progress_row.dart';
import 'package:navyoga_academy/widgets/attandance_class_progress_row.dart';
import 'package:navyoga_academy/widgets/attandance_section_card.dart';
import 'package:navyoga_academy/widgets/animatedItem.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:navyoga_academy/models/attendance_api_model.dart';
import 'package:navyoga_academy/services/attendance_service.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final attendanceService = AttendanceService();

  AttendanceApiModel? attendance;

  @override
  void initState() {
    super.initState();
    loadAttendance();
  }

  Future<void> loadAttendance() async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString("token");

    final response = await attendanceService.getAttendance(token!);

    final attendanceData = AttendanceApiModel.fromJson(response["data"]);

    setState(() {
      attendance = attendanceData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentIndex: 3,
      drawer: const CustomDrawer(),

      //backgroundColor: Colors.transparent,
      body: CustomScrollView(
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
              style: TextStyle(
                color: Colors.deepOrange,
                fontWeight: FontWeight.bold,
              ),
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
                          fontSize: 33,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),

                  AnimatedItem(
                    index: 1,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Track your class attendance, practice time, and progress metrics",
                        style: GoogleFonts.poppins(
                          fontSize: 17,
                          color: Colors.black87,
                        ),
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
    );
  }

  /// 🔹 Reusable grid
  Widget _buildStatsGrid() {
    final stats = [
      AttendanceStatModel(
        title: "Attendance Rate",
        value: "${attendance?.attendanceRate ?? 0}%",
        icon: Icons.trending_up,
        color: Colors.orange,
      ),

      AttendanceStatModel(
        title: "Classes Attended",
        value: "${attendance?.classesAttended ?? 0}",
        icon: Icons.check_circle,
        color: Colors.green,
      ),

      AttendanceStatModel(
        title: "Missed Classes",
        value: "${attendance?.missedClasses ?? 0}",
        icon: Icons.cancel,
        color: Colors.red,
      ),

      AttendanceStatModel(
        title: "Current Streak",
        value: "${attendance?.streak ?? 0}",
        icon: Icons.local_fire_department,
        color: Colors.deepPurple,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),

      itemCount: stats.length,

      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.25,
      ),

      itemBuilder: (_, i) =>
          AnimatedItem(index: i + 2, child: StatCard(stats[i])),
    );
  }

  /// 🔹 Reusable section
  Widget _buildSection(String title, List<Widget> children) {
    return SectionCard(title: title, children: children);
  }
}
