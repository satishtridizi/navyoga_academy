import 'package:flutter/material.dart';
import 'package:navyoga_academy/Dashboard/dashboard_menu.dart';
import 'package:navyoga_academy/widgets/settings_notification_tile.dart';
import 'package:navyoga_academy/widgets/settings_payment_section.dart';
import 'package:navyoga_academy/widgets/settings_privacy_section.dart';
import 'package:navyoga_academy/widgets/settings_security_section.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  /// 🔥 Notification Settings
  List<Map<String, dynamic>> settings = [
    {
      "title": "Class Reminders",
      "subtitle": "Get notified before your classes start",
      "value": true,
    },
    {
      "title": "New Recording Alerts",
      "subtitle": "Notified when new recordings are available",
      "value": true,
    },
    {
      "title": "Achievement Notifications",
      "subtitle": "Get notified when you earn achievements",
      "value": true,
    },
  ];

  /// 🔐 Security Fields
  final List<Map<String, String>> securityFields = [
    {"label": "Current Password", "hint": "Enter current password"},
    {"label": "New Password", "hint": "Enter new password"},
    {"label": "Confirm New Password", "hint": "Confirm new password"},
  ];

  /// 🔒 Privacy & Data Options
  final List<Map<String, dynamic>> privacyOptions = [
    {"title": "Download My Data", "isDanger": false},
    {"title": "Privacy Policy", "isDanger": false},
    {"title": "Terms of Service", "isDanger": false},
    {"title": "Delete Account", "isDanger": true},
  ];

  /// 💳 Payment Data
  Map<String, dynamic> paymentData = {
    "plan": "Premium Membership",
    "status": "Active",
    "validTill": "May 10, 2026",
    "price": "₹999/month",
    "card": "**** **** **** 1234",
    "autoRenew": true,
  };
  bool twoFactorEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const CustomDrawer(),
      backgroundColor: const Color(0xfff5f5f5),

      appBar: AppBar(
        leadingWidth: 72,
        backgroundColor: Colors.grey[200],
        elevation: 0,

        /// 🔥 ADD THIS
        leading: Builder(
          builder: (context) => Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.deepPurple,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),

                onPressed: () {
                  _scaffoldKey.currentState?.openDrawer();
                },
              ),
            ),
          ),
        ),

        title: const Text(
          "NavYoga Academy",
          style: TextStyle(color: Colors.deepOrange),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔥 HEADER
            const Text(
              "Settings",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              "Manage your account preferences\nand security",
              style: TextStyle(color: Colors.blueGrey),
            ),

            const SizedBox(height: 20),

            /// ================= NOTIFICATION =================
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.deepOrange.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.notifications_none, color: Colors.deepOrange),
                      SizedBox(width: 8),
                      Text(
                        "Notification Settings",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  ...settings.asMap().entries.map((entry) {
                    return SettingsNotificationTile(
                      title: entry.value["title"],

                      subtitle: entry.value["subtitle"],

                      value: entry.value["value"],

                      onChanged: (val) {
                        setState(() {
                          settings[entry.key]["value"] = val;
                        });
                      },
                    );
                  }).toList(),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// ================= SECURITY =================
            SettingsSecuritySection(
              securityFields: securityFields,

              twoFactorEnabled: twoFactorEnabled,

              onTwoFactorChanged: (val) {
                setState(() {
                  twoFactorEnabled = val;
                });
              },

              onUpdatePassword: () {
                // password update logic
              },
            ),

            const SizedBox(height: 20),
            SettingsPaymentSection(
              paymentData: paymentData,

              onAutoRenewChanged: (val) {
                setState(() {
                  paymentData["autoRenew"] = val;
                });
              },

              onManagePayment: () {},

              onViewPaymentDetails: () {},
            ),

            const SizedBox(height: 20),
            SettingsPrivacySection(
              privacyOptions: privacyOptions,

              onOptionTap: (title) {
                if (title == "Delete Account") {
                  // delete logic
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
