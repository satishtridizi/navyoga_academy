import 'package:flutter/material.dart';
import 'package:navyoga_academy/Dashboard/dashboard_menu.dart';
import 'package:navyoga_academy/routes/dashboard_routes.dart';
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
              childAspectRatio: 1.55,

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

            const ClassCard(
              "Advanced Hatha Yoga",
              "Priya Sharma • Today at 6:00 PM",
              "60 min",
            ),
            const ClassCard(
              "Pranayama Basics",
              "Rahul Kumar • Tomorrow at 7:00 AM",
              "45 min",
            ),
            const ClassCard(
              "Meditation & Mindfulness",
              "Anita Verma • Mar 12",
              "30 min",
            ),
            const ClassCard(
              "Power Yoga Flow",
              "Vikram Singh • Mar 13",
              "75 min",
            ),

            const SizedBox(height: 30),

            /// 🎥 RECORDINGS
            sectionHeader(Icons.videocam, "Recent Recordings"),

            const VideoCard(
              "Introduction to Ashtanga",
              "Priya Sharma • 45:30",
              "234 views",
              "Mar 8",
            ),
            const VideoCard(
              "Breathing Techniques",
              "Rahul Kumar • 30:15",
              "189 views",
              "Mar 7",
            ),
            const VideoCard(
              "Morning Stretch Routine",
              "Anita Verma • 25:00",
              "312 views",
              "Mar 6",
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
