import 'package:flutter/material.dart';
import 'package:navyoga_academy/routes/app_routes.dart';

class BottomNavbar extends StatelessWidget {
  const BottomNavbar({
    super.key,
    required this.currentIndex,
    this.onTap,
  });

  final int currentIndex;

  /// Optional custom navigation callback.
  ///
  /// When provided, the parent screen controls navigation.
  /// Otherwise, this widget uses the registered named routes.
  final void Function(BuildContext context, int index)? onTap;

  static  List<String> _routes = [
    AppRoutes.myClasses,
    AppRoutes.recordings,
    AppRoutes.dashboard,
    AppRoutes.attendance,
    AppRoutes.profile,
  ];

  void _handleNavigation(
    BuildContext context,
    int selectedIndex,
  ) {
    if (selectedIndex < 0 || selectedIndex >= _routes.length) {
      return;
    }

    // Avoid reopening the screen that is already active.
    if (selectedIndex == currentIndex) {
      return;
    }

    // Allow parent widgets to provide custom navigation.
    if (onTap != null) {
      onTap!(context, selectedIndex);
      return;
    }

    final selectedRoute = _routes[selectedIndex];

    Navigator.of(context).pushReplacementNamed(
      selectedRoute,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: Colors.deepPurple,
      unselectedItemColor: Colors.grey,
      elevation: 12,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      selectedFontSize: 12,
      unselectedFontSize: 12,
      selectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.w500,
      ),
      onTap: (selectedIndex) {
        _handleNavigation(
          context,
          selectedIndex,
        );
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.menu_book_outlined),
          activeIcon: Icon(Icons.menu_book),
          label: 'My Classes',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.video_library_outlined),
          activeIcon: Icon(Icons.video_library),
          label: 'Recordings',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined),
          activeIcon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today_outlined),
          activeIcon: Icon(Icons.calendar_today),
          label: 'Attendance',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}