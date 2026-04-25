import 'package:flutter/material.dart';
import 'package:navyoga_academy/routes/app_routes.dart';
import 'package:navyoga_academy/screens/myclasses.dart';
import 'package:navyoga_academy/screens/myprofile.dart';
import 'package:navyoga_academy/screens/attendance.dart';
import 'package:navyoga_academy/screens/payments.dart';
import 'package:navyoga_academy/screens/self-paced_learning.dart';
import 'package:navyoga_academy/screens/recordingscreens.dart';
import 'package:navyoga_academy/screens/referrals.dart';
import 'package:navyoga_academy/screens/log_in.dart';

class DashboardButton extends StatelessWidget {
  const DashboardButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.dashboard);
      },
      child: Container(
        height: 70,
        width: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 12),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.dashboard, color: Colors.deepPurple),
            SizedBox(height: 2),
            Text("Dashboard", style: TextStyle(fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

class CustomBottomBar extends StatelessWidget {
  const CustomBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 12),
        ],
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [
          BottomItem(Icons.menu_book, "My Classes"),
          BottomItem(Icons.videocam, "Recordings"),

          SizedBox(width: 50), // space for FAB

          BottomItem(Icons.calendar_today, "Attendance"),
          BottomItem(Icons.person_outline, "Profile"),
        ],
      ),
    );
  }
}

class BottomItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const BottomItem(this.icon, this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (label == "My Classes") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MyClassesScreen()),
          );
        } else if (label == "Recordings") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RecordingsDashboard()),
          );
        } else if (label == "Attendance") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AttendanceScreen()),
          );
        } else if (label == "Profile") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfileScreen()),
          );
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.deepPurple),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> menuItems = [
      {"icon": Icons.dashboard, "title": "Dashboard", "active": true},
      {"icon": Icons.menu_book, "title": "My Classes"},
      {"icon": Icons.school, "title": "Self-Paced"},
      {"icon": Icons.videocam, "title": "Recordings"},
      {"icon": Icons.calendar_today, "title": "Attendance"},
      {"icon": Icons.event, "title": "Events"},
      {"icon": Icons.card_giftcard, "title": "Referrals"},
      {"icon": Icons.person_outline, "title": "Profile"},
      {"icon": Icons.payment, "title": "Payments"},
      {"icon": Icons.settings, "title": "Settings"},
    ];

    return Drawer(
      backgroundColor: const Color(0xfff7f7f7),
      child: Column(
        children: [
          const SizedBox(height: 40),

          /// 🔝 HEADER
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.deepPurple,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white),
            ),
            title: const Text(
              "NavYoga",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange,
                fontSize: 18,
              ),
            ),
            subtitle: Container(
              margin: const EdgeInsets.only(top: 6),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "Student Portal",
                style: TextStyle(fontSize: 12),
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          const Divider(),

          /// 🔥 MENU LIST (DYNAMIC)
          Expanded(
            child: ListView.builder(
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems[index];
                final bool isActive = item["active"] == true;

                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: isActive
                        ? const LinearGradient(
                            colors: [Colors.deepPurple, Colors.purple],
                          )
                        : null,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ListTile(
                    leading: Icon(
                      item["icon"],
                      color: isActive ? Colors.white : Colors.blueGrey,
                    ),
                    title: Text(
                      item["title"],
                      style: TextStyle(
                        color: isActive ? Colors.white : Colors.blueGrey,
                        fontWeight: isActive
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);

                      if (item["title"] == "Dashboard") {
                        Navigator.pushNamed(context, AppRoutes.dashboard);
                      } else if (item["title"] == "My Classes") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MyClassesScreen(),
                          ),
                        );
                      } else if (item["title"] == "Self-Paced") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SelfPacedLearningScreen(),
                          ),
                        );
                      } else if (item["title"] == "Recordings") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RecordingsDashboard(),
                          ),
                        );
                      } else if (item["title"] == "Referrals") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ReferralScreen(),
                          ),
                        );
                      } else if (item["title"] == "Events") {
                        Navigator.pushNamed(context, AppRoutes.events);
                      } else if (item["title"] == "Profile") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProfileScreen(),
                          ),
                        );
                      } else if (item["title"] == "Settings") {
                        Navigator.pushNamed(context, AppRoutes.settings);
                      } else if (item["title"] == "Attendance") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AttendanceScreen(),
                          ),
                        );
                      } else if (item["title"] == "Payments") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SubscriptionScreen(),
                          ),
                        );
                      }
                    },
                  ),
                );
              },
            ),
          ),

          const Divider(),

          /// 🚪 LOGOUT
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.blueGrey),
            title: const Text("Logout"),
            onTap: () {
              Navigator.pop(context); // close drawer

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false, // removes all previous routes
              );
            },
          ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
