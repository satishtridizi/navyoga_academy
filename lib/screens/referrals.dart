import 'package:flutter/material.dart';
import 'package:navyoga_academy/Dashboard/dashboard_menu.dart';
import 'package:navyoga_academy/widgets/app_background.dart';
import 'package:navyoga_academy/widgets/referral_badge_card.dart';
import 'package:navyoga_academy/widgets/referral_how_it_works_section.dart';
import 'package:navyoga_academy/widgets/referral_invite_section.dart';
import 'package:navyoga_academy/widgets/referral_reward_summary_section.dart';
import 'package:navyoga_academy/widgets/referral_share_section.dart';
import 'package:navyoga_academy/widgets/referral_user_card.dart';
import '../data/referral_data.dart';
import '../widgets/referral_stat_card.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ReferralScreen extends StatelessWidget {
  const ReferralScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      backgroundColor: Colors.transparent,

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

      body: AppBackground(
        child: ListView(
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
            ...ReferralData.stats.asMap().entries.map((entry) {
              final index = entry.key;
              final e = entry.value;

              return Animate(
                delay: Duration(milliseconds: 120 * index),

                effects: const [
                  FadeEffect(duration: Duration(milliseconds: 400)),

                  SlideEffect(
                    begin: Offset(0, 0.15),
                    end: Offset(0, 0),
                    duration: Duration(milliseconds: 400),
                  ),
                ],

                child: ReferralStatCard(stat: e),
              );
            }).toList(),

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
                Chip(label: Text("${ReferralData.users.length} Total")),
              ],
            ),

            const SizedBox(height: 12),

            ...ReferralData.users.asMap().entries.map((entry) {
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

                child: ReferralUserCard(user: e),
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
      ),
    );
  }
}
