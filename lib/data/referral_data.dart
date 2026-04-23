import 'package:flutter/material.dart';
import '../models/referral_stat_model.dart';
import '../models/referral_user_model.dart';
import '../models/badge_model.dart';

class ReferralData {
  static List<ReferralStatModel> stats = [
    ReferralStatModel(
      title: "Total Referrals",
      value: "12",
      icon: Icons.group_outlined,
      borderColor: Color(0xffFFDCC9),
      iconBg: Color(0xffFFE6D8),
      iconColor: Colors.deepOrange,
    ),
    ReferralStatModel(
      title: "Active Referrals",
      value: "8",
      icon: Icons.check_circle_outline,
      borderColor: Color(0xffB7F1C6),
      iconBg: Color(0xffDDF9E5),
      iconColor: Colors.green,
    ),
    ReferralStatModel(
      title: "Total Earned",
      value: "₹ 3600",
      icon: Icons.trending_up,
      borderColor: Color(0xffDCC6E8),
      iconBg: Color(0xffEADAF2),
      iconColor: Colors.purple,
    ),
    ReferralStatModel(
      title: "Available Balance",
      value: "₹ 2400",
      icon: Icons.workspace_premium_outlined,
      borderColor: Color(0xffE4D1FA),
      iconBg: Color(0xffF0E6FD),
      iconColor: Colors.deepPurple,
    ),
  ];

  static List<ReferralUserModel> users = [
    ReferralUserModel(
      name: "Priya Sharma",
      email: "priya.sharma@email.com",
      date: "Joined Mar 1, 2026",
      amount: "₹ 300",
      status: "completed",
      earning: "earned",
    ),
    ReferralUserModel(
      name: "Rahul Kumar",
      email: "rahul.k@email.com",
      date: "Joined Mar 5, 2026",
      amount: "₹ 300",
      status: "active",
      earning: "earned",
    ),
    ReferralUserModel(
      name: "Anita Verma",
      email: "anita.v@email.com",
      date: "Joined Mar 10, 2026",
      amount: "₹ 300",
      status: "pending",
      earning: "pending",
    ),
    ReferralUserModel(
      name: "Vikram Singh",
      email: "vikram.s@email.com",
      date: "Joined Feb 20, 2026",
      amount: "₹ 300",
      status: "completed",
      earning: "redeem",
    ),
    ReferralUserModel(
      name: "Meera Patel",
      email: "meera.p@email.com",
      date: "Joined Feb 15, 2026",
      amount: "₹ 300",
      status: "active",
      earning: "earned",
    ),
  ];

  static List<BadgeModel> badges = [
    BadgeModel(
      title: "First Steps",
      subtitle: "Refer your first friend",
      progressText: "1/1",
      percent: 1200,
      reward: "₹100",
      icon: Icons.adjust,
      color: Colors.green,
      isCompleted: true,
    ),
    BadgeModel(
      title: "Social Butterfly",
      subtitle: "Refer 5 friends",
      progressText: "5/5",
      percent: 240,
      reward: "₹250",
      icon: Icons.person_add,
      color: Colors.blue,
      isCompleted: true,
    ),
    BadgeModel(
      title: "Rising Star",
      subtitle: "Refer 10 friends",
      progressText: "10/10",
      percent: 120,
      reward: "₹500",
      icon: Icons.star,
      color: Colors.orange,
      isCompleted: true,
    ),
    BadgeModel(
      title: "Top Performer",
      subtitle: "Refer 20 friends",
      progressText: "12/20",
      percent: 60,
      reward: "₹1000",
      icon: Icons.leaderboard_outlined,
      color: const Color.fromARGB(255, 102, 102, 102),
      isCompleted: true,
    ),
    BadgeModel(
      title: "Champion",
      subtitle: "Refer 50 friends",
      progressText: "12/50",
      percent: 24,
      reward: "₹2500",
      icon: Icons.favorite,
      color: const Color.fromARGB(255, 102, 102, 102),
      isCompleted: true,
    ),
    BadgeModel(
      title: "Legend",
      subtitle: "Refer 100 friends",
      progressText: "12/100",
      percent: 12,
      reward: "₹5000",
      icon: Icons.king_bed_outlined,
      color: const Color.fromARGB(255, 102, 102, 102),
      isCompleted: true,
    ),
  ];
}
