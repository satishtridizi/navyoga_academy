import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:navyoga_academy/data/profile_data.dart';
import 'package:navyoga_academy/models/class_model.dart';
import 'package:navyoga_academy/screens/myclasses.dart';
import 'package:navyoga_academy/screens/payments.dart';
import 'package:navyoga_academy/screens/referrals.dart';
import 'package:navyoga_academy/services/attendance_service.dart';
import 'package:navyoga_academy/screens/onboarding_overlay.dart';
import 'package:navyoga_academy/services/leads_service.dart';
import 'package:navyoga_academy/Dashboard/dashboard_menu.dart';
import 'package:navyoga_academy/routes/app_routes.dart';
import 'package:navyoga_academy/services/notification_service.dart';
import 'package:navyoga_academy/services/recording_service.dart';
import 'package:navyoga_academy/services/referral_service.dart';
import 'package:navyoga_academy/services/workshop_service.dart';
import 'package:navyoga_academy/utils/auth_manager.dart';
import 'package:navyoga_academy/widgets/animatedItem.dart';
import 'package:navyoga_academy/widgets/app_scaffold.dart';
import 'package:navyoga_academy/widgets/dashboard_Action_card.dart';
import 'package:navyoga_academy/widgets/dashboard_ReferralCode_card.dart';
import 'package:navyoga_academy/widgets/dashboard_Referral_card.dart';
import 'package:navyoga_academy/widgets/dashboard_ShareEarn_card.dart';
import 'package:navyoga_academy/widgets/achievement_card.dart';
import 'package:navyoga_academy/widgets/dashboard_class_card.dart';
import 'package:navyoga_academy/widgets/dashboard_section_header.dart';
import 'package:navyoga_academy/widgets/dashboard_stat_card.dart';
import 'package:navyoga_academy/models/recording_api_model.dart';
import 'package:navyoga_academy/screens/recording_player_screen.dart';
import 'package:navyoga_academy/models/dashboard_model.dart';
import 'package:navyoga_academy/services/dashboard_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
//import 'package:navyoga_academy/services/enrollment_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showOnboarding = true;
  final PageController _bannerController = PageController();
  bool showOnboarding = false;

  final GlobalKey<OnboardingOverlayState> onboardingKey =
      GlobalKey<OnboardingOverlayState>();
  int currentBanner = 0;
  int unlockedBadges = 0;
  final attendanceService = AttendanceService();
  final recordingService = RecordingService();
  List<dynamic> recordings = [];

  bool showAllUpcoming = false;
  bool showAllVideos = false;
  bool showAllReferral = false;

  final dashboardService = DashboardService();
  final leadsService = LeadsService();
  List<dynamic> upcomingClasses = [];
  List<dynamic> achievements = [];

  Map<String, dynamic>? referralStats;

  String referralCode = "";
  DashboardModel? dashboard;
  int unreadCount = 0;

  int totalReferrals = 0;
  int activeReferrals = 0;
  int totalEarned = 0;
  int availableBalance = 0;
  @override
  void initState() {
    super.initState();

    loadStudentDashboard();
    loadUnreadCount();
    testWorkshops();
    loadReferralStats();
    loadRecordings();

    Future.delayed(const Duration(seconds: 4), autoScrollBanner);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkOnboarding();
    });
  }

  void autoScrollBanner() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 4));

      if (!_bannerController.hasClients) return false;

      if (currentBanner == 1) {
        currentBanner = 0;
      } else {
        currentBanner++;
      }

      _bannerController.animateToPage(
        currentBanner,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );

      return mounted;
    });
  }

  Future<void> testWorkshops() async {
    final token = await AuthManager.getToken();

    if (token == null) return;

    final res = await WorkshopService().getWorkshops(token);

    print("WORKSHOP RESPONSE");
    print(res);
  }

  Future<void> loadStudentDashboard() async {
    final token = await AuthManager.getToken();

    if (token == null || token.isEmpty) {
      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (route) => false,
      );
      return;
    }

    try {
      final res = await dashboardService.getDashboard(token);

      if (res["success"] == true) {
        final data = res["data"];

        print("DASHBOARD METRICS = ${data["metrics"]}");
        print("UPCOMING CLASSES API = ${data["upcomingClasses"]}");
        print("FULL DASHBOARD RESPONSE = $data");

        setState(() {
          dashboard = DashboardModel.fromJson(data["metrics"] ?? {});

          upcomingClasses = data["upcomingClasses"] ?? [];

          achievements = data["achievements"] ?? [];

          referralStats = data["referralStats"];

          referralCode = data["referralStats"]?["referralCode"] ?? "";
        });
        print("Referral Stats = $referralStats");
        print("Referral Code = $referralCode");
      }
    } catch (e) {
      debugPrint("Dashboard Error: $e");
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

  Future<void> loadReferralStats() async {
    final token = await AuthManager.getToken();

    if (token == null) return;

    final res = await ReferralService().getReferrals(token);

    if (res["success"] == true) {
      final items = res["data"]["items"] as List;

      totalReferrals = items.length;

      totalEarned = items.fold<int>(
        0,
        (sum, e) => e["status"].toString().toLowerCase() == "active"
            ? sum + int.parse(e["reward"].toString())
            : sum,
      );

      availableBalance = totalEarned;

      final badgeTargets = [1, 5, 10, 20, 50, 100];

      unlockedBadges = badgeTargets
          .where((target) => totalReferrals >= target)
          .length;

      setState(() {});
    }
  }

  Future<void> loadRecordings() async {
    final token = await AuthManager.getToken();

    if (token == null) return;

    final list = await recordingService.getRecordings(token);

    setState(() {
      recordings = list.map((e) => RecordingApiModel.fromJson(e)).toList();
    });
  }

  Future<void> checkOnboarding() async {
    final prefs = await SharedPreferences.getInstance();

    final shouldShow = prefs.getBool("show_onboarding") ?? false;

    print("Dashboard showOnboarding = $shouldShow");

    if (!mounted) return;

    setState(() {
      showOnboarding = shouldShow;
    });

    if (shouldShow) {
      await prefs.setBool("show_onboarding", false);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget _buildOfferBanner({required String image, bool showButton = true}) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          image: DecorationImage(image: AssetImage(image), fit: BoxFit.cover),
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
                    fontWeight: FontWeight.bold,
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
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            if (showButton)
              Positioned(
                left: 16,
                bottom: 16,
                child: GestureDetector(
                  onTap: () {
                    Clipboard.setData(const ClipboardData(text: "NAVYOGA20"));

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Coupon copied: NAVYOGA20 🎉"),
                      ),
                    );

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SubscriptionScreen(),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.92),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.auto_awesome_motion, color: Colors.purple),
                        SizedBox(width: 6),
                        Text(
                          "Claim Offer Now",
                          style: TextStyle(
                            color: Color(0xff590069),
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
      );
    }

    return Stack(
      children: [
        AppScaffold(
          currentIndex: 2,
          drawer: const CustomDrawer(currentPage: "Dashboard"),

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

            title: Image.asset(
              'assets/logo/logo_transparent_clean.png',
              height: 60,
            ),
            centerTitle: true,

            // 🔥 ADD THIS BLOCK HERE
            actions: [
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications, color: Colors.black),
                    onPressed: () async {
                      await Navigator.pushNamed(
                        context,
                        AppRoutes.notifications,
                      );

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
                        child: SizedBox(
                          height: 220,
                          child: Column(
                            children: [
                              Expanded(
                                child: PageView(
                                  controller: _bannerController,
                                  onPageChanged: (index) {
                                    setState(() {
                                      currentBanner = index;
                                    });
                                  },
                                  children: [
                                    _buildOfferBanner(
                                      image:
                                          "assets/images/woman-practicing-cobra-asana-yoga-600nw-1605427378.webp",
                                      showButton: true,
                                    ),

                                    _buildOfferBanner(
                                      image:
                                          "assets/images/woman-practicing-cobra-asana-yoga-600nw-1605427378.webp",
                                      showButton: false,
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 10),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  2,
                                  (index) => AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    width: currentBanner == index ? 18 : 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: currentBanner == index
                                          ? Colors.deepPurple
                                          : Colors.grey.shade400,
                                      borderRadius: BorderRadius.circular(20),
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
                              "${dashboard?.enrolledClasses ?? 0}",
                              "+${dashboard?.enrolledChangeMonth ?? 0} this month",
                              Color.fromARGB(255, 255, 89, 24),
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.myClasses,
                                );
                              },
                            ),
                          ),
                          AnimatedItem(
                            index: 1,
                            child: StatCard(
                              "Hours Completed",
                              "${dashboard?.hoursCompleted ?? 0}",
                              "+${dashboard?.hoursChangeWeek ?? 0} this week",
                              Color.fromARGB(255, 169, 43, 191),
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.attendance,
                                );
                              },
                            ),
                          ),
                          AnimatedItem(
                            index: 2,
                            child: StatCard(
                              "Recordings Watched",
                              "${dashboard?.recordingsWatched ?? 0}",
                              "+${dashboard?.recordingsChangeWeek ?? 0} this week",
                              Color.fromARGB(255, 43, 191, 117),
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.selfPaced,
                                );
                              },
                            ),
                          ),

                          AnimatedItem(
                            index: 3,
                            child: StatCard(
                              "Attendance Rate",
                              "${dashboard?.attendanceRate ?? 0}%",
                              "+${dashboard?.attendanceImprovement ?? 0}% improvement",
                              Colors.orange,
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.attendance,
                                );
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const MyClassesScreen(),
                            ),
                          );
                        },
                        viewAllText: showAllUpcoming
                            ? "Show Less ↑"
                            : "View All →",
                      ),

                      if (upcomingClasses.isEmpty)
                        Container(
                          padding: const EdgeInsets.only(
                            top: 12,
                            bottom: 8,
                            right: 8,
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            "No upcoming classes scheduled.",
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7A99),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      else
                        Column(
                          children: List.generate(
                            showAllUpcoming
                                ? upcomingClasses.length
                                : (upcomingClasses.length > 2
                                      ? 2
                                      : upcomingClasses.length),
                            (index) {
                              final cls = upcomingClasses[index];

                              return ClassCard(
                                cls["name"] ?? "Class",
                                cls["instructor"] ?? "Instructor",
                                "${cls["duration"] ?? 0} mins",
                                onJoin: () {
                                  final classModel = ClassModel.fromJson(cls);

                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.liveClass,
                                    arguments: classModel,
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 10),

                      // sectionHeader(
                      //   Icons.videocam,
                      //   "Recent Recordings",
                      //   onViewAllTap: () {
                      //     Navigator.pushNamed(context, AppRoutes.recordings);
                      //   },
                      //   viewAllText: "View All →",
                      // ),

                      // const SizedBox(height: 10),

                      // Column(
                      //   children: List.generate(
                      //     recordings.length > 3 ? 3 : recordings.length,
                      //     (index) {
                      //       final recording = recordings[index];

                      //       return Card(
                      //         margin: const EdgeInsets.only(bottom: 12),
                      //         child: ListTile(
                      //           leading: const Icon(
                      //             Icons.play_circle_fill,
                      //             color: Colors.deepPurple,
                      //           ),
                      //           title: Text(recording.title),
                      //           subtitle: Text(recording.yogaType),
                      //           trailing: const Icon(
                      //             Icons.arrow_forward_ios,
                      //             size: 16,
                      //           ),
                      //           onTap: () {
                      //             Navigator.push(
                      //               context,
                      //               MaterialPageRoute(
                      //                 builder: (_) => RecordingPlayerScreen(
                      //                   recording: recording,
                      //                 ),
                      //               ),
                      //             );
                      //           },
                      //         ),
                      //       );
                      //     },
                      //   ),
                      // ),

                      // /// 🏆 ACHIEVEMENTS
                      // sectionHeader(
                      //   Icons.emoji_events,
                      //   "Your Achievements",
                      //   onViewAllTap: () {
                      //     Navigator.pushNamed(context, AppRoutes.profile);
                      //   },
                      //   viewAllText: "View All →",
                      // ),
                      // const SizedBox(height: 10),

                      // if (achievements.isEmpty)
                      //   const Center(child: Text("No achievements found"))
                      // else
                      //   Column(
                      //     children: achievements.map((achievement) {
                      //       return GestureDetector(
                      //         onTap: () {
                      //           Navigator.pushNamed(context, AppRoutes.profile);
                      //         },
                      //         child: AchievementCard(data: achievement),
                      //       );
                      //     }).toList(),
                      //   ),
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
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const MyClassesScreen(),
                                  ),
                                );
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
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.selfPaced,
                                );
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
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.attendance,
                                );
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ReferralScreen(),
                            ),
                          );
                        },
                        viewAllText: "View All →",
                      ),

                      const SizedBox(height: 10),

                      if (referralStats != null)
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.0,
                          children: [
                            ReferralCard(
                              totalReferrals.toString(),
                              "Total Referrals",
                              Colors.blue,
                              "Total",
                            ),

                            ReferralCard(
                              "$unlockedBadges/6",
                              "Achievement Badges",
                              Colors.amber,
                              "Unlocked",
                            ),

                            ReferralCard(
                              "₹$totalEarned",
                              "Total Earned",
                              Colors.orange,
                              "Earned",
                            ),

                            ReferralCard(
                              "₹$availableBalance",
                              "Available Balance",
                              Colors.purple,
                              "Balance",
                            ),
                          ],
                        ),
                      const SizedBox(height: 20),
                      ReferralCodeCard(referralCode: referralCode),
                      const ShareEarnCard(),
                    ],
                  ),
                ),
        ),
        if (showOnboarding)
          OnboardingOverlay(
            key: onboardingKey,
            onFinished: () {
              setState(() {
                showOnboarding = false;
              });
            },
          ),
      ],
    );
  }
}
