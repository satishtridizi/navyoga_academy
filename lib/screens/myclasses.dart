import 'package:flutter/material.dart';
import 'package:navyoga_academy/Dashboard/dashboard_menu.dart';
import 'package:navyoga_academy/services/dashboard_service.dart';
import 'package:navyoga_academy/models/live_enrollment_model.dart';
import 'package:navyoga_academy/models/myclasses_stats_model.dart';
import 'package:navyoga_academy/routes/app_routes.dart';
import 'package:navyoga_academy/services/workshop_service.dart';
import 'package:navyoga_academy/services/enrollment_service.dart';
import 'package:navyoga_academy/utils/auth_manager.dart';
import 'package:navyoga_academy/widgets/app_scaffold.dart';
import 'package:navyoga_academy/services/enrollment_service.dart';
import 'package:navyoga_academy/widgets/myclasses_available_class_card.dart';

class MyClassesScreen extends StatefulWidget {
  const MyClassesScreen({super.key});

  @override
  State<MyClassesScreen> createState() => _MyClassesScreenState();
}

class _MyClassesScreenState extends State<MyClassesScreen> {
  int enrolledCount = 0;
  int completedCount = 0;
  int progressCount = 0;
  int attendanceRate = 0;

  List<LiveEnrollmentModel> enrolledClasses = [];
  bool loading = true;
  String selectedLevel = "All Levels";
  String selectedStatus = "All Status";
  String selectedSection = "enrolled";
  @override
  void initState() {
    super.initState();

    loadEnrollments();

    loadDashboardStats();
  }

  Future<void> loadEnrollments() async {
    final token = await AuthManager.getToken();

    if (token == null) return;

    final res = await WorkshopService().getWorkshops(token);

    print(res);
    if (res["success"] == true) {
      final List items = res["data"]["items"] ?? [];

      final enrolledItems = items
          .where((e) => e["isEnrolled"] == true)
          .toList();

      final completedItems = enrolledItems
          .where((e) => e["status"] == "COMPLETED")
          .toList();

      final activeItems = enrolledItems
          .where((e) => e["status"] == "ACTIVE")
          .toList();

      setState(() {
        enrolledClasses = enrolledItems.map((e) {
          return LiveEnrollmentModel(
            id: e["id"] ?? "",
            courseId: "",
            planName: e["title"] ?? "",
            status: "ACTIVE",
            meetingUrl: e["meetingUrl"] ?? "",
            title: e["title"] ?? "",
            yogaType: e["yogaType"] ?? "",
            level: e["level"] ?? "",
            trainer: e["instructorName"] ?? "Instructor",
            duration: e["totalDuration"] ?? 0,
          );
        }).toList();

        enrolledCount = enrolledItems.length;

        completedCount = completedItems.length;

        progressCount = activeItems.length;

        loading = false;
      });
    }
  }

