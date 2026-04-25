import 'package:flutter/material.dart';
import 'package:navyoga_academy/Dashboard/dashboard_menu.dart';
import 'package:navyoga_academy/models/recording_model.dart';
import 'package:navyoga_academy/routes/app_routes.dart';
import 'package:navyoga_academy/models/class_model.dart';
import 'package:navyoga_academy/screens/recording_player_screen.dart';
import 'package:navyoga_academy/widgets/dashboard_Action_card.dart';
import 'package:navyoga_academy/widgets/dashboard_ReferralCode_card.dart';
import 'package:navyoga_academy/widgets/dashboard_Referral_card.dart';
import 'package:navyoga_academy/widgets/dashboard_ShareEarn_card.dart';
import 'package:navyoga_academy/widgets/dashboard_achievement_card.dart';
import 'package:navyoga_academy/widgets/dashboard_class_card.dart';
import 'package:navyoga_academy/widgets/dashboard_section_header.dart';
import 'package:navyoga_academy/widgets/dashboard_stat_card.dart';
import 'package:navyoga_academy/widgets/dashboard_video_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      backgroundColor: Color(0xffF7F7F7),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,

        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Color(0xff1E1B39)),

            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),

        title: Text(
          "NavYoga Academy",
          style: TextStyle(
            color: Colors.deepOrange,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// 🔥 BANNER
            Container(
              height: 220,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                image: const DecorationImage(
                  image: AssetImage(
                    "assets/images/woman-practicing-cobra-asana-yoga-600nw-1605427378.webp",
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.deepOrange,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "🎉 LIMITED TIME OFFER",
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
                  const Positioned(
                    left: 16,
                    bottom: 70,
                    child: Text(
                      "Get 20% OFF\non Annual Plans!",
                      style: TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.auto_awesome_motion, color: Colors.purple),
                          SizedBox(width: 6),
                          Text(
                            "Claim Offer Now",
                            style: TextStyle(
                              color: Color.fromARGB(255, 89, 0, 105),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// 📊 STATS
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.3,

              children: [
                StatCard(
                  "Enrolled Classes",
                  "8",
                  "+2 this month",
                  Color.fromARGB(255, 255, 89, 24),
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.attendance);
                  },
                ),

                StatCard(
                  "Hours Completed",
                  "124",
                  "+18 this week",
                  Color.fromARGB(255, 169, 43, 191),
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.attendance);
                  },
                ),

                StatCard(
                  "Recordings Watched",
                  "45",
                  "+8 this week",
                  Color.fromARGB(255, 43, 191, 117),
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.attendance);
                  },
                ),

                StatCard(
                  "Attendance Rate",
                  "92%",
                  "+5% improvement",
                  Colors.orange,
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.attendance);
                  },
                ),
              ],
            ),

            const SizedBox(height: 30),

            /// 📅 UPCOMING
            sectionHeader(Icons.calendar_today, "Upcoming Classes"),

            ClassCard(
              "Advanced Hatha Yoga",
              "Priya Sharma • Today at 6:00 PM",
              "60 min",
              onJoin: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.liveClass,
                  arguments: ClassModel(
                    title: "Advanced Hatha Yoga",
                    trainer: "Priya Sharma",
                    rating: "4.8",
                    level: "Advanced",
                    duration: "60 min",
                    students: "24/30",
                    progress: 0.7,
                    schedule: "Today at 6:00 PM",
                    next: "Now",
                    color: Colors.orange,
                  ),
                );
              },
            ),

            ClassCard(
              "Pranayama Basics",
              "Rahul Kumar • Tomorrow at 7:00 AM",
              "45 min",
              onJoin: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.liveClass,
                  arguments: ClassModel(
                    title: "Pranayama Basics",
                    trainer: "Rahul Kumar",
                    rating: "4.9",
                    level: "Beginner",
                    duration: "45 min",
                    students: "18/25",
                    progress: 0.5,
                    schedule: "Tomorrow at 7:00 AM",
                    next: "Upcoming",
                    color: Colors.green,
                  ),
                );
              },
            ),

            ClassCard(
              "Meditation & Mindfulness",
              "Anita Verma • Mar 12",
              "30 min",
              onJoin: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.liveClass,
                  arguments: ClassModel(
                    title: "Meditation & Mindfulness",
                    trainer: "Anita Verma",
                    rating: "5.0",
                    level: "All Levels",
                    duration: "30 min",
                    students: "32/40",
                    progress: 0.8,
                    schedule: "Mar 12",
                    next: "Upcoming",
                    color: Colors.purple,
                  ),
                );
              },
            ),

            ClassCard(
              "Power Yoga Flow",
              "Vikram Singh • Mar 13",
              "75 min",
              onJoin: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.liveClass,
                  arguments: ClassModel(
                    title: "Power Yoga Flow",
                    trainer: "Vikram Singh",
                    rating: "4.7",
                    level: "Intermediate",
                    duration: "75 min",
                    students: "20/25",
                    progress: 0.4,
                    schedule: "Mar 13",
                    next: "Upcoming",
                    color: Colors.deepOrange,
                  ),
                );
              },
            ),
            const SizedBox(height: 30),

            /// 🎥 RECORDINGS
            sectionHeader(Icons.videocam, "Recent Recordings"),

            VideoCard(
              "Introduction to Ashtanga",
              "Priya Sharma • 45:30",
              "234 views",
              "Mar 8",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RecordingPlayerScreen(
                      recording: RecordingModel(
                        title: "Introduction to Ashtanga",
                        trainer: "Priya Sharma",
                        category: "Yoga",
                        duration: "45:30",
                        rating: "4.8",
                        views: "234 views",
                        date: "Mar 8",
                        color: Colors.purple,
                        isCompleted: false,
                      ),
                    ),
                  ),
                );
              },
            ),

            VideoCard(
              "Breathing Techniques",
              "Rahul Kumar • 30:15",
              "189 views",
              "Mar 7",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RecordingPlayerScreen(
                      recording: RecordingModel(
                        title: "Breathing Techniques",
                        trainer: "Rahul Kumar",
                        category: "Pranayama",
                        duration: "30:15",
                        rating: "4.9",
                        views: "189 views",
                        date: "Mar 7",
                        color: Colors.green,
                        isCompleted: false,
                      ),
                    ),
                  ),
                );
              },
            ),

            VideoCard(
              "Morning Stretch Routine",
              "Anita Verma • 25:00",
              "312 views",
              "Mar 6",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RecordingPlayerScreen(
                      recording: RecordingModel(
                        title: "Morning Stretch Routine",
                        trainer: "Anita Verma",
                        category: "Yoga",
                        duration: "25:00",
                        rating: "5.0",
                        views: "312 views",
                        date: "Mar 6",
                        color: Colors.purple,
                        isCompleted: true,
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 30),

            /// 🏆 ACHIEVEMENTS
            sectionHeader(
              Icons.calendar_today,
              "Your Achievements",
              showViewAll: false,
            ),
            const SizedBox(height: 10),

            const AchievementCard(
              "30-Day Streak",
              "Attended classes for 30 consecutive days",
              Color.fromARGB(255, 245, 135, 102),
              true,
            ),
            const AchievementCard(
              "Early Bird",
              "Attended 10 morning classes",
              Color.fromARGB(255, 48, 175, 52),
              true,
            ),
            const AchievementCard(
              "Meditation Master",
              "Completed 20 sessions",
              Colors.grey,
              false,
            ),

            const SizedBox(height: 30),

            /// ACTIONS
            const ActionCard(
              "Browse Classes",
              "Explore available courses",
              Colors.deepOrange,
            ),
            const ActionCard("Self-Paced", "Learn at your pace", Colors.purple),
            const ActionCard(
              "Watch Recordings",
              "Catch up on sessions",
              Colors.pink,
            ),
            const ActionCard(
              "View Attendance",
              "Track your progress",
              Colors.green,
            ),
            const ActionCard(
              "My Profile",
              "Update your details",
              Colors.orange,
            ),

            const SizedBox(height: 30),

            /// REFERRAL
            sectionHeader(Icons.card_giftcard, "Referral Program"),

            const ReferralCard(
              "12",
              "Total Referrals",
              Colors.orange,
              "Active",
            ),

            const ReferralCard(
              "₹ 3600",
              "Total Earned",
              Colors.purple,
              "Earned",
            ),

            const ReferralCard(
              "3/6",
              "Achievement Badges",
              Colors.orange,
              "Unlocked",
            ),
            const SizedBox(height: 20),

            const ReferralCodeCard(),
            const ShareEarnCard(),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomBar(),
      floatingActionButton: const DashboardButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
