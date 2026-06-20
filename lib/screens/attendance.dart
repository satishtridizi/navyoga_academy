import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:navyoga_academy/Dashboard/dashboard_menu.dart';

import 'package:navyoga_academy/models/ClassWiseStatModel.dart';
import 'package:navyoga_academy/models/MonthlyStatModel.dart';
import 'package:navyoga_academy/models/attendance_stat_model.dart';
import 'package:navyoga_academy/models/detail_model.dart';
import 'package:navyoga_academy/models/insight_model.dart';
import 'package:navyoga_academy/models/progress_model.dart';
import 'package:navyoga_academy/utils/auth_manager.dart';
import 'package:navyoga_academy/widgets/app_scaffold.dart';
import 'package:navyoga_academy/widgets/attendance_stat_card.dart';
import 'package:navyoga_academy/widgets/attandance_detail_card.dart';
import 'package:navyoga_academy/widgets/attandance_insight_card.dart';
import 'package:navyoga_academy/widgets/attandance_progress_row.dart';
import 'package:navyoga_academy/widgets/attandance_class_progress_row.dart';
import 'package:navyoga_academy/widgets/attandance_section_card.dart';
import 'package:navyoga_academy/widgets/animatedItem.dart';
import 'package:navyoga_academy/models/attendance_api_model.dart';
import 'package:navyoga_academy/services/attendance_service.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  String formatMinutes(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;

    return "${hours}h ${mins}m";
  }

  final attendanceService = AttendanceService();

  AttendanceApiModel? attendance;
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    loadAttendance();
  }

  Future<void> loadAttendance() async {
    setState(() {
      isLoading = true;
    });

    final token = await AuthManager.getToken();

    if (token == null) {
      Navigator.pushReplacementNamed(context, "/login");
      return;
    }

    final attendanceList = await attendanceService.getAttendance(token);

    if (!mounted) return;

    if (attendanceList.isEmpty) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    int total = attendanceList.length;

    int present = attendanceList.where((e) => e["status"] == "PRESENT").length;

    int absent = attendanceList.where((e) => e["status"] == "ABSENT").length;

    int attendanceRate = total == 0 ? 0 : ((present / total) * 100).toInt();

    setState(() {
      attendance = AttendanceApiModel(
        attendanceRate: attendanceRate,
        classesAttended: present,
        missedClasses: absent,
        streak: null,
        totalMinutesThisMonth: null,
        previousMonthMinutes: null,
        monthlyGoalMinutes: null,
        monthlyStats: [],

        classWiseStats: [],
      );

      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final avgMinutes =
        (attendance?.totalMinutesThisMonth ?? 0) ~/
        (DateTime.now().day == 0 ? 1 : DateTime.now().day);

    final goalPercentage =
        ((attendance?.totalMinutesThisMonth ?? 0) /
            ((attendance?.monthlyGoalMinutes ?? 1))) *
        100;

    return AppScaffold(
      currentIndex: 3,
      drawer: const CustomDrawer(currentPage: "Attendance"),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        title: Image.asset(
          'assets/logo/logo_transparent_clean.png',
          height: 60,
        ),
        centerTitle: true,
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
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
                        "My Attendance & Time Tracking",
                        style: TextStyle(
                          fontSize: 23,
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
                  if (attendance?.totalMinutesThisMonth != null)
                    AnimatedItem(
                      index: 2,
                      child: DetailCard(
                        DetailModel(
                          title: "Total Time This Month",
                          value: formatMinutes(
                            attendance!.totalMinutesThisMonth!,
                          ),
                          subtitle: "",
                          icon: Icons.timer,
                          color: Colors.orange,
                        ),
                      ),
                    ),

                  const SizedBox(height: 6),

                  if (attendance?.totalMinutesThisMonth != null)
                    AnimatedItem(
                      index: 5,
                      child: InsightCard(
                        data: InsightModel(
                          title: "Average Per Day",
                          value: formatMinutes(avgMinutes),
                          unit: "",
                          subtitle: "Last 30 days",
                          extra: "",
                          icon: Icons.access_time,
                          color: Colors.teal,
                          type: "simple",
                        ),
                      ),
                    ),

                  const SizedBox(height: 12),

                  if (attendance?.streak != null)
                    AnimatedItem(
                      index: 6,
                      child: InsightCard(
                        data: InsightModel(
                          title: "Current Streak",
                          value: "${attendance!.streak}",
                          unit: "days",
                          subtitle: "Current practice streak",
                          extra: "",
                          icon: Icons.local_fire_department,
                          color: Colors.orange,
                          type: "simple",
                        ),
                      ),
                    ),

                  const SizedBox(height: 12),

                  if (attendance?.monthlyGoalMinutes != null)
                    AnimatedItem(
                      index: 7,
                      child: InsightCard(
                        data: InsightModel(
                          title: "Monthly Goal",
                          value: "${goalPercentage.round()}%",
                          unit: "",
                          subtitle: "",
                          extra: "",
                          icon: Icons.gps_fixed,
                          color: Colors.deepPurple,
                          type: "simple",
                        ),
                      ),
                    ),

                  /// MONTHLY
                  if ((attendance?.monthlyStats ?? []).isNotEmpty)
                    AnimatedItem(
                      index: 8,
                      child: _buildSection(
                        "Monthly Statistics",
                        (attendance?.monthlyStats ?? [])
                            .map(
                              (e) => ProgressRow(
                                ProgressModel(
                                  title: e.month,
                                  sub1: formatMinutes(e.minutes),
                                  sub2:
                                      "${e.attended}/${e.totalClasses} classes",
                                  progress: e.progress,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  const SizedBox(height: 20),

                  /// CLASS-WISE
                  if ((attendance?.classWiseStats ?? []).isNotEmpty)
                    AnimatedItem(
                      index: 9,
                      child: _buildSection(
                        "Class-wise Time & Attendance",
                        (attendance?.classWiseStats ?? [])
                            .map(
                              (e) => ClassProgressRow(
                                ProgressModel(
                                  title: e.className,
                                  sub1: formatMinutes(e.minutes),
                                  sub2: "${e.attended}/${e.totalClasses}",
                                  progress: e.progress,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),

                  const SizedBox(height: 20),
                ],
              ),
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
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.3,
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