  Future<void> loadDashboardStats() async {
    final token = await AuthManager.getToken();

    if (token == null) return;

    final res = await DashboardService().getDashboard(token);

    print("DASHBOARD RESPONSE = $res");

    if (res["success"] == true) {
      final metrics = res["data"]["metrics"];

      setState(() {
        enrolledCount = metrics["enrolledClasses"] ?? 0;

        attendanceRate = metrics["attendanceRate"] ?? 0;

        // Backend doesn't provide these yet
        completedCount = metrics["completedClasses"] ?? 0;

        progressCount = metrics["inProgressClasses"] ?? 0;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final arg = ModalRoute.of(context)?.settings.arguments;

    if (arg != null && arg is String) {
      selectedSection = arg;
    }
  }

  List getFilteredClasses() {
    return enrolledClasses.where((e) {
      /// STATUS FILTER
      if (selectedStatus == "Completed" && e.status != "COMPLETED") {
        return false;
      }

      if (selectedStatus == "In Progress" && e.status != "ACTIVE") {
        return false;
      }

      /// LEVEL FILTER
      if (selectedLevel != "All Levels" && e.level != selectedLevel) {
        return false;
      }

      /// SECTION FILTER
      if (selectedSection == "completed") {
        return e.status == "COMPLETED";
      }

      if (selectedSection == "progress") {
        return e.status == "ACTIVE";
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final stats = [
      StatsModel(
        title: "Enrolled Classes",
        value: enrolledCount.toString(),
        color: Colors.deepOrange,
        icon: Icons.menu_book,
      ),

      StatsModel(
        title: "Completed",
        value: completedCount.toString(),
        color: Colors.green,
        icon: Icons.check_circle,
      ),

      StatsModel(
        title: "In Progress",
        value: progressCount.toString(),
        color: Colors.purple,
        icon: Icons.timelapse,
      ),

      StatsModel(
        title: "Avg. Attendance",
        value: "$attendanceRate%",
        color: Colors.orange,
        icon: Icons.calendar_today,
      ),
    ];
    return AppScaffold(
      currentIndex: 0,
      drawer: const CustomDrawer(currentPage: "My Classes"),
      //backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Color(0xff1E1B39)),
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

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// 🔥 HEADER
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.deepOrange, Colors.orangeAccent],
                ),
                borderRadius: BorderRadius.circular(26),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.menu_book, color: Colors.white, size: 30),
                      SizedBox(width: 10),
                      Text(
                        "My Classes",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Manage your enrolled classes\nand explore new courses",
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// 📊 STATS GRID
            GridView.builder(
              itemCount: stats.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.15,
              ),
              itemBuilder: (context, index) {
                final item = stats[index];

                return GestureDetector(
                  onTap: () {
                    if (item.title.contains("Enrolled")) {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.myClasses,
                        arguments: "enrolled",
                      );
                    } else if (item.title.contains("Completed")) {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.myClasses,
                        arguments: "completed",
                      );
                    } else if (item.title.contains("Progress")) {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.myClasses,
                        arguments: "progress",
                      );
                    } else if (item.title.contains("Attendance")) {
                      Navigator.pushNamed(context, AppRoutes.attendance);
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          (item.color).withOpacity(0.2),
                          (item.color).withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: item.color,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                item.icon,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                            Text(
                              item.value,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        Text(
                          item.title,
                          style: const TextStyle(
                            color: Color.fromARGB(255, 30, 30, 30),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            /// 🔍 SEARCH
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xfff7f7f7),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        icon: Icon(Icons.search),
                        hintText: "Search classes or instructors...",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: filterBox(
                          selectedLevel,
                          [
                            "All Levels",
                            "Beginner",
                            "Intermediate",
                            "Advanced",
                          ],
                          (val) => setState(() => selectedLevel = val),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: filterBox(
                          selectedStatus,
                          ["All Status", "Completed", "In Progress"],
                          (val) => setState(() => selectedStatus = val),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// 📚 HEADER
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.deepOrange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.auto_awesome, color: Colors.white),
                ),
                const SizedBox(width: 10),
                Text(
                  "Enrolled Classes (${enrolledClasses.length})",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            /// 📦 COURSE LIST
            if (selectedSection == "enrolled" ||
                selectedSection == "completed" ||
                selectedSection == "progress") ...[
              Builder(
                builder: (context) {
                  final filteredEnrolled = getFilteredClasses();

                  if (filteredEnrolled.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        "No enrolled classes found",
                        style: TextStyle(fontSize: 16),
                      ),
                    );
                  }

                  return Column(
                    children: filteredEnrolled.map((e) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.enrollmentsuccess,
                            arguments: e,
                          );
                        },
                        child: AvailableClassCard(data: e),
                      );
                    }).toList(),
                  );
                },
              ),
            ],

            const SizedBox(height: 24),

            /// 🆕 AVAILABLE CLASSES HEADER
            // Row(
            //   children: [
            //     Container(
            //       padding: const EdgeInsets.all(10),
            //       decoration: BoxDecoration(
            //         color: Colors.deepPurple,
            //         borderRadius: BorderRadius.circular(12),
            //       ),
            //       child: const Icon(Icons.menu_book, color: Colors.white),
            //     ),
            //     const SizedBox(width: 10),
            //     const Text(
            //       "Available Classes",
            //       style: TextStyle(
            //         fontSize: 18,
            //         fontWeight: FontWeight.bold,
            //         color: Colors.deepOrange,
            //       ),
            //     ),
            //   ],
            // ),

            // const SizedBox(height: 16),

            // Builder(
            //   builder: (context) {
            //     final availableNotEnrolled = availableClasses
            //         .where(
            //           (e) => !EnrollmentService.enrolledClasses.any(
            //             (enrolled) => enrolled.title == e.title,
            //           ),
            //         )
            //         .toList();

            //     if (availableNotEnrolled.isEmpty) {
            //       return const Padding(
            //         padding: EdgeInsets.all(20),
            //         child: Text(
            //           "All classes enrolled",
            //           style: TextStyle(
            //             fontSize: 16,
            //             fontWeight: FontWeight.w600,
            //           ),
            //         ),
            //       );
            //     }

            //     return Column(
            //       children: availableNotEnrolled
            //           .map((e) => AvailableClassCard(data: e))
            //           .toList(),
            //     );
            //   },
            // ),
          ],
        ),
      ),
    );
  }

  Widget filterBox(
    String value,
    List<String> options,
    Function(String) onSelected,
  ) {
    return GestureDetector(
      onTap: () async {
        final selected = await showModalBottomSheet<String>(
          context: context,
          builder: (_) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: options
                  .map(
                    (e) => ListTile(
                      title: Text(e),
                      onTap: () => Navigator.pop(context, e),
                    ),
                  )
                  .toList(),
            );
          },
        );

        if (selected != null) {
          onSelected(selected);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(value),
            const SizedBox(width: 6),
            const Icon(Icons.keyboard_arrow_down, size: 18),
          ],
        ),
      ),
    );
  }
}
