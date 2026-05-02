import 'package:flutter/material.dart';
import 'package:navyoga_academy/screens/attendance.dart';
import 'package:navyoga_academy/screens/events_screen.dart';
import 'package:navyoga_academy/screens/myclasses.dart';
import 'package:navyoga_academy/screens/myprofile.dart';
import 'package:navyoga_academy/screens/payments.dart';
import 'package:navyoga_academy/screens/recording_player_screen.dart';
import 'package:navyoga_academy/screens/recordingscreens.dart';
import 'package:navyoga_academy/screens/redeem_screen.dart';
import 'package:navyoga_academy/screens/referrals.dart';
import 'package:navyoga_academy/screens/self-paced_learning.dart';
import 'package:navyoga_academy/screens/log_in.dart';
import '../screens/live_class_screen.dart';
import '../screens/dashboard.dart';
import '../screens/settings.dart';
import '../screens/myclasses_enroll_screen.dart';

class AppRoutes {
  static const dashboard = "/";
  static const settings = "/settings";
  static const enrollClass = "/enroll-class";
  static const myClasses = "/my-classes";
  static const attendance = "/attendance";
  static const events = "/events";
  static const selfPaced = "/self-paced";
  static const recordings = "/recordings";
  static const learning = "/learning";
  static const referral = "/referral";
  static const payments = "/payments";
  static const liveClass = "/liveClass";
  static const String login = '/login';
  static const recordingPlayer = "/recordingPlayer";
  static const profile = "/profile";
  static const redeem = "/redeem";

  static Map<String, WidgetBuilder> routes = {
    dashboard: (_) => HomeScreen(),

    settings: (_) => const SettingsScreen(),

    enrollClass: (_) => const EnrollScreen(),

    myClasses: (_) => const MyClassesScreen(),

    attendance: (_) => const AttendanceScreen(),

    events: (_) => const EventsScreen(),

    selfPaced: (context) => const SelfPacedLearningScreen(),

    recordings: (context) => const RecordingsDashboard(),

    referral: (_) => const ReferralScreen(),

    payments: (_) => const SubscriptionScreen(),

    liveClass: (_) => const LiveClassScreen(),

    login: (_) => const LoginScreen(),

    profile: (_) => const ProfileScreen(),

    redeem: (_) => const RedeemScreen(),
  };
}
