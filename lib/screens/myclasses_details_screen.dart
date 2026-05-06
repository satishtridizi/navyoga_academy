import 'package:flutter/material.dart';
import 'package:navyoga_academy/models/class_model.dart';
import 'package:navyoga_academy/routes/app_routes.dart';
import 'package:navyoga_academy/widgets/animatedItem.dart';
import 'package:navyoga_academy/widgets/app_background.dart';

class ClassDetailsScreen extends StatelessWidget {
  const ClassDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final classData = ModalRoute.of(context)!.settings.arguments as ClassModel;

    final Color mainColor = classData.color;

    return Scaffold(
      backgroundColor: Colors.transparent,

      body: AppBackground(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),

          slivers: [
            /// 🔥 APP BAR
            SliverAppBar(
              expandedHeight: 260,
              pinned: true,
              backgroundColor: mainColor,

              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [mainColor, mainColor.withOpacity(0.7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),

                  child: Stack(
                    children: [
                      Positioned(
                        right: -30,
                        top: 60,
                        child: Icon(
                          Icons.self_improvement,
                          size: 180,
                          color: Colors.white.withOpacity(0.08),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(24),

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,

                          children: [
                            AnimatedItem(
                              index: 0,

                              child: Text(
                                classData.title,
                                style: const TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),

                            AnimatedItem(
                              index: 1,

                              child: Text(
                                classData.trainer,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            /// 🔥 CONTENT
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    /// TAGS
                    AnimatedItem(
                      index: 2,

                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,

                        children: [
                          _chip(
                            classData.level,
                            mainColor.withOpacity(0.15),
                            mainColor,
                          ),

                          _chip(
                            "⏱ ${classData.duration}",
                            Colors.grey.shade200,
                            Colors.black,
                          ),

                          _chip(
                            "⭐ ${classData.rating}",
                            Colors.yellow.shade100,
                            Colors.black,
                          ),

                          _chip(
                            "👥 ${classData.students}",
                            Colors.grey.shade200,
                            Colors.black,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    /// DESCRIPTION CARD
                    AnimatedItem(
                      index: 3,

                      child: Container(
                        padding: const EdgeInsets.all(22),

                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),

                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            const Text(
                              "About This Class",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepOrange,
                              ),
                            ),

                            const SizedBox(height: 14),

                            Text(
                              "Enhance your yoga journey with guided sessions, breathing techniques, flexibility exercises, and holistic wellness practices.",
                              style: TextStyle(
                                color: Colors.blueGrey.shade700,
                                height: 1.7,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    /// SCHEDULE CARD
                    AnimatedItem(
                      index: 4,

                      child: Container(
                        padding: const EdgeInsets.all(22),

                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              mainColor.withOpacity(0.12),
                              mainColor.withOpacity(0.03),
                            ],
                          ),

                          borderRadius: BorderRadius.circular(28),

                          border: Border.all(color: mainColor.withOpacity(0.2)),
                        ),

                        child: Column(
                          children: [
                            _detailRow(
                              Icons.calendar_today,
                              "Schedule",
                              classData.schedule,
                              mainColor,
                            ),

                            const SizedBox(height: 18),

                            _detailRow(
                              Icons.play_circle,
                              "Next Session",
                              classData.next,
                              mainColor,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    /// BUTTONS
                    AnimatedItem(
                      index: 5,

                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.liveClass,
                                  arguments: classData,
                                );
                              },

                              style: ElevatedButton.styleFrom(
                                backgroundColor: mainColor,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),

                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),

                              icon: const Icon(Icons.play_arrow),

                              label: const Text(
                                "Join Class",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.enrollClass,
                                  arguments: classData,
                                );
                              },

                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),

                                side: BorderSide(color: mainColor),

                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),

                              icon: Icon(Icons.school, color: mainColor),

                              label: Text(
                                "Enroll",
                                style: TextStyle(color: mainColor),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),

      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),

      child: Text(
        text,
        style: TextStyle(color: fg, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _detailRow(IconData icon, String title, String value, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),

          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(16),
          ),

          child: Icon(icon, color: color),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),

              const SizedBox(height: 4),

              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
