import 'package:flutter/material.dart';
import 'package:navyoga_academy/widgets/bottom_navbar.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    required this.currentIndex,
    this.appBar,
    this.drawer,
    this.backgroundColor,
    this.floatingActionButton,
    this.onBottomNavTap,
  });

  final Widget body;
  final int currentIndex;
  final PreferredSizeWidget? appBar;
  final Widget? drawer;
  final Color? backgroundColor;
  final Widget? floatingActionButton;

  /// Optional custom handler for bottom-navigation taps.
  ///
  /// When this is null, BottomNavbar handles navigation internally.
  final void Function(BuildContext context, int index)? onBottomNavTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? const Color(0xFFF7F7F7),
      appBar: appBar,
      drawer: drawer,
      body: body,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: BottomNavbar(
        currentIndex: currentIndex,
        onTap: onBottomNavTap,
      ),
    );
  }
}