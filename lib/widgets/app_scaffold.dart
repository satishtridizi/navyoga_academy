import 'package:flutter/material.dart';
import 'package:navyoga_academy/widgets/app_background.dart';
import 'package:navyoga_academy/widgets/bottom_navbar.dart';

class AppScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? drawer;
  final int currentIndex;
  final FloatingActionButton? floatingActionButton;

  const AppScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.drawer,
    required this.currentIndex,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: drawer,
      backgroundColor: Colors.transparent,
      appBar: appBar,

      body: AppBackground(child: body),

      bottomNavigationBar: BottomNavbar(currentIndex: currentIndex),

      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
