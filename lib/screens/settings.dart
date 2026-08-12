import 'package:flutter/material.dart';
import 'package:navyoga_academy/Dashboard/dashboard_menu.dart';
//import 'package:navyoga_academy/models/payments_models.dart';
import 'package:navyoga_academy/models/settings_privacy_option_model.dart';
import 'package:navyoga_academy/models/settings_security_field_model.dart';
import 'package:navyoga_academy/screens/download_data_screen.dart';
//import 'package:navyoga_academy/screens/payment_history_screen.dart';
import 'package:navyoga_academy/screens/privacy_policy_screen.dart';
import 'package:navyoga_academy/screens/terms_screen.dart';
//import 'package:navyoga_academy/services/payment_service.dart';
import 'package:navyoga_academy/services/settings_service.dart';
import 'package:navyoga_academy/utils/auth_manager.dart';
import 'package:navyoga_academy/utils/app_snackbar.dart';
import 'package:navyoga_academy/widgets/app_scaffold.dart';
//import 'package:navyoga_academy/widgets/settings_notification_tile.dart';
//import 'package:navyoga_academy/widgets/settings_payment_section.dart';
import 'package:navyoga_academy/widgets/settings_privacy_section.dart';
import 'package:navyoga_academy/widgets/settings_security_section.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // ==================== STATE VARIABLES ====================

  final TextEditingController _currentPasswordCtrl = TextEditingController();
  final TextEditingController _newPasswordCtrl = TextEditingController();
  final TextEditingController _confirmPasswordCtrl = TextEditingController();

  //List<PaymentHistory> paymentHistoryList = [];
  //bool isPaymentHistoryLoading = true;
  bool isPrivacyLoading = true;
  bool twoFactorEnabled = false;

  List<SecurityField> securityFields = [];
  List<PrivacyOption> privacyOptions = [];

  // List<Map<String, dynamic>> settings = [
  //   {
  //     "title": "Class Reminders",
  //     "subtitle": "Get notified before your classes start",
  //     "value": true,
  //   },
  //   {
  //     "title": "New Recording Alerts",
  //     "subtitle": "Notified when new recordings are available",
  //     "value": true,
  //   },
  //   {
  //     "title": "Achievement Notifications",
  //     "subtitle": "Get notified when you earn achievements",
  //     "value": true,
  //   },
  // ];

  // Map<String, dynamic> paymentData = {
  //   "plan": "Loading...",
  //   "status": "—",
  //   "validTill": "—",
  //   "price": "—",
  //   "card": "—",
  //   "autoRenew": false,
  // };

  // ==================== LIFECYCLE ====================

  @override
  void initState() {
    super.initState();
    loadSecurityFields();
    loadPrivacyOptions();
  }

  @override
  void dispose() {
    _currentPasswordCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  // ==================== LOADERS ====================

  void loadSecurityFields() {
    setState(() {
      securityFields = [
        SecurityField(
          label: "Current Password",
          hint: "Enter current password",
        ),
        SecurityField(label: "New Password", hint: "Enter new password"),
        SecurityField(label: "Confirm Password", hint: "Re-enter password"),
      ];
    });
  }

  void loadPrivacyOptions() {
    try {
      final data = SettingsService().fetchPrivacyOptions();
      setState(() {
        privacyOptions = data;
        isPrivacyLoading = false;
      });
    } catch (e) {
      setState(() => isPrivacyLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load privacy settings")),
      );
    }
  }

  Future<void> handleUpdatePassword() async {
    if (_newPasswordCtrl.text != _confirmPasswordCtrl.text) {
      AppSnackbar.showError(context, "Passwords do not match");
      return;
    }

    final token = await AuthManager.getToken();
    if (token == null) return;

    final res = await SettingsService().changePassword(
      token: token,
      currentPassword: _currentPasswordCtrl.text.trim(),
      newPassword: _newPasswordCtrl.text.trim(),
    );

    if (res["success"] == true) {
      AppSnackbar.showSuccess(context, res["message"] ?? "Password updated");
      _currentPasswordCtrl.clear();
      _newPasswordCtrl.clear();
      _confirmPasswordCtrl.clear();
    } else {
      AppSnackbar.showError(
        context,
        res["message"] ?? "Failed to update password",
      );
    }
  }

  // ==================== BUILD ====================

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentIndex: 2,
      drawer: const CustomDrawer(currentPage: "Settings"),
      appBar: AppBar(
        leadingWidth: 72,
        backgroundColor: Colors.grey[200],
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Color(0xff1E1B39)),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),

        title: Image.asset(
          'assets/logo/logo_transparent_clean.png',
          height: 60,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== HEADER =====
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
              "Manage your account security",
              style: TextStyle(color: Colors.blueGrey),
            ),
            const SizedBox(height: 20),

            // ===== NOTIFICATIONS =====
            // Container(
            //   padding: const EdgeInsets.all(16),
            //   decoration: BoxDecoration(
            //     color: Colors.white,
            //     borderRadius: BorderRadius.circular(22),
            //     border: Border.all(color: Colors.deepOrange.withOpacity(0.2)),
            //   ),
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       Row(
            //         children: const [
            //           Icon(Icons.notifications_none, color: Colors.deepOrange),
            //           SizedBox(width: 8),
            //           Text(
            //             "Notification Settings",
            //             style: TextStyle(
            //               fontWeight: FontWeight.bold,
            //               color: Colors.deepOrange,
            //             ),
            //           ),
            //         ],
            //       ),
            //       const SizedBox(height: 16),
            //       ...settings.asMap().entries.map((entry) {
            //         return SettingsNotificationTile(
            //           title: entry.value["title"],
            //           subtitle: entry.value["subtitle"],
            //           value: entry.value["value"],
            //           onChanged: (val) {
            //             setState(() => settings[entry.key]["value"] = val);
            //           },
            //         );
            //       }).toList(),
            //     ],
            //   ),
            // ),

            //const SizedBox(height: 20),

            // ===== SECURITY =====
            SettingsSecuritySection(
              securityFields: securityFields,
              //twoFactorEnabled: twoFactorEnabled,
              onTwoFactorChanged: (val) {
                setState(() => twoFactorEnabled = val);
              },
              onUpdatePassword: handleUpdatePassword,
              // ✅ ADD THESE THREE
              currentPasswordController: _currentPasswordCtrl,
              newPasswordController: _newPasswordCtrl,
              confirmPasswordController: _confirmPasswordCtrl,
            ),

            //.animate().fade(duration: 400.ms).slideY(begin: 0.2),

            //const SizedBox(height: 20),

            // ===== PAYMENT =====
            // SettingsPaymentSection(
            //   paymentData: paymentData,
            //   onAutoRenewChanged: (val) {
            //     setState(() => paymentData["autoRenew"] = val);
            //   },
            //   onManagePayment: () {},
            //   onViewPaymentDetails: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (_) =>
            //             PaymentHistoryScreen(payments: paymentHistoryList),
            //       ),
            //     );
            //   },
            // ),
            const SizedBox(height: 20),

            // ===== PRIVACY =====
            isPrivacyLoading
                ? const Center(child: CircularProgressIndicator())
                : SettingsPrivacySection(
                    privacyOptions: privacyOptions,
                    onOptionTap: (title) {
                      if (title == "Privacy Policy") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PrivacyPolicyScreen(),
                          ),
                        );
                      } else if (title == "Terms of Service") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TermsScreen(),
                          ),
                        );
                      } else if (title == "Download My Data") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const DownloadDataScreen(),
                          ),
                        );
                      } else if (title == "Delete Account") {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Delete Account"),
                            content: const Text(
                              "Are you sure you want to delete your account? This action cannot be undone.",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text(
                                  "Cancel",
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Account deleted (mock)"),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Delete",
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
