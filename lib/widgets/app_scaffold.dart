import 'package:flutter/material.dart';
import 'package:navyoga_academy/widgets/app_background.dart';
import 'package:navyoga_academy/widgets/bottom_navbar.dart';
import 'package:navyoga_academy/routes/app_routes.dart';

class AppScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? drawer;
  final int? currentIndex;
  final FloatingActionButton? floatingActionButton;

  const AppScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.drawer,
    this.currentIndex,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: drawer,
      backgroundColor: Colors.transparent,
      appBar: appBar,

      body: AppBackground(child: body),

      bottomNavigationBar: BottomNavbar(
        currentIndex: currentIndex,
        onTap: (context, index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, AppRoutes.myClasses);
              break;

            case 1:
              Navigator.pushReplacementNamed(context, AppRoutes.recordings);
              break;

            case 2:
              Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
              break;

            case 3:
              Navigator.pushReplacementNamed(context, AppRoutes.attendance);
              break;

            case 4:
              Navigator.pushReplacementNamed(context, AppRoutes.profile);
              break;
          }
        },
      ),
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
