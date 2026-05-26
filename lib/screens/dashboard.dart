import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:navyoga_academy/models/class_model.dart';
import 'package:navyoga_academy/services/attendance_service.dart';
import 'package:navyoga_academy/services/leads_service.dart';
import 'package:navyoga_academy/Dashboard/dashboard_menu.dart';
import 'package:navyoga_academy/data/dashboard_data.dart';
import 'package:navyoga_academy/models/recording_model.dart';
import 'package:navyoga_academy/routes/app_routes.dart';
import 'package:navyoga_academy/screens/recording_player_screen.dart';
import 'package:navyoga_academy/services/notification_service.dart';
import 'package:navyoga_academy/services/recording_service.dart';
import 'package:navyoga_academy/utils/api_helper.dart';
import 'package:navyoga_academy/utils/auth_manager.dart';
import 'package:navyoga_academy/widgets/animatedItem.dart';
import 'package:navyoga_academy/widgets/app_scaffold.dart';
import 'package:navyoga_academy/widgets/dashboard_Action_card.dart';
import 'package:navyoga_academy/widgets/dashboard_ReferralCode_card.dart';
import 'package:navyoga_academy/widgets/dashboard_Referral_card.dart';
import 'package:navyoga_academy/widgets/dashboard_ShareEarn_card.dart';
import 'package:navyoga_academy/widgets/dashboard_achievement_card.dart';
import 'package:navyoga_academy/widgets/dashboard_class_card.dart';
import 'package:navyoga_academy/widgets/dashboard_section_header.dart';
import 'package:navyoga_academy/widgets/dashboard_stat_card.dart';
import 'package:navyoga_academy/widgets/dashboard_video_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:navyoga_academy/models/dashboard_model.dart';
import 'package:navyoga_academy/services/dashboard_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final attendanceService = AttendanceService();
  final recordingService = RecordingService();

  bool showAllUpcoming = false;
  bool showAllVideos = false;
  bool showAllReferral = false;

  final dashboardService = DashboardService();
  final leadsService = LeadsService();

  DashboardModel? dashboard;
  int unreadCount = 0;
  @override
  void initState() {
    super.initState();

    loadStudentDashboard();
    loadUnreadCount();
  }

  Future<void> loadStudentDashboard() async {
    final token = await AuthManager.getToken();

    if (token == null) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
      return;
    }

    try {
      final attendanceList = await attendanceService.getAttendance(token);
      final recordingsList = await recordingService.getRecordings(token);

      int recordingsWatched = recordingsList.length;

      int total = attendanceList.length;

      int present = attendanceList
          .where((e) => e["status"] == "PRESENT")
          .length;

      int attendanceRate = total == 0 ? 0 : ((present / total) * 100).toInt();

      setState(() {
        dashboard = DashboardModel(
          enrolledClasses: attendanceList.length,
          practiceHours: 0,
          recordingsWatched: recordingsWatched,
          attendanceRate: attendanceRate,
        );
      });
    } catch (e) {
      setState(() {
        dashboard = DashboardModel(
          enrolledClasses: 0,
          practiceHours: 0,
          recordingsWatched: 0,
          attendanceRate: 0,
        );
      });
    }
  }

  Future<void> loadUnreadCount() async {
    final token = await AuthManager.getToken();

    if (token == null) return;

    // ✅ FIRST declare
    final list = await NotificationService().getNotifications(token);

    setState(() {
      unreadCount = list.where((n) => n["isRead"] == false).length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentIndex: 2,
      drawer: const CustomDrawer(),

      //  backgroundColor: Color(0xffF7F7F7),
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

        // 🔥 ADD THIS BLOCK HERE
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications, color: Colors.black),
                onPressed: () async {
                  await Navigator.pushNamed(context, AppRoutes.notifications);

                  loadUnreadCount(); // 🔥 refresh after back
                },
              ),

              if (unreadCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$unreadCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),

      body: dashboard == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 10),
                  Text("Loading dashboard..."),
                ],
              ),
            )
          : SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  /// 🔥 BANNER
                  AnimatedItem(
                    index: 0,
                    child: Container(
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
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
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
                                const offerText = "NAVYOGA20";

                                // copy
                                Clipboard.setData(
                                  const ClipboardData(text: offerText),
                                );

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Coupon copied: NAVYOGA20 🎉",
                                    ),
                                  ),
                                );

                                // 🔥 ADD THIS NAVIGATION
                                Navigator.pushNamed(context, AppRoutes.coupons);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.92),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.auto_awesome_motion,
                                      color: Colors.purple,
                                    ),
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
                      AnimatedItem(
                        index: 0,
                        child: StatCard(
                          "Enrolled Classes",
                          dashboard?.enrolledClasses.toString() ?? "0",
                          "+2 this month",
                          Color.fromARGB(255, 255, 89, 24),
                          onTap: () {
                            Navigator.pushNamed(context, AppRoutes.myClasses);
                          },
                        ),
                      ),
                      AnimatedItem(
                        index: 1,
                        child: StatCard(
                          "Hours Completed",
                          dashboard?.practiceHours.toString() ?? "0",
                          "+18 this week",
                          Color.fromARGB(255, 169, 43, 191),
                          onTap: () {
                            Navigator.pushNamed(context, AppRoutes.selfPaced);
                          },
                        ),
                      ),
                      AnimatedItem(
                        index: 2,
                        child: StatCard(
                          "Recordings Watched",
                          dashboard?.recordingsWatched.toString() ?? "0",
                          "+8 this week",
                          Color.fromARGB(255, 43, 191, 117),
                          onTap: () {
                            Navigator.pushNamed(context, AppRoutes.recordings);
                          },
                        ),
                      ),

                      AnimatedItem(
                        index: 3,
                        child: StatCard(
                          "Attendance Rate",
                          "${dashboard?.attendanceRate ?? 0}%",
                          "+5% improvement",
                          Colors.orange,
                          onTap: () {
                            Navigator.pushNamed(context, AppRoutes.attendance);
                          },
                        ),
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

                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      "Live classes will be available soon",
                      style: TextStyle(color: Colors.grey),
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

                        return AnimatedItem(
                          index: index,
                          child: Padding(
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
                                        trainer: "${v.trainer} • ${v.duration}"
                                            .split(" • ")[0], // quick extract
                                        category: "Yoga",
                                        duration: "${v.trainer} • ${v.duration}"
                                            .split(" • ")[1],
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

                  Column(
                    children: [
                      AnimatedItem(
                        index: 0,
                        child: GestureDetector(
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
                      ),
                      AnimatedItem(
                        index: 1,
                        child: GestureDetector(
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
                      ),
                      AnimatedItem(
                        index: 2,
                        child: GestureDetector(
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
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  /// ACTIONS
                  Column(
                    children: [
                      AnimatedItem(
                        index: 0,
                        child: ActionCard(
                          "Browse Classes",
                          "Explore available courses",
                          Colors.deepOrange,
                          onTap: () {
                            Navigator.pushNamed(context, AppRoutes.myClasses);
                          },
                        ),
                      ),
                      AnimatedItem(
                        index: 1,
                        child: ActionCard(
                          "Self-Paced",
                          "Learn at your pace",
                          Colors.purple,
                          onTap: () {
                            Navigator.pushNamed(context, AppRoutes.selfPaced);
                          },
                        ),
                      ),
                      AnimatedItem(
                        index: 2,
                        child: ActionCard(
                          "Watch Recordings",
                          "Catch up on sessions",
                          Colors.pink,
                          onTap: () {
                            Navigator.pushNamed(context, AppRoutes.recordings);
                          },
                        ),
                      ),
                      AnimatedItem(
                        index: 3,
                        child: ActionCard(
                          "View Attendance",
                          "Track your progress",
                          Colors.green,
                          onTap: () {
                            Navigator.pushNamed(context, AppRoutes.attendance);
                          },
                        ),
                      ),
                      AnimatedItem(
                        index: 4,
                        child: ActionCard(
                          "My Profile",
                          "Update your details",
                          Colors.orange,
                          onTap: () {
                            Navigator.pushNamed(context, AppRoutes.profile);
                          },
                        ),
                      ),
                    ],
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

                        return AnimatedItem(
                          index: index,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.referral,
                                );
                              },
                              child: ReferralCard(
                                r.value,
                                r.title,
                                r.color,
                                r.status,
                              ),
                            ),
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
            ),
    );
  }
}
