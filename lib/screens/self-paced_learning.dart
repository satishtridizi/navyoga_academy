import 'package:flutter/material.dart';
import 'package:navyoga_academy/Dashboard/dashboard_menu.dart';
import 'package:navyoga_academy/data/self_paced_data.dart';
import 'package:navyoga_academy/models/selfpaces_course_model.dart';

class SelfPacedLearningScreen extends StatefulWidget {
  const SelfPacedLearningScreen({super.key});

  @override
  State<SelfPacedLearningScreen> createState() =>
      _SelfPacedLearningScreenState();
}

class _SelfPacedLearningScreenState extends State<SelfPacedLearningScreen> {
  Widget _courseCard(CourseModel course) {
    return Container(
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
                if (course.showProgress) ...[
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
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (course.showEnrollButton) {
                        handleCTA("enroll");
                      } else if (course.completed) {
                        handleCTA("review");
                      } else {
                        handleCTA("continue");
                      }
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: Text(
                      course.showEnrollButton
                          ? "Enroll Now"
                          : course.actionText,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: course.showEnrollButton
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
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
  void handleCTA(String type) {
    if (type == "continue") {
      Navigator.pushNamed(context, "/courseDetails");
    } else if (type == "review") {
      Navigator.pushNamed(context, "/courseReview");
    } else if (type == "enroll") {
      Navigator.pushNamed(context, "/enrollCourse");
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("$type action coming soon")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const CustomDrawer(),
      backgroundColor: const Color(0xffF7F7F7),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),

          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),

        title: const Text(
          "NavYoga Academy",
          style: TextStyle(
            color: Colors.deepOrange,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            /// TOP GRADIENT SECTION
            Container(
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

            /// FLOATING SEARCH FILTER CARD
            Transform.translate(
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

                          border: Border.all(color: Colors.orange.shade100),
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
                        padding: const EdgeInsets.symmetric(vertical: 16),

                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),

                          border: Border.all(color: Colors.orange.shade100),
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

                          return GestureDetector(
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

                                borderRadius: BorderRadius.circular(24),

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
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 50),

            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: SelfPacedData.courses.length,
              itemBuilder: (context, index) {
                final course = SelfPacedData.courses[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: _courseCard(course),
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

  Widget _buildCourseCard() {
    return Container(
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

                child: Image.network(
                  "https://images.unsplash.com/photo-1506126613408-eca07ce68773",

                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

              Positioned(
                top: 16,
                right: 14,

                child: _pill(
                  "Enrolled",
                  Colors.white,
                  Colors.deepPurple,
                  borderColor: Colors.deepPurple,
                ),
              ),

              Positioned(
                left: 14,
                bottom: 14,

                child: _pill("Beginner", const Color(0xffD1FAE5), Colors.green),
              ),

              Positioned(
                right: 14,
                bottom: 14,

                child: _pill("⭐ 4.9", Colors.white, Colors.black87),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(26),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                const Text(
                  "Yoga Fundamentals\nfor Beginners",

                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 14),

                const Text(
                  "Master the basic yoga poses,\nbreathing techniques, and foundational",

                  style: TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 28),

                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: [
                    Text("Priya Sharma", style: TextStyle(fontSize: 16)),

                    Text("🕒 6 hours", style: TextStyle(fontSize: 16)),
                  ],
                ),

                const SizedBox(height: 18),

                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: [
                    Text(
                      "8 of 24 lessons",

                      style: TextStyle(color: Colors.blueGrey),
                    ),

                    Text(
                      "33%",

                      style: TextStyle(
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                ClipRRect(
                  borderRadius: BorderRadius.circular(10),

                  child: const LinearProgressIndicator(
                    value: .33,
                    minHeight: 10,
                  ),
                ),

                const SizedBox(height: 26),

                SizedBox(
                  width: double.infinity,

                  child: ElevatedButton.icon(
                    onPressed: () => handleCTA("continue"),

                    icon: const Icon(Icons.play_arrow),

                    label: const Text("Continue Learning"),

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,

                      foregroundColor: Colors.white,

                      padding: const EdgeInsets.symmetric(vertical: 16),

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
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

  Widget _buildAdvancedCourseCard() {
    return Container(
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
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),

                child: Image.network(
                  "https://images.unsplash.com/photo-1544367567-0f2fcb009e0b",

                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

              /// Completed
              Positioned(
                top: 16,
                left: 16,

                child: _pill("✓ Completed", Colors.green, Colors.white),
              ),

              /// Enrolled
              Positioned(
                top: 16,
                right: 14,

                child: _pill(
                  "Enrolled",
                  Colors.white,
                  Colors.deepPurple,
                  borderColor: Colors.deepPurple,
                ),
              ),

              /// Advanced
              Positioned(
                left: 14,
                bottom: 14,

                child: _pill("Advanced", Colors.white, Colors.deepPurple),
              ),

              /// Rating
              Positioned(
                right: 14,
                bottom: 14,

                child: _pill("⭐ 4.8", Colors.white, Colors.black87),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(26),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                const Text(
                  "Advanced Asana Mastery",

                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 14),

                const Text(
                  "Deepen your practice with advanced\nposes, inversions, and complex",

                  style: TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 28),

                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: [
                    Text("Rohan Desai", style: TextStyle(fontSize: 16)),

                    Text("🕒 10 hours", style: TextStyle(fontSize: 16)),
                  ],
                ),

                const SizedBox(height: 18),

                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: [
                    Text(
                      "40 of 40 lessons",

                      style: TextStyle(color: Colors.blueGrey),
                    ),

                    Text(
                      "100%",

                      style: TextStyle(
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                ClipRRect(
                  borderRadius: BorderRadius.circular(10),

                  child: const LinearProgressIndicator(
                    value: 1.0,
                    minHeight: 10,
                  ),
                ),

                const SizedBox(height: 26),

                SizedBox(
                  width: double.infinity,

                  child: ElevatedButton.icon(
                    onPressed: () => handleCTA("review"),

                    icon: const Icon(Icons.play_arrow),

                    label: const Text("Review Course"),

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,

                      foregroundColor: Colors.white,

                      padding: const EdgeInsets.symmetric(vertical: 16),

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
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

  Widget _buildPranayamaCourseCard() {
    return Container(
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
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),

                child: Image.network(
                  "https://images.unsplash.com/photo-1552196563-55cd4e45efb3",

                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

              Positioned(
                top: 16,
                right: 14,

                child: _pill(
                  "Enrolled",
                  Colors.white,
                  Colors.deepPurple,

                  borderColor: Colors.deepPurple,
                ),
              ),

              Positioned(
                left: 14,
                bottom: 14,

                child: _pill("Intermediate", Colors.white, Colors.blue),
              ),

              Positioned(
                right: 14,
                bottom: 14,

                child: _pill("⭐ 5", Colors.white, Colors.black87),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(26),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                const Text(
                  "Pranayama &\nBreathwork Essentials",

                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 14),

                const Text(
                  "Learn powerful breathing techniques\nto enhance your energy, reduce",

                  style: TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 28),

                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: [
                    Text("Anjali Menon", style: TextStyle(fontSize: 16)),

                    Text("🕒 4 hours", style: TextStyle(fontSize: 16)),
                  ],
                ),

                const SizedBox(height: 18),

                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: [
                    Text(
                      "5 of 16 lessons",

                      style: TextStyle(color: Colors.blueGrey),
                    ),

                    Text(
                      "31%",

                      style: TextStyle(
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                ClipRRect(
                  borderRadius: BorderRadius.circular(10),

                  child: const LinearProgressIndicator(
                    value: .31,
                    minHeight: 10,
                  ),
                ),

                const SizedBox(height: 26),

                SizedBox(
                  width: double.infinity,

                  child: ElevatedButton.icon(
                    onPressed: () => handleCTA("continue"),

                    icon: const Icon(Icons.play_arrow),

                    label: const Text("Continue Learning"),

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,

                      foregroundColor: Colors.white,

                      padding: const EdgeInsets.symmetric(vertical: 16),

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
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

  Widget _buildMeditationCourseCard() {
    return Container(
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
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),

                child: Image.network(
                  "https://images.unsplash.com/photo-1526401485004-2fda9f3f1c9b",

                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

              Positioned(
                left: 14,
                bottom: 14,

                child: _pill("Beginner", Colors.white, Colors.green),
              ),

              Positioned(
                right: 14,
                bottom: 14,

                child: _pill("⭐ 4.9", Colors.white, Colors.black87),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(26),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                const Text(
                  "Meditation &\nMindfulness Journey",

                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 14),

                const Text(
                  "Develop a consistent meditation\npractice with guided sessions ranging",

                  style: TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 28),

                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: [
                    Text("Vikram Patel", style: TextStyle(fontSize: 16)),

                    Text("🕒 5 hours", style: TextStyle(fontSize: 16)),
                  ],
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,

                  child: ElevatedButton.icon(
                    onPressed: () => handleCTA("enroll"),

                    icon: const Icon(Icons.menu_book_outlined),

                    label: const Text("Enroll Now"),

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,

                      foregroundColor: Colors.white,

                      padding: const EdgeInsets.symmetric(vertical: 16),

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
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

  Widget _buildFlexibilityCourseCard() {
    return Container(
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
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),

                child: Image.network(
                  "https://images.unsplash.com/photo-1544367567-0f2fcb009e0b",

                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

              Positioned(
                left: 14,
                bottom: 14,

                child: _pill("Intermediate", Colors.white, Colors.blue),
              ),

              Positioned(
                right: 14,
                bottom: 14,

                child: _pill("⭐ 4.7", Colors.white, Colors.black87),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(26),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                const Text(
                  "Yoga for Flexibility & Strength",

                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 14),

                const Text(
                  "Build strength and increase flexibility\nthrough targeted sequences focusing",

                  style: TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 28),

                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: [
                    Text("Kavita Singh", style: TextStyle(fontSize: 16)),

                    Text("🕒 8 hours", style: TextStyle(fontSize: 16)),
                  ],
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,

                  child: ElevatedButton.icon(
                    onPressed: () => handleCTA("enroll"),

                    icon: const Icon(Icons.menu_book_outlined),

                    label: const Text("Enroll Now"),

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,

                      foregroundColor: Colors.white,

                      padding: const EdgeInsets.symmetric(vertical: 16),

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
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

  Widget _buildRestorativeCourseCard() {
    return Container(
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
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),

                child: Image.network(
                  "https://images.unsplash.com/photo-1552196563-55cd4e45efb3",

                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

              Positioned(
                left: 14,
                bottom: 14,

                child: _pill("Beginner", Colors.white, Colors.green),
              ),

              Positioned(
                right: 14,
                bottom: 14,

                child: _pill("⭐ 4.9", Colors.white, Colors.black87),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(26),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                const Text(
                  "Restorative Yoga & Healing",

                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 14),

                const Text(
                  "Gentle, therapeutic practices designed\nto promote deep relaxation, stress",

                  style: TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 28),

                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: [
                    Text("Meera Iyer", style: TextStyle(fontSize: 16)),

                    Text("🕒 6 hours", style: TextStyle(fontSize: 16)),
                  ],
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,

                  child: ElevatedButton.icon(
                    onPressed: () => handleCTA("enroll"),

                    icon: const Icon(Icons.menu_book_outlined),

                    label: const Text("Enroll Now"),

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,

                      foregroundColor: Colors.white,

                      padding: const EdgeInsets.symmetric(vertical: 16),

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
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
