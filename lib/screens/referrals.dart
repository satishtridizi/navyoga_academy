import 'package:flutter/material.dart';
import 'package:navyoga_academy/Dashboard/dashboard_menu.dart';
import '../models/badge_model.dart';
import 'package:navyoga_academy/widgets/referral_badge_card.dart';
import 'package:navyoga_academy/widgets/referral_how_it_works_section.dart';
import 'package:navyoga_academy/widgets/referral_invite_section.dart';
import 'package:navyoga_academy/widgets/referral_reward_summary_section.dart';
import 'package:navyoga_academy/widgets/referral_share_section.dart';
import 'package:navyoga_academy/widgets/referral_user_card.dart';
import '../data/referral_data.dart';
import '../widgets/referral_stat_card.dart';

class ReferralScreen extends StatelessWidget {
  const ReferralScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      backgroundColor: const Color(0xffF7F8FC),

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

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          /// ================= HEADER =================
          Row(
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

          const SizedBox(height: 25),

          /// ================= STATS =================
          ...ReferralData.stats.map((e) => ReferralStatCard(stat: e)).toList(),

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

          ...ReferralData.badges.map((e) => BadgeCard(badge: e)).toList(),

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

          ...ReferralData.users.map((e) => ReferralUserCard(user: e)).toList(),

          const SizedBox(height: 20),

          ShareSection(),

          const SizedBox(height: 20),

          HowItWorksSection(),

          const SizedBox(height: 20),

          RewardSummarySection(),

          const SizedBox(height: 20),

          InviteSection(),
        ],
      ),
    );
  }
}
