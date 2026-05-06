import 'package:flutter/material.dart';
import 'package:navyoga_academy/routes/app_routes.dart';

class BottomNavbar extends StatelessWidget {
  final int currentIndex;

  const BottomNavbar({super.key, required this.currentIndex});

  void onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushNamed(context, AppRoutes.myClasses);
        break;

      case 1:
        Navigator.pushNamed(context, AppRoutes.recordings);
        break;

      case 2:
        Navigator.pushNamed(context, AppRoutes.dashboard);
        break;

      case 3:
        Navigator.pushNamed(context, AppRoutes.attendance);
        break;

      case 4:
        Navigator.pushNamed(context, AppRoutes.profile);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,

      selectedItemColor: Colors.deepPurple,
      unselectedItemColor: Colors.grey,

      onTap: (index) => onTap(context, index),

      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.menu_book),
          label: "My Classes",
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.videocam),
          label: "Recordings",
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: "Dashboard",
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: "Attendance",
        ),

        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
      ],
    );
  }
}
