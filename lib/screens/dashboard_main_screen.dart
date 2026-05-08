import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:navyoga_academy/data/dashboard_data.dart';
import 'package:navyoga_academy/models/recording_model.dart';
import 'package:navyoga_academy/routes/app_routes.dart';
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
import 'package:navyoga_academy/utils/app_snackbar.dart';

class DashboardMainScreen extends StatefulWidget {
  const DashboardMainScreen({super.key});

  @override
  State<DashboardMainScreen> createState() => _DashboardMainScreenState();
}

class _DashboardMainScreenState extends State<DashboardMainScreen> {
  bool showAllUpcoming = false;
  bool showAllVideos = false;
  bool showAllReferral = false;
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
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
                  child: GestureDetector(
                    onTap: () {
                      const offerText = "NAVYOGA20"; // better real coupon

                      Clipboard.setData(const ClipboardData(text: offerText));

                      AppSnackbar.showError(
                        context,
                        "Coupon copied: NAVYOGA20 🎉",
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Coupon copied: NAVYOGA20 🎉"),
                        ),
                      );
                    },
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
                  Navigator.pushNamed(context, AppRoutes.myClasses);
                },
              ),

              StatCard(
                "Hours Completed",
                "124",
                "+18 this week",
                Color.fromARGB(255, 169, 43, 191),
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.selfPaced);
                },
              ),

              StatCard(
                "Recordings Watched",
                "45",
                "+8 this week",
                Color.fromARGB(255, 43, 191, 117),
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.recordings);
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
          sectionHeader(
            Icons.calendar_today,
            "Upcoming Classes",
            onViewAllTap: () {
              setState(() {
                showAllUpcoming = !showAllUpcoming; // 👈 TOGGLE
              });
            },
          ),

          const SizedBox(height: 10),

          Column(
            children: List.generate(
              showAllUpcoming ? HomeData.classes.length : 2,
              (index) {
                final c = HomeData.classes[index];

                return ClassCard(
                  c.title,
                  "${c.trainer} • ${c.schedule}",
                  c.duration,
                  onJoin: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.liveClass,
                      arguments: c, // pass model if needed
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 30),

          /// 🎥 RECORDINGS
          sectionHeader(
            Icons.videocam,
            "Recent Recordings",
            onViewAllTap: () {
              setState(() {
                showAllVideos = !showAllVideos;
              });
            },
            viewAllText: showAllVideos ? "Show Less ↑" : "View All →",
          ),

          const SizedBox(height: 10),

          Column(
            children: List.generate(
              showAllVideos ? HomeData.videos.length : 2,
              (index) {
                final v = HomeData.videos[index];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: VideoCard(
                    v.title,
                    "${v.trainer} • ${v.duration}",
                    v.views,
                    v.date,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RecordingPlayerScreen(
                            recording: RecordingModel(
                              title: v.title,
                              trainer: "${v.trainer} • ${v.duration}".split(
                                " • ",
                              )[0], // quick extract
                              category: "Yoga",
                              duration: "${v.trainer} • ${v.duration}".split(
                                " • ",
                              )[1],
                              rating: "4.8",
                              views: v.views,
                              date: v.date,
                              color: Colors.purple,
                              isCompleted: false,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 30),

          /// 🏆 ACHIEVEMENTS
          sectionHeader(
            Icons.calendar_today,
            "Your Achievements",
            showViewAll: false,
          ),
          const SizedBox(height: 10),

          GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.profile,
                arguments: "achievements", // 👈 IMPORTANT
              );
            },
            child: const AchievementCard(
              "30-Day Streak",
              "Attended classes for 30 consecutive days",
              Color.fromARGB(255, 245, 135, 102),
              true,
            ),
          ),

          GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.profile,
                arguments: "achievements",
              );
            },
            child: const AchievementCard(
              "Early Bird",
              "Attended 10 morning classes",
              Color.fromARGB(255, 48, 175, 52),
              true,
            ),
          ),

          GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.profile,
                arguments: "achievements",
              );
            },
            child: const AchievementCard(
              "Meditation Master",
              "Completed 20 sessions",
              Colors.grey,
              false,
            ),
          ),
          const SizedBox(height: 30),

          /// ACTIONS
          ActionCard(
            "Browse Classes",
            "Explore available courses",
            Colors.deepOrange,
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.myClasses);
            },
          ),
          ActionCard(
            "Self-Paced",
            "Learn at your pace",
            Colors.purple,
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.selfPaced);
            },
          ),

          ActionCard(
            "Watch Recordings",
            "Catch up on sessions",
            Colors.pink,
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.recordings);
            },
          ),

          ActionCard(
            "View Attendance",
            "Track your progress",
            Colors.green,
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.attendance);
            },
          ),

          ActionCard(
            "My Profile",
            "Update your details",
            Colors.orange,
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.profile);
            },
          ),

          const SizedBox(height: 30),

          /// REFERRAL
          sectionHeader(
            Icons.card_giftcard,
            "Referral Program",
            onViewAllTap: () {
              setState(() {
                showAllReferral = !showAllReferral;
              });
            },
            viewAllText: showAllReferral ? "Show Less ↑" : "View All →",
          ),

          const SizedBox(height: 10),

          Column(
            children: List.generate(
              showAllReferral ? HomeData.referrals.length : 2,
              (index) {
                final r = HomeData.referrals[index];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.referral);
                    },
                    child: ReferralCard(r.value, r.title, r.color, r.status),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),

          const ReferralCodeCard(),
          const ShareEarnCard(),
        ],
      ),
    );
  }
}
