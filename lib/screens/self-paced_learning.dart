import 'package:flutter/material.dart';
import 'package:navyoga_academy/Dashboard/dashboard_menu.dart';
import 'package:navyoga_academy/data/self_paced_data.dart';
import 'package:navyoga_academy/models/selfpaces_course_model.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:navyoga_academy/services/self_paced_service.dart';
import 'package:navyoga_academy/utils/api_helper.dart';
import 'package:navyoga_academy/utils/auth_manager.dart';
import 'package:navyoga_academy/widgets/app_background.dart';
import 'package:navyoga_academy/widgets/app_scaffold.dart';
import 'package:navyoga_academy/utils/app_snackbar.dart';
import 'package:navyoga_academy/models/class_model.dart';
import 'package:navyoga_academy/routes/app_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SelfPacedLearningScreen extends StatefulWidget {
  const SelfPacedLearningScreen({super.key});

  @override
  State<SelfPacedLearningScreen> createState() =>
      _SelfPacedLearningScreenState();
}

class _SelfPacedLearningScreenState extends State<SelfPacedLearningScreen> {
  final selfPacedService = SelfPacedService();

  List<CourseModel> courses = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadCourses();
  }

  Future<void> loadCourses() async {
    final token = await AuthManager.getToken();

    if (token == null) {
      Navigator.pushReplacementNamed(context, "/login");
      return;
    }

    final response = await selfPacedService.getCourses(token);

    if (ApiHelper.isSuccess(response) && response["data"] != null) {
      final List list = response["data"];
      if (!mounted) return;

      setState(() {
        courses = list.map((e) => CourseModel.fromJson(e)).toList();
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
  }

  Future<void> enrollCourse(CourseModel course) async {
    final token = await AuthManager.getToken();

    if (token == null) {
      Navigator.pushReplacementNamed(context, "/login");
      return;
    }

    final response = await selfPacedService.initiatePayment(token, course.id);

    if (ApiHelper.isSuccess(response) && response["data"] != null) {
      AppSnackbar.showSuccess(context, "Proceed to payment");
    } else {
      AppSnackbar.showError(context, response["message"]);
    }
    return;
  }

  Widget _courseCard(CourseModel course) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
      margin: const EdgeInsets.symmetric(horizontal: 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
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
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    cacheWidth: 800,

                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 220,
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
              if (course.enrolled)
                Positioned(
                  top: 16,
                  right: 14,
                  child: _pill(
                    course.completed ? "✓ Completed" : "Enrolled",
                    Colors.white,
                    Colors.deepPurple,
                    borderColor: Colors.deepPurple,
                  ),
                ),
            ],
          ),

          /// CONTENT
          Padding(
            padding: const EdgeInsets.all(26),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  course.description,
                  style: const TextStyle(color: Colors.blueGrey),
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(course.instructor),
                    Text("🕒 ${course.duration}"),
                  ],
                ),

                /// PROGRESS
                if (course.progress > 0) ...[
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(course.lessonsText ?? ""),
                      Text(
                        "${((course.progress ?? 0) * 100).toInt()}%",
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
                      value: course.progress ?? 0,
                      minHeight: 10,
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                /// CTA BUTTON
                SizedBox(
                  width: double.infinity,
                  child: Animate(
                    effects: const [
                      FadeEffect(duration: Duration(milliseconds: 500)),
                    ],

                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (!course.enrolled) {
                          handleCTA("enroll", course);
                        } else if (course.completed) {
                          handleCTA("review");
                        } else {
                          handleCTA("continue");
                        }
                      },
                      icon: const Icon(Icons.play_arrow),
                      label: Text(
                        !course.enrolled
                            ? "Enroll Now"
                            : course.completed
                            ? "Review Course"
                            : (course.enrolled
                                  ? "Continue Learning"
                                  : "Enroll Now"),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: !course.enrolled
                            ? Colors.deepOrange
                            : Colors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
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
  void handleCTA(String type, [CourseModel? course]) {
    if (type == "continue") {
      Navigator.pushNamed(context, "/courseDetails");
    } else if (type == "review") {
      Navigator.pushNamed(context, "/courseReview");
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
      currentIndex: 2,

      drawer: const CustomDrawer(currentPage: "Self-Paced"),
      // backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.white,
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
            fontWeight: FontWeight.w600,
          ),
        ),
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

                      padding: const EdgeInsets.fromLTRB(24, 30, 24, 50),

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
                                padding: const EdgeInsets.all(18),

                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(.15),

                                  borderRadius: BorderRadius.circular(18),
                                ),

                                child: const Icon(
                                  Icons.school,
                                  color: Colors.white,
                                  size: 34,
                                ),
                              ),

                              const SizedBox(width: 16),

                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,

                                  children: [
                                    Text(
                                      "Self-Paced\nLearning",

                                      style: TextStyle(
                                        fontSize: 40,
                                        fontWeight: FontWeight.bold,

                                        color: Colors.white,
                                        height: 1.1,
                                      ),
                                    ),

                                    SizedBox(height: 12),

                                    Text(
                                      "Learn at your own pace,\nanytime, anywhere",

                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 16,
                                        height: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 35),

                          _statCard(
                            icon: Icons.menu_book_outlined,
                            title: "Enrolled Courses",
                            count: "3",
                          ),

                          const SizedBox(height: 20),

                          _statCard(
                            icon: Icons.trending_up,
                            title: "In Progress",
                            count: "2",
                          ),

                          const SizedBox(height: 20),

                          _statCard(
                            icon: Icons.workspace_premium_outlined,
                            title: "Completed",
                            count: "1",
                          ),

                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),

                  /// FLOATING SEARCH FILTER CARD
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
                          padding: const EdgeInsets.all(24),

                          decoration: BoxDecoration(
                            color: Colors.white,

                            borderRadius: BorderRadius.circular(28),

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
                                  horizontal: 16,
                                  vertical: 14,
                                ),

                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),

                                  border: Border.all(
                                    color: Colors.orange.shade100,
                                  ),
                                ),

                                child: const Row(
                                  children: [
                                    Icon(Icons.search, color: Colors.blueGrey),

                                    SizedBox(width: 12),

                                    Expanded(
                                      child: Text(
                                        "Search courses, instructors...",

                                        style: TextStyle(
                                          color: Colors.blueGrey,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 20),

                              /// FILTER
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
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
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 22),

                              /// CATEGORY CHIPS
                              Wrap(
                                spacing: 10,
                                runSpacing: 12,

                                children: categories.map((cat) {
                                  bool selected = cat == selectedCategory;

                                  return Animate(
                                    delay: Duration(
                                      milliseconds:
                                          80 * categories.indexOf(cat).toInt(),
                                    ),

                                    effects: const [
                                      FadeEffect(
                                        duration: Duration(milliseconds: 400),
                                      ),

                                      ScaleEffect(
                                        begin: Offset(0.9, 0.9),
                                        end: Offset(1, 1),
                                        duration: Duration(milliseconds: 400),
                                      ),
                                    ],

                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectedCategory = cat;
                                        });
                                      },

                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 18,
                                          vertical: 10,
                                        ),

                                        decoration: BoxDecoration(
                                          color: selected
                                              ? Colors.deepOrange
                                              : Colors.white,

                                          borderRadius: BorderRadius.circular(
                                            24,
                                          ),

                                          border: Border.all(
                                            color: Colors.orange.shade100,
                                          ),
                                        ),

                                        child: Text(
                                          cat,

                                          style: TextStyle(
                                            fontSize: 16,

                                            color: selected
                                                ? Colors.white
                                                : Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 50),

                  courses.isEmpty
                      ? const Center(child: Text("No courses available"))
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: courses.length,
                          itemBuilder: (context, index) {
                            final course = courses[index];
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
  }) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(26),

      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.12),

        borderRadius: BorderRadius.circular(24),

        border: Border.all(color: Colors.white.withOpacity(.18)),
      ),

      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),

            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.15),

              shape: BoxShape.circle,
            ),

            child: Icon(icon, color: Colors.white),
          ),

          const SizedBox(width: 18),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Text(
                title,

                style: const TextStyle(color: Colors.white70, fontSize: 17),
              ),

              const SizedBox(height: 6),

              Text(
                count,

                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Widget _pill(String text, Color bg, Color fg, {Color? borderColor}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),

    decoration: BoxDecoration(
      color: bg,

      borderRadius: BorderRadius.circular(30),

      border: borderColor != null ? Border.all(color: borderColor) : null,
    ),

    child: Text(
      text,

      style: TextStyle(color: fg, fontWeight: FontWeight.w600),
    ),
  );
}
