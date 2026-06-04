import 'package:flutter/material.dart';
import 'package:navyoga_academy/screens/attendance.dart';
import 'package:navyoga_academy/screens/change_password_screen.dart';

import 'package:navyoga_academy/screens/events_screen.dart';
import 'package:navyoga_academy/screens/leads_screen.dart';
import 'package:navyoga_academy/screens/live_classes_list.dart';
import 'package:navyoga_academy/screens/myclasses.dart';
import 'package:navyoga_academy/screens/myprofile.dart';
import 'package:navyoga_academy/screens/notifications_screen.dart';
import 'package:navyoga_academy/screens/payment_history_screen.dart';
import 'package:navyoga_academy/screens/payments.dart';
import 'package:navyoga_academy/screens/recordingscreens.dart';
import 'package:navyoga_academy/screens/redeem_screen.dart';
import 'package:navyoga_academy/screens/referrals.dart';
import 'package:navyoga_academy/screens/self-paced_learning.dart';
import 'package:navyoga_academy/screens/log_in.dart';
import 'package:navyoga_academy/screens/splash_screen.dart';
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
  static const paymentHistory = "/paymentHistory";
  static const splash = "/splash";
  static const leads = "/leads";
  static const notifications = "/notifications";

  static const liveClassesList = "/live-classes-list";
  static const changePassword = "/change-password";

  static Map<String, WidgetBuilder> routes = {
    splash: (_) => const SplashScreen(),

    login: (_) => const LoginScreen(),

    dashboard: (_) => const HomeScreen(),

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

    profile: (_) => const ProfileScreen(),

    redeem: (_) => const RedeemScreen(),

    AppRoutes.paymentHistory: (context) =>
        const PaymentHistoryScreen(payments: []),

    '/leads': (context) => const LeadsScreen(),

    notifications: (_) => const NotificationsScreen(),

    liveClassesList: (_) => const LiveClassesListScreen(),

    changePassword: (_) => const ChangePasswordScreen(),
  };
}
