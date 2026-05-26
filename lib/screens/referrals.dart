import 'package:flutter/material.dart';
import 'package:navyoga_academy/Dashboard/dashboard_menu.dart';
import 'package:navyoga_academy/utils/auth_manager.dart';
import 'package:navyoga_academy/widgets/app_background.dart';
import 'package:navyoga_academy/widgets/app_scaffold.dart';
import 'package:navyoga_academy/widgets/referral_badge_card.dart';
import 'package:navyoga_academy/widgets/referral_how_it_works_section.dart';
import 'package:navyoga_academy/widgets/referral_invite_section.dart';
import 'package:navyoga_academy/widgets/referral_reward_summary_section.dart';
import 'package:navyoga_academy/widgets/referral_share_section.dart';
import 'package:navyoga_academy/widgets/referral_user_card.dart';
import '../data/referral_data.dart';
import '../models/referral_user_model.dart';
import '../widgets/referral_stat_card.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:navyoga_academy/models/referral_api_model.dart';
import 'package:navyoga_academy/services/referral_service.dart';
import 'package:navyoga_academy/utils/app_snackbar.dart';
import '../models/referral_stat_model.dart';

class ReferralScreen extends StatefulWidget {
  const ReferralScreen({super.key});

  @override
  State<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen> {
  int totalReferrals = 0;
  int activeReferrals = 0;
  int totalEarned = 0;
  int availableBalance = 0;
  final service = ReferralService();
  List referrals = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadReferrals();
  }

  Future<void> loadReferrals() async {
    final token = await AuthManager.getToken();

    if (token == null) return;

    final res = await service.getReferrals(token);

    if (res["success"] == true) {
      final data = res["data"];

      final List referralList = data["items"]; // ✅ FIXED
      final overview = data["overview"]; // ✅ FIXED

      setState(() {
        referrals = referralList
            .map((e) => ReferralApiModel.fromJson(e))
            .toList();

        totalReferrals = overview["totalReferrals"];
        activeReferrals = overview["active"];
        totalEarned = overview["totalEarned"];
        availableBalance = overview["totalEarned"]; // adjust later if needed

        isLoading = false;
      });
    } else {
      AppSnackbar.showError(
        context,
        res["message"] ?? "Failed to load referrals",
      );
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentIndex: 2,
      drawer: const CustomDrawer(),

      // backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black54),
            onPressed: () {
              Scaffold.of(context).openDrawer(); // ✅ opens drawer
            },
          ),
        ),
        title: const Text(
          "NavYoga Academy",
          style: TextStyle(
            color: Colors.deepOrange,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              children: [
                /// ================= HEADER =================
                Animate(
                  effects: const [
                    FadeEffect(duration: Duration(milliseconds: 500)),

                    SlideEffect(
                      begin: Offset(0, 0.2),
                      end: Offset(0, 0),
                      duration: Duration(milliseconds: 500),
                    ),
                  ],

                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(
                          Icons.card_giftcard,
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
                              "Referral Program",
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepOrange,
                              ),
                            ),
                            Text(
                              "Invite friends and earn rewards together",
                              style: TextStyle(color: Colors.blueGrey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                /// ================= STATS =================
                Column(
                  children: [
                    ReferralStatCard(
                      stat: ReferralStatModel(
                        title: "Total Referrals",
                        value: totalReferrals.toString(), // ✅ FIX
                        icon: Icons.people,
                        borderColor: Colors.blue,
                        iconBg: Colors.blue.shade50,
                        iconColor: Colors.blue,
                      ),
                    ),
                    ReferralStatCard(
                      stat: ReferralStatModel(
                        title: "Active Referrals",
                        value: activeReferrals.toString(), // ✅ FIX
                        icon: Icons.check_circle,
                        borderColor: Colors.green,
                        iconBg: Colors.green.shade50,
                        iconColor: Colors.green,
                      ),
                    ),
                    ReferralStatCard(
                      stat: ReferralStatModel(
                        title: "Total Earned",
                        value: "₹$totalEarned", // ✅ optional formatting
                        icon: Icons.currency_rupee,
                        borderColor: Colors.orange,
                        iconBg: Colors.orange.shade50,
                        iconColor: Colors.orange,
                      ),
                    ),
                    ReferralStatCard(
                      stat: ReferralStatModel(
                        title: "Available Balance",
                        value: "₹$availableBalance",
                        icon: Icons.account_balance_wallet,
                        borderColor: Colors.purple,
                        iconBg: Colors.purple.shade50,
                        iconColor: Colors.purple,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                /// ================= BADGES =================
                const Text(
                  "Achievement Badges",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange,
                  ),
                ),

                const SizedBox(height: 16),

                ...ReferralData.badges.asMap().entries.map((entry) {
                  final index = entry.key;
                  final e = entry.value;

                  return Animate(
                    delay: Duration(milliseconds: 150 * index),

                    effects: const [
                      FadeEffect(duration: Duration(milliseconds: 500)),

                      ScaleEffect(
                        begin: Offset(0.95, 0.95),
                        end: Offset(1, 1),
                        duration: Duration(milliseconds: 500),
                      ),
                    ],

                    child: BadgeCard(badge: e),
                  );
                }).toList(),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Your Referrals",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange,
                      ),
                    ),
                    Chip(label: Text("${referrals.length} Total")),
                  ],
                ),

                const SizedBox(height: 12),

                ...referrals.asMap().entries.map((entry) {
                  final index = entry.key;
                  final e = entry.value;

                  return Animate(
                    delay: Duration(milliseconds: 100 * index),

                    effects: const [
                      FadeEffect(duration: Duration(milliseconds: 400)),

                      SlideEffect(
                        begin: Offset(0, 0.12),
                        end: Offset(0, 0),
                        duration: Duration(milliseconds: 400),
                      ),
                    ],

                    child: ReferralUserCard(
                      user: ReferralUserModel(
                        earning: e.reward,
                        amount: e.reward,
                        name: e.name,

                        email: "",

                        status: e.status,

                        date: e.joinedDate,
                      ),
                    ),
                  );
                }).toList(),

                const SizedBox(height: 20),

                Animate(
                  effects: const [
                    FadeEffect(duration: Duration(milliseconds: 500)),
                  ],
                  child: ShareSection(),
                ),

                const SizedBox(height: 20),

                Animate(
                  delay: const Duration(milliseconds: 100),
                  effects: const [
                    FadeEffect(duration: Duration(milliseconds: 500)),
                    SlideEffect(begin: Offset(0, 0.1), end: Offset(0, 0)),
                  ],
                  child: HowItWorksSection(),
                ),

                const SizedBox(height: 20),

                Animate(
                  delay: const Duration(milliseconds: 200),
                  effects: const [
                    FadeEffect(duration: Duration(milliseconds: 500)),
                    SlideEffect(begin: Offset(0, 0.1), end: Offset(0, 0)),
                  ],
                  child: RewardSummarySection(),
                ),

                const SizedBox(height: 20),

                Animate(
                  delay: const Duration(milliseconds: 300),
                  effects: const [
                    FadeEffect(duration: Duration(milliseconds: 500)),
                    ScaleEffect(begin: Offset(0.97, 0.97), end: Offset(1, 1)),
                  ],
                  child: InviteSection(),
                ),
              ],
            ),
    );
  }
}
