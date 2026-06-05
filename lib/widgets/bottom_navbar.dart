import 'package:flutter/material.dart';

class BottomNavbar extends StatelessWidget {
  final int? currentIndex;
  final void Function(BuildContext, int)? onTap;

  const BottomNavbar({super.key, this.currentIndex, this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex ?? 0,
      selectedItemColor: currentIndex == null ? Colors.grey : Colors.deepPurple,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      onTap: (index) => onTap?.call(context, index),
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
