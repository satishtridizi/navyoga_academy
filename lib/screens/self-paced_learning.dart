import 'package:flutter/material.dart';
import 'package:navyoga_academy/Dashboard/dashboard_menu.dart';
import 'package:navyoga_academy/models/class_model.dart';
import 'package:navyoga_academy/models/selfpaces_course_model.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:navyoga_academy/screens/self_paced_lesson_screen.dart';
import 'package:navyoga_academy/services/self_paced_progress_service.dart';
import 'package:navyoga_academy/services/self_paced_service.dart';
import 'package:navyoga_academy/utils/api_helper.dart';
import 'package:navyoga_academy/utils/auth_manager.dart';
import 'package:navyoga_academy/widgets/app_scaffold.dart';
import 'package:navyoga_academy/utils/app_snackbar.dart';
import 'package:navyoga_academy/routes/app_routes.dart';
import 'package:navyoga_academy/services/subscription_service.dart';
import 'package:navyoga_academy/screens/self_paced_classes_screen.dart';

class SelfPacedLearningScreen extends StatefulWidget {
  const SelfPacedLearningScreen({super.key});

  @override
  State<SelfPacedLearningScreen> createState() =>
      _SelfPacedLearningScreenState();
}

class _SelfPacedLearningScreenState extends State<SelfPacedLearningScreen> {
  String searchQuery = "";
  String? selectedPlanId;
  Map<String, double> courseProgress = {};
  Map<String, bool> courseCompleted = {};
  final progressService = SelfPacedProgressService();
  final selfPacedService = SelfPacedService();
  int enrolledCount = 0;
  int inProgressCount = 0;
  int completedCount = 0;
  int totalClasses = 0;
  List<CourseModel> courses = [];
  bool isLoading = true;
  bool hasActiveSubscription = false;
  String selectedStat = "all";
  List<CourseModel> get filteredCourses {
    List<CourseModel> filtered = List.from(courses);

    // Search Filter
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((course) {
        return course.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
            course.instructor.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    }

    // Category Filter
    if (selectedCategory != "All") {
      filtered = filtered.where((course) {
        return course.category.toLowerCase() == selectedCategory.toLowerCase();
      }).toList();
    }

    // Stat Filter
    switch (selectedStat) {
      case "enrolled":
        filtered = filtered
            .where((c) => (courseProgress[c.id] ?? 0) > 0)
            .toList();
        break;

      case "progress":
        filtered = filtered
            .where(
              (c) =>
                  (courseProgress[c.id] ?? 0) > 0 &&
                  !(courseCompleted[c.id] ?? false),
            )
            .toList();
        break;

      case "completed":
        filtered = filtered
            .where((c) => courseCompleted[c.id] ?? false)
            .toList();
        break;
    }

    return filtered;
  }

  @override
  void initState() {
    super.initState();
    loadCourses();
    loadSubscription();
    loadPlans();
  }

  Future<void> loadPlans() async {
    final token = await AuthManager.getToken();

    if (token == null) return;

    final response = await selfPacedService.getPlans(token);

    if (response["success"] == true &&
        response["data"] != null &&
        response["data"].isNotEmpty) {
      selectedPlanId = response["data"][0]["id"];

      print("PLAN ID => $selectedPlanId");
    }
  }

  Future<void> loadCourses() async {
    final token = await AuthManager.getToken();

    if (token == null) {
      Navigator.pushReplacementNamed(context, "/login");
      return;
    }

    final response = await selfPacedService.getCourses(token);

    print("SELF PACED RESPONSE => $response");

    if (ApiHelper.isSuccess(response) && response["data"] != null) {
      final List list = response["data"];
      if (!mounted) return;

      courses = list.map((e) => CourseModel.fromJson(e)).toList();

      final progressResponse = await progressService.getMyProgress(token);
      final progressList = progressResponse["data"] ?? [];
      int enrolled = 0;
      int inProgress = 0;
      int completed = 0;
      totalClasses = 0;
      print("TOTAL COURSES => ${courses.length}");
      for (final course in courses) {
        final classesResponse = await selfPacedService.getClasses(
          token,
          course.id,
        );

        final List classes = classesResponse["data"] ?? [];
        totalClasses += classes.length;
        if (classes.isEmpty) continue;

        int completedLessons = 0;

        for (final lesson in classes) {
          final lessonId = lesson["id"];

          final found = progressList.any(
            (p) => p["classId"] == lessonId && p["isCompleted"] == true,
          );

          if (found) {
            completedLessons++;
          }
        }
        double progress = completedLessons / classes.length;

        courseProgress[course.id] = progress;

        courseCompleted[course.id] = completedLessons == classes.length;
        print(
          "${course.title} => "
          "$completedLessons/${classes.length}",
        );

        if (completedLessons > 0) {
          enrolled++;
        }

        if (completedLessons > 0 && completedLessons < classes.length) {
          inProgress++;
        }

        if (completedLessons == classes.length) {
          completed++;
        }
      }
      print("PROGRESS LIST => ${progressResponse["data"]}");

      for (final c in courses) {
        print(
          "COURSE => ${c.title}"
          " enrolled=${c.enrolled}"
          " completed=${c.completed}"
          " progress=${c.progress}",
        );
      }

      setState(() {
        enrolledCount = enrolled;
        inProgressCount = inProgress;
        completedCount = completed;

        isLoading = false;
      });
    } else {
      AppSnackbar.showError(
        context,
        response["message"] ?? "Failed to load courses",
      );

      setState(() {
        courses = [];
        isLoading = false;
      });
    }
    final plans = await selfPacedService.getPlans(token);

    print("SELF PACED PLANS => $plans");
  }

  Future<void> loadSubscription() async {
    final token = await AuthManager.getToken();

    if (token == null) return;

    final subscriptionService = SubscriptionService();

    final response = await subscriptionService.getMySubscription(token);

    if (response["success"] == true && response["data"]["enrolled"] == true) {
      setState(() {
        hasActiveSubscription = true;
      });
    }
  }

  Future<void> enrollCourse(CourseModel course) async {
    final token = await AuthManager.getToken();

    if (token == null) {
      Navigator.pushReplacementNamed(context, "/login");
      return;
    }

    final response = await selfPacedService.initiatePayment(
      token,
      course.id,
      selectedPlanId!,
    );
    print("INITIATE RESPONSE => $response");
    if (ApiHelper.isSuccess(response) && response["data"] != null) {
      AppSnackbar.showSuccess(context, "Proceed to payment");

      Navigator.pushNamed(
        context,
        AppRoutes.payments, // or your payment route
      );
    } else {
      AppSnackbar.showError(
        context,
        response["message"] ?? "Payment initiation failed",
      );
    }
  }

  Widget _courseCard(CourseModel course) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
      margin: const EdgeInsets.symmetric(horizontal: 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// IMAGE
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),

                child: Animate(
                  effects: const [
                    ScaleEffect(
                      begin: Offset(1.05, 1.05),
                      end: Offset(1, 1),
                      duration: Duration(milliseconds: 700),
                    ),
                  ],

                  child: Image.network(
                    course.image,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    cacheWidth: 800,

                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 150,
                        width: double.infinity,
                        color: Colors.grey[300],
                        child: const Icon(Icons.broken_image, size: 40),
                      );
                    },
                  ),
                ),
              ),

              /// LEVEL
              Positioned(
                left: 14,
                bottom: 14,
                child: _pill(course.level, Colors.white, Colors.deepPurple),
              ),

              /// RATING
              Positioned(
                right: 14,
                bottom: 14,
                child: _pill("⭐ ${course.rating}", Colors.white, Colors.black),
              ),

              /// STATUS
              if ((courseProgress[course.id] ?? 0) > 0)
                Positioned(
                  top: 16,
                  right: 14,
                  child: _pill(
                    (courseCompleted[course.id] ?? false)
                        ? "✓ Completed"
                        : "Enrolled",
                    Colors.white,
                    Colors.deepPurple,
                    borderColor: Colors.deepPurple,
                  ),
                ),
            ],
          ),

          /// CONTENT
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  course.description,
                  style: const TextStyle(color: Colors.blueGrey),
                ),

                const SizedBox(height: 2),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(course.instructor),
                    Text("🕒 ${course.duration}"),
                  ],
                ),

                /// PROGRESS
                if ((courseProgress[course.id] ?? 0) > 0) ...[
                  const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(course.lessonsText ?? ""),
                      Text(
                        "${((courseProgress[course.id] ?? 0) * 100).toInt()}%",
                        style: const TextStyle(
                          color: Colors.deepPurple,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: courseProgress[course.id] ?? 0,
                      minHeight: 10,
                    ),
                  ),
                ],

                const SizedBox(height: 10),

                /// CTA BUTTON
                SizedBox(
                  width: double.infinity,
                  child: Animate(
                    effects: const [
                      FadeEffect(duration: Duration(milliseconds: 500)),
                    ],

                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (!hasActiveSubscription) {
                          handleCTA("enroll", course);
                        } else if (courseCompleted[course.id] ?? false) {
                          handleCTA("review", course);
                        } else {
                          handleCTA("continue", course);
                        }
                      },
                      icon: const Icon(Icons.play_arrow),
                      label: Text(
                        !hasActiveSubscription
                            ? "Enroll Now"
                            : (courseCompleted[course.id] ?? false)
                            ? "Review Course"
                            : "Continue Learning",
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: !hasActiveSubscription
                            ? Colors.deepOrange
                            : Colors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String selectedCategory = "All";

  final categories = [
    "All",
    "Foundation",
    "Asana",
    "Pranayama",
    "Meditation",
    "Fitness",
    "Wellness",
  ];
  Future<void> continueLearning(CourseModel course) async {
    try {
      final token = await AuthManager.getToken();

      if (token == null) return;

      final classesResponse = await selfPacedService.getClasses(
        token,
        course.id,
      );

      final List classes = classesResponse["data"] ?? [];

      if (classes.isEmpty) return;

      final progressResponse = await progressService.getMyProgress(token);

      final List progressList = progressResponse["data"] ?? [];

      Map<String, bool> completedMap = {};

      for (final item in progressList) {
        completedMap[item["classId"].toString()] = item["isCompleted"] == true;
      }

      final firstUnfinished = classes.firstWhere(
        (lesson) => completedMap[lesson["id"].toString()] != true,
        orElse: () => classes.first,
      );
      print("OPENING LESSON ID => ${firstUnfinished["id"]}");
      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SelfPacedLessonScreen(
            lesson: ClassModel.fromJson(firstUnfinished),
          ),
        ),
      );
    } catch (e) {
      print("CONTINUE LEARNING ERROR => $e");
    }
  }

  void handleCTA(String type, [CourseModel? course]) {
    if (type == "continue" && course != null) {
      continueLearning(course);
    } else if (type == "review" && course != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              SelfPacedClassesScreen(moduleId: course.id, title: course.title),
        ),
      );
    } else if (type == "enroll" && course != null) {
      enrollCourse(course);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("$type action coming soon")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentIndex: null,

      drawer: const CustomDrawer(currentPage: "Self-Paced"),
      // backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.white,
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              physics: const ClampingScrollPhysics(),

              child: Column(
                children: [
                  /// TOP GRADIENT SECTION
                  /// TOP GRADIENT SECTION
                  Animate(
                    effects: const [
                      FadeEffect(duration: Duration(milliseconds: 500)),

                      SlideEffect(
                        begin: Offset(0, -0.1),
                        end: Offset(0, 0),
                        duration: Duration(milliseconds: 500),
                      ),
                    ],

                    child: Container(
                      width: double.infinity,

                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),

                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,

                          colors: [Color(0xffF97316), Color(0xff7E22CE)],
                        ),
                      ),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),

                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(.15),

                                  borderRadius: BorderRadius.circular(18),
                                ),

                                child: const Icon(
                                  Icons.school,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),

                              const SizedBox(width: 16),

                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,

                                  children: [
                                    Text(
                                      "Self-Paced Learning",

                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,

                                        color: Colors.white,
                                        height: 1.1,
                                      ),
                                    ),

                                    SizedBox(height: 12),

                                    Text(
                                      "Learn at your own pace, anytime, anywhere",

                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 13,
                                        height: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 35),

                          Row(
                            children: [
                              Expanded(
                                child: buildTopStat(
                                  Icons.menu_book_outlined,
                                  "Modules",
                                  courses.length.toString(),
                                ),
                              ),
                              const SizedBox(width: 12),

                              Expanded(
                                child: buildTopStat(
                                  Icons.play_circle_outline,
                                  "Classes",
                                  totalClasses.toString(),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          Row(
                            children: [
                              Expanded(
                                child: buildTopStat(
                                  Icons.trending_up,
                                  "Progress",
                                  "${(courseProgress.values.isEmpty ? 0 : (courseProgress.values.reduce((a, b) => a + b) / courseProgress.length * 100)).toInt()}%",
                                ),
                              ),
                              const SizedBox(width: 12),

                              Expanded(
                                child: buildTopStat(
                                  Icons.workspace_premium_outlined,
                                  "Active Plan",
                                  hasActiveSubscription
                                      ? "Active"
                                      : "Not Enrolled",
                                ),
                              ),
                            ],
                          ),
                          if (!hasActiveSubscription)
                            Container(
                              margin: const EdgeInsets.all(20),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: const Color(0xffF7F1F3),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.orange.shade200,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.lock_outline,
                                      color: Colors.deepOrange,
                                    ),
                                  ),

                                  const SizedBox(width: 16),

                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Subscribe to unlock self-paced classes",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          "Browse the catalogue below and enroll to start watching at your own pace.",
                                        ),
                                      ],
                                    ),
                                  ),

                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pushNamed(
                                        context,
                                        AppRoutes.payments,
                                      );
                                    },
                                    child: const Text("View Plans"),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  /// FLOATING SEARCH FILTER CARD
                  if (hasActiveSubscription)
                    Animate(
                      delay: const Duration(milliseconds: 200),
                      effects: const [
                        FadeEffect(duration: Duration(milliseconds: 500)),
                        SlideEffect(
                          begin: Offset(0, 0.15),
                          end: Offset(0, 0),
                          duration: Duration(milliseconds: 500),
                        ),
                      ],
                      child: Transform.translate(
                        offset: const Offset(0, 25),

                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 22),

                          child: Container(
                            padding: const EdgeInsets.all(14),

                            decoration: BoxDecoration(
                              color: Colors.white,

                              borderRadius: BorderRadius.circular(20),

                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(.08),

                                  blurRadius: 18,

                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),

                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                /// SEARCH
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),

                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),

                                    border: Border.all(
                                      color: Colors.orange.shade100,
                                    ),
                                  ),

                                  child: TextField(
                                    onChanged: (value) {
                                      setState(() {
                                        searchQuery = value;
                                      });
                                    },
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      icon: Icon(
                                        Icons.search,
                                        color: Colors.blueGrey,
                                      ),
                                      hintText:
                                          "Search courses, instructors...",
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 6),

                                /// FILTER
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),

                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),

                                    border: Border.all(
                                      color: Colors.orange.shade100,
                                    ),
                                  ),

                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,

                                    children: [
                                      Icon(Icons.filter_alt_outlined),

                                      SizedBox(width: 10),

                                      Text(
                                        "All Courses",

                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 10),

                                /// CATEGORY CHIPS
                                // Wrap(
                                //   spacing: 6,
                                //   runSpacing: 6,

                                //   children: categories.map((cat) {
                                //     bool selected = cat == selectedCategory;

                                //     return Animate(
                                //       delay: Duration(
                                //         milliseconds:
                                //             80 * categories.indexOf(cat).toInt(),
                                //       ),

                                //       effects: const [
                                //         FadeEffect(
                                //           duration: Duration(milliseconds: 400),
                                //         ),

                                //         ScaleEffect(
                                //           begin: Offset(0.9, 0.9),
                                //           end: Offset(1, 1),
                                //           duration: Duration(milliseconds: 400),
                                //         ),
                                //       ],

                                //       child: GestureDetector(
                                //         onTap: () {
                                //           setState(() {
                                //             selectedCategory = cat;
                                //           });
                                //         },

                                //         child: Container(
                                //           padding: const EdgeInsets.symmetric(
                                //             horizontal: 12,
                                //             vertical: 6,
                                //           ),

                                //           decoration: BoxDecoration(
                                //             color: selected
                                //                 ? Colors.deepOrange
                                //                 : Colors.white,

                                //             borderRadius: BorderRadius.circular(
                                //               24,
                                //             ),

                                //             border: Border.all(
                                //               color: Colors.orange.shade100,
                                //             ),
                                //           ),

                                //           child: Text(
                                //             cat,

                                //             style: TextStyle(
                                //               fontSize: 13,

                                //               color: selected
                                //                   ? Colors.white
                                //                   : Colors.black87,
                                //             ),
                                //           ),
                                //         ),
                                //       ),
                                //     );
                                //   }).toList(),
                                // ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                  SizedBox(height: hasActiveSubscription ? 50 : 20),

                  if (hasActiveSubscription)
                    courses.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: 40),
                              child: Text("No courses available"),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: filteredCourses.length,
                            itemBuilder: (context, index) {
                              final course = filteredCourses[index];

                              return Animate(
                                delay: Duration(milliseconds: 150 * index),
                                effects: const [
                                  FadeEffect(
                                    duration: Duration(milliseconds: 500),
                                  ),
                                  SlideEffect(
                                    begin: Offset(0, 0.12),
                                    end: Offset(0, 0),
                                    duration: Duration(milliseconds: 500),
                                  ),
                                ],
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  child: _courseCard(course),
                                ),
                              );
                            },
                          ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  static Widget _statCard({
    required IconData icon,
    required String title,
    required String count,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.12),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(.18)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 6),
                Text(
                  count,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget _pill(String text, Color bg, Color fg, {Color? borderColor}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),

    decoration: BoxDecoration(
      color: bg,

      borderRadius: BorderRadius.circular(30),

      border: borderColor != null ? Border.all(color: borderColor) : null,
    ),

    child: Text(
      text,

      style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600),
    ),
  );
}

Widget buildTopStat(IconData icon, String title, String value) {
  return Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(.12),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withOpacity(.2)),
    ),
    child: Row(
      children: [
        CircleAvatar(
          backgroundColor: Colors.white24,
          child: Icon(icon, color: Colors.white),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white70)),
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
