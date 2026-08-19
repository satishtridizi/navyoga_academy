import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:navyoga_academy/routes/app_routes.dart';
import 'package:navyoga_academy/screens/splash_screen.dart';
import 'package:navyoga_academy/services/reminder_service.dart';
import 'package:navyoga_academy/utils/auth_manager.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final reminderService = ReminderService();
  await reminderService.init();
  await reminderService.requestPermissions();

  final bool isLoggedIn = await checkLoginStatus();

  runApp(
    MyApp(isLoggedIn: isLoggedIn),
  );
}

Future<bool> checkLoginStatus() async {
  try {
    final String? token = await AuthManager.getToken();
    return token != null && token.trim().isNotEmpty;
  } catch (error) {
    debugPrint('Failed to check login status: $error');
    return false;
  }
}

class NoGlowScrollBehavior extends ScrollBehavior {
  const NoGlowScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({
    super.key,
    required this.isLoggedIn,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 17, height: 1.45, color: Color(0xFF27222C)),
          bodyMedium: TextStyle(fontSize: 15, height: 1.4, color: Color(0xFF27222C)),
          bodySmall: TextStyle(fontSize: 13, height: 1.35, color: Color(0xFF4F4855)),
          titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF211D25)),
          titleMedium: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Color(0xFF211D25)),
        ),
      ),

      scrollBehavior: const NoGlowScrollBehavior(),
      onGenerateRoute: AppRoutes.onGenerateRoute,
      // Flutter otherwise builds every prefix route for an initial route such
      // as /login, which constructs the dashboard (`/`) behind the login page.
      onGenerateInitialRoutes: (initialRoute) => [
        MaterialPageRoute<void>(
          settings: const RouteSettings(name: AppRoutes.splash),
          builder: (context) => SplashScreen(isLoggedIn: isLoggedIn),
        ),
      ],
      initialRoute: AppRoutes.splash,

      routes: AppRoutes.routes,
    );
  }
}
