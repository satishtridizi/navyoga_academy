import 'package:flutter/material.dart';
//import 'package:navyoga_academy/routes/dashboard_routes.dart';
import 'package:navyoga_academy/routes/app_routes.dart';
import 'package:navyoga_academy/screens/attendance.dart';
import 'package:navyoga_academy/screens/dashboard.dart';
import 'package:navyoga_academy/Dashboard/dashboard_menu.dart';
import 'package:navyoga_academy/screens/events_screen.dart';
import 'package:navyoga_academy/screens/myclasses.dart';
import 'package:navyoga_academy/screens/myprofile.dart';
import 'package:navyoga_academy/screens/payments.dart';
import 'package:navyoga_academy/screens/recordingscreens.dart';
import 'package:navyoga_academy/screens/referrals.dart';

import 'package:navyoga_academy/screens/settings.dart';
import 'package:navyoga_academy/screens/admin_signin.dart';
import 'package:navyoga_academy/screens/sign_in.dart';
import 'package:navyoga_academy/screens/super_admin_signin.dart';
import 'package:navyoga_academy/screens/sign_in.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.home,
      routes: AppRoutes.routes,
    );
  }
}
