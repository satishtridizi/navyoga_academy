import 'package:flutter/material.dart';
import 'package:navyoga_academy/Dashboard/dashboard_menu.dart';
import 'package:navyoga_academy/data/myclasses_available_classes.dart';
import 'package:navyoga_academy/data/myclasses_enrolled_classes_data.dart';
import 'package:navyoga_academy/routes/app_routes.dart';
import 'package:navyoga_academy/widgets/app_background.dart';
import 'package:navyoga_academy/widgets/myclasses_available_class_card.dart';
import 'package:navyoga_academy/widgets/myclasses_course_card.dart';
import 'package:navyoga_academy/data/myclasses_stats_data.dart';

class MyClassesScreen extends StatefulWidget {
  const MyClassesScreen({super.key});

  @override
  State<MyClassesScreen> createState() => _MyClassesScreenState();
}

class _MyClassesScreenState extends State<MyClassesScreen> {
  String selectedLevel = "All Levels";
  String selectedStatus = "All Status";
  String selectedSection = "enrolled";
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
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
      if (selectedStatus == "Completed" && e.progress != 1.0) {
        return false;
      }

      if (selectedStatus == "In Progress" &&
          (e.progress == 0 || e.progress == 1.0)) {
        return false;
      }

      /// LEVEL FILTER
      if (selectedLevel != "All Levels" && e.level != selectedLevel) {
        return false;
      }

      /// SECTION FILTER
      if (selectedSection == "completed") {
        return e.progress == 1.0;
      }

      if (selectedSection == "progress") {
        return e.progress > 0 && e.progress < 1;
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const CustomDrawer(),
      backgroundColor: Colors.transparent,

      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.deepPurple),

          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        title: const Text(
          "NavYoga Academy",
          style: TextStyle(
            color: Colors.deepOrange,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: AppBackground(
        child: SingleChildScrollView(
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
                itemCount: statsData.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.15,
                ),
                itemBuilder: (context, index) {
                  final item = statsData[index];

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
                  const Text(
                    "Enrolled Classes (8)",
                    style: TextStyle(
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
                    return Column(
                      children: filteredEnrolled
                          .map((e) => CourseCard(data: e))
                          .toList(),
                    );
                  },
                ),
              ],

              const SizedBox(height: 24),

              /// 🆕 AVAILABLE CLASSES HEADER
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.menu_book, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "Available Classes",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Column(
                children: availableClasses
                    .map((e) => AvailableClassCard(data: e))
                    .toList(),
              ),
            ],
          ),
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
