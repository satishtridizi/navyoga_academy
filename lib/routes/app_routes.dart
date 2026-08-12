import 'package:flutter/material.dart';
import 'package:navyoga_academy/features/live_class/screens/live_class_screen.dart';

import 'package:navyoga_academy/models/class_model.dart';
import 'package:navyoga_academy/models/live_class_arguments.dart';
import 'package:navyoga_academy/models/mylive_class_model.dart';

import 'package:navyoga_academy/screens/YttLiveClassesScreen.dart';
import 'package:navyoga_academy/screens/YttRecordedScreen.dart';
import 'package:navyoga_academy/screens/attendance.dart';
import 'package:navyoga_academy/screens/change_password_screen.dart';
import 'package:navyoga_academy/screens/dashboard.dart';
import 'package:navyoga_academy/screens/enrollment_success_screen.dart';
import 'package:navyoga_academy/screens/events_screen.dart';
import 'package:navyoga_academy/screens/leads_screen.dart';
import 'package:navyoga_academy/screens/live_classes_list.dart';
import 'package:navyoga_academy/screens/log_in.dart';
import 'package:navyoga_academy/screens/myclasses.dart';
import 'package:navyoga_academy/screens/myclasses_enroll_screen.dart';
import 'package:navyoga_academy/screens/myprofile.dart';
import 'package:navyoga_academy/screens/notifications_screen.dart';
import 'package:navyoga_academy/screens/payment_history_screen.dart';
import 'package:navyoga_academy/screens/payment_screen.dart';
import 'package:navyoga_academy/screens/payments.dart';
import 'package:navyoga_academy/screens/recordingscreens.dart';
import 'package:navyoga_academy/screens/redeem_screen.dart';
import 'package:navyoga_academy/screens/referrals.dart';
import 'package:navyoga_academy/screens/self-paced_learning.dart';
import 'package:navyoga_academy/screens/self_paced_progress_screen.dart';
import 'package:navyoga_academy/screens/settings.dart';
import 'package:navyoga_academy/screens/splash_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/splash';
  static const String login = '/login';

  static const String dashboard = '/';
  static const String myClasses = '/my-classes';
  static const String selfPaced = '/self-paced';
  static const String attendance = '/attendance';
  static const String profile = '/profile';

  static const String enrollClass = '/enroll-class';
  static const String liveClass = '/live-class';
  static const String liveClassesList =
      '/live-classes-list';
  static const String enrollmentsuccess =
      '/enrollment-success';

  static const String recordings = '/recordings';
  static const String selfPacedProgress =
      '/self-paced-progress';

  static const String settings = '/settings';
  static const String changePassword =
      '/change-password';
  static const String notifications =
      '/notifications';

  static const String payments = '/payments';
  static const String payment = '/payment';
  static const String paymentHistory =
      '/payment-history';
  static const String redeem = '/redeem';

  static const String events = '/events';
  static const String referral = '/referral';
  static const String leads = '/leads';

  static const String yttLiveClasses =
      '/ytt-live-classes';
  static const String yttRecorded =
      '/ytt-recorded';

  static final Map<String, WidgetBuilder> routes = {
    splash: (_) => const SplashScreen(),
    login: (_) => const LoginScreen(),

    dashboard: (_) => const HomeScreen(),
    myClasses: (_) => const MyClassesScreen(),
    selfPaced: (_) => SelfPacedLearningScreen(),
    attendance: (_) => const AttendanceScreen(),
    profile: (_) => const ProfileScreen(),

    enrollClass: (_) => const EnrollScreen(),

    /*
     * Do not register liveClass here.
     * It requires route arguments.
     */

    liveClassesList: (_) =>
        const LiveClassesListScreen(),

    enrollmentsuccess: (_) =>
        const EnrollmentSuccessScreen(),

    recordings: (_) =>
        const RecordingsDashboard(),

    selfPacedProgress: (_) =>
        const SelfPacedProgressScreen(),

    settings: (_) => const SettingsScreen(),

    changePassword: (_) =>
        const ChangePasswordScreen(),

    notifications: (_) =>
        const NotificationsScreen(),

    payments: (_) =>
        const SubscriptionScreen(),

    payment: (_) => const PaymentScreen(),

    paymentHistory: (_) =>
        const PaymentHistoryScreen(
      payments: [],
    ),

    redeem: (_) => const RedeemScreen(),

    events: (_) => const EventsScreen(),
    referral: (_) => const ReferralScreen(),
    leads: (_) => const LeadsScreen(),

    yttLiveClasses: (_) =>
        const YttLiveClassesScreen(),

    yttRecorded: (_) =>
        const YttRecordedScreen(),
  };

  static Route<dynamic>? onGenerateRoute(
    RouteSettings settings,
  ) {
    switch (settings.name) {
      case liveClass:
        final rawArgs = settings.arguments;
        LiveClassArguments? parsedArgs;

        if (rawArgs is LiveClassArguments) {
          parsedArgs = rawArgs;
        } else if (rawArgs is ClassModel) {
          parsedArgs = LiveClassArguments(
            classId: rawArgs.id,
            studentName: 'Student',
            title: rawArgs.title,
            tutorName: rawArgs.trainer,
            duration: rawArgs.durationMinutes > 0 ? rawArgs.durationMinutes : 60,
          );
        } else if (rawArgs is MyLiveClassModel) {
          parsedArgs = LiveClassArguments(
            classId: rawArgs.id,
            studentName: 'Student',
            title: rawArgs.title,
            tutorName: rawArgs.tutor?.name,
            yogaType: rawArgs.yogaType,
            scheduledAt: rawArgs.scheduledAt,
            duration: rawArgs.duration,
            rawData: rawArgs.rawData,
          );
        } else if (rawArgs is Map) {
          final map = Map<String, dynamic>.from(rawArgs);
          parsedArgs = LiveClassArguments(
            classId: map['_id']?.toString() ??
                map['id']?.toString() ??
                map['classId']?.toString() ??
                '',
            studentName: map['studentName']?.toString() ??
                map['name']?.toString() ??
                'Student',
            title: map['title']?.toString() ??
                map['className']?.toString() ??
                'Live Yoga Class',
            duration: int.tryParse(
                  map['duration']?.toString() ?? '',
                ) ??
                60,
            tutorName: map['trainer']?.toString() ??
                map['tutorName']?.toString() ??
                map['instructor']?.toString(),
            yogaType: map['yogaType']?.toString() ??
                map['type']?.toString(),
            rawData: map,
          );
        }

        if (parsedArgs == null || parsedArgs.classId.isEmpty) {
          return MaterialPageRoute(
            settings: settings,
            builder: (_) {
              return const _InvalidRouteScreen(
                message:
                    'Live-class information is unavailable.',
              );
            },
          );
        }

        return MaterialPageRoute(
          settings: settings,
          builder: (_) {
            return LiveClassScreen(
              arguments: parsedArgs!,
            );
          },
        );

      default:
        return null;
    }
  }
}

class _InvalidRouteScreen
    extends StatelessWidget {
  const _InvalidRouteScreen({
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Unable to open'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            message,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}