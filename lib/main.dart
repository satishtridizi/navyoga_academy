import 'package:flutter/material.dart';
import 'package:navyoga_academy/routes/app_routes.dart';
import 'package:navyoga_academy/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

/// ✅ REMOVE FLEX / STRETCH / GLOW EFFECT
class NoGlowScrollBehavior extends ScrollBehavior {
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
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      builder: (context, child) {
        return ScrollConfiguration(
          behavior: const MaterialScrollBehavior().copyWith(overscroll: false),
          child: child!,
        );
      },

      initialRoute: AppRoutes.dashboard,
      routes: AppRoutes.routes,
    );
  }
}
