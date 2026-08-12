import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:navyoga_academy/routes/app_routes.dart';
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

      scrollBehavior: const NoGlowScrollBehavior(),
      onGenerateRoute: AppRoutes.onGenerateRoute,
      // Flutter otherwise builds every prefix route for an initial route such
      // as /login, which constructs the dashboard (`/`) behind the login page.
      onGenerateInitialRoutes: (initialRoute) => [
        MaterialPageRoute<void>(
          settings: RouteSettings(name: initialRoute),
          builder: (context) => isLoggedIn
              ? AppRoutes.routes[AppRoutes.dashboard]!(context)
              : AppRoutes.routes[AppRoutes.login]!(context),
        ),
      ],
      initialRoute: isLoggedIn
          ? AppRoutes.dashboard
          : AppRoutes.login,

      routes: AppRoutes.routes,
    );
  }
}
