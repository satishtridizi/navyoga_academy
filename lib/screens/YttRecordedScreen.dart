import 'package:flutter/material.dart';
import 'package:navyoga_academy/services/payments_service.dart';
import 'package:navyoga_academy/utils/auth_manager.dart';
import 'payments.dart';
import 'package:navyoga_academy/Dashboard/dashboard_menu.dart';

class YttRecordedScreen extends StatefulWidget {
  const YttRecordedScreen({super.key});

  @override
  State<YttRecordedScreen> createState() => _YttRecordedScreenState();
}

class _YttRecordedScreenState extends State<YttRecordedScreen> {
  int modulesCount = 0;
  int classesCount = 0;
  double progress = 0;
  String activePlan = "Not Enrolled";

  @override
  void initState() {
    super.initState();
    loadYttRecordedData();
  }

  Future<void> loadYttRecordedData() async {
    try {
      final token = await AuthManager.getToken();

      if (token == null) return;

      final response = await PaymentsService().getMyYttRecordedEnrollments(
        token,
      );

      print("YTT ENROLLMENTS => $response");

      final List enrollments = response["data"] ?? [];

      if (enrollments.isEmpty) {
        setState(() {
          modulesCount = 0;
          classesCount = 0;
          progress = 0;
          activePlan = "Not Enrolled";
        });
        return;
      }

      final enrollment = enrollments.first;

      setState(() {
        activePlan =
            enrollment["plan"]?["name"] ?? enrollment["planName"] ?? "Enrolled";

        progress = (enrollment["progress"] ?? 0).toDouble();

        modulesCount = enrollment["modulesCount"] ?? 0;

        classesCount = enrollment["classesCount"] ?? 0;
      });
    } catch (e) {
      debugPrint("YTT RECORDED ERROR => $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),

      drawer: const CustomDrawer(currentPage: "YTT Recorded"),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black54),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Image.asset(
          'assets/logo/logo_transparent_clean.png',
          height: 60,
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: const CustomBottomBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(36, 60, 36, 40),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFF36A3D),
                    Color(0xFF6A0DAD),
                    Color(0xFF9C27B0),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.videocam_outlined,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "YTT Recorded",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                height: 1.0,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Self-paced Yoga Teacher Training — your enrolled cohorts",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.3,
                    children: [
                      _StatCard(
                        icon: Icons.menu_book_outlined,
                        title: "Modules",
                        value: modulesCount.toString(),
                      ),
                      _StatCard(
                        icon: Icons.play_circle_outline,
                        title: "Classes",
                        value: classesCount.toString(),
                      ),
                      _StatCard(
                        icon: Icons.trending_up,
                        title: "Progress",
                        value: "${progress.toInt()}%",
                      ),
                      _StatCard(
                        icon: Icons.workspace_premium_outlined,
                        title: "Active Plan",
                        value: activePlan,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Empty State
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 28,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F5F7),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFFB08A)),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE0D5),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.lock_outline,
                        color: Colors.deepOrange,
                        size: 25,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "You're not enrolled in any YTT Recorded course yet",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E1B39),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Enroll in a course from the plans page to unlock its modules and start learning at your own pace.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 20),

                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SubscriptionScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6A0DAD),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      icon: const Icon(Icons.card_membership_outlined),
                      label: const Text(
                        "View YTT Recorded Plans",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 120),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.white.withOpacity(0.15),
            child: Icon(icon, color: Colors.white, size: 16),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFFE6D5F2),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 24,
            ),
          ),
        ],
      ),
    );
  }
}
