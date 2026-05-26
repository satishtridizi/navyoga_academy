import 'package:flutter/material.dart';
import 'package:navyoga_academy/Dashboard/dashboard_menu.dart';
import 'package:navyoga_academy/models/student_model.dart';
import 'package:navyoga_academy/routes/app_routes.dart';
import 'package:navyoga_academy/services/auth_service.dart';
import 'package:navyoga_academy/services/profile_service.dart';
import 'package:navyoga_academy/utils/api_helper.dart';
import 'package:navyoga_academy/utils/auth_manager.dart';
import 'package:navyoga_academy/widgets/animatedItem.dart';
import 'package:navyoga_academy/widgets/app_scaffold.dart';
import 'package:navyoga_academy/widgets/goal_myprofile_widget.dart';
import '../data/profile_data.dart';
import '../widgets/profile_stat_card.dart';
import '../widgets/profile_section.dart';
import '../widgets/profile_field.dart';
import '../widgets/achievement_card.dart';
import 'package:navyoga_academy/utils/app_snackbar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  StudentModel? student;
  final authService = AuthService();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  List<TextEditingController> medicalControllers = [];
  List<TextEditingController> preferenceControllers = [];

  final profileService = ProfileService();

  bool isUpdating = false;

  @override
  void initState() {
    super.initState();

    medicalControllers = ProfileData.medicalInfo
        .map((e) => TextEditingController(text: e.value))
        .toList();

    preferenceControllers = ProfileData.preferences
        .map((e) => TextEditingController(text: e.value))
        .toList();

    loadProfile();
  }

  Future<void> loadProfile() async {
    final token = await AuthManager.getToken();

    if (token == null) return;

    final response = await authService.getProfile(token);

    if (response["unauthorized"] == true) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (route) => false,
      );
      return;
    }

    if (!ApiHelper.isSuccess(response) || response["data"] == null) {
      return;
    }

    final studentData = StudentModel.fromJson(response["data"]);

    setState(() {
      student = studentData;
      nameController.text = studentData.name;
      emailController.text = studentData.email;
      phoneController.text = studentData.phone;
    });
  }

  Future<void> updateProfile() async {
    setState(() {
      isUpdating = true;
    });

    final token = await AuthManager.getToken();

    if (token == null) {
      Navigator.pushReplacementNamed(context, "/login");

      return;
    }

    final response = await profileService.updateProfile(
      token: token,

      name: nameController.text,

      email: emailController.text,

      phone: phoneController.text,

      address: addressController.text,
    );
    if (!mounted) return;

    setState(() {
      isUpdating = false;
    });

    if (ApiHelper.isSuccess(response)) {
      AppSnackbar.showSuccess(context, response["message"]);
    } else {
      AppSnackbar.showError(context, response["message"]);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentIndex: 4,
      drawer: const CustomDrawer(),

      //backgroundColor: Colors.transparent,
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black54),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          "NavYoga Academy",
          style: TextStyle(color: Colors.deepOrange),
        ),
        backgroundColor: Colors.grey[200],
        elevation: 0,
      ),

      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔥 HEADER
            AnimatedItem(
              index: 0,
              child: Text(
                "My Profile",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange,
                ),
              ),
            ),
            const SizedBox(height: 6),

            AnimatedItem(
              index: 1,

              child: const Text(
                "Manage your personal information and track your progress",
                style: TextStyle(color: Colors.blueGrey),
              ),
            ),

            const SizedBox(height: 20),

            /// 📊 STATS
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: ProfileData.stats.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.1,
              ),
              itemBuilder: (_, i) => ProfileStatCard(ProfileData.stats[i]),
            ),

            const SizedBox(height: 20),

            /// 👤 PERSONAL INFO
            ProfileSection(
              title: "Personal Information",
              child: Column(
                children: [
                  _buildAvatar(),

                  const SizedBox(height: 20),

                  Column(
                    children: [
                      ProfileField(ProfileData.personalInfo[0], nameController),
                      ProfileField(
                        ProfileData.personalInfo[1],
                        emailController,
                      ),
                      ProfileField(
                        ProfileData.personalInfo[2],
                        phoneController,
                      ),
                      ProfileField(
                        ProfileData.personalInfo[3],
                        addressController,
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: updateProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: isUpdating
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              "Update Profile",
                              style: TextStyle(color: Colors.white),
                            ),
                    ),
                  ),
                ],
              ),
            ),

            /// 🎯 HEALTH GOALS
            ProfileSection(
              title: "Health Goals",
              child: Column(
                children: [
                  ...ProfileData.goals.map((e) => GoalWidget(data: e)),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // future: open add goal screen
                      },
                      icon: const Icon(
                        Icons.track_changes,
                        color: Colors.purple,
                      ),
                      label: const Text("Set New Goal"),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Colors.purple,
                          width: 1.5,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /// 🏆 ACHIEVEMENTS (ADD THIS BELOW HEALTH GOALS)
            ProfileSection(
              title: "Your Achievements",
              child: Column(
                children: [
                  ...ProfileData.achievements.map(
                    (e) => AchievementCard(data: e),
                  ),
                ],
              ),
            ),

            /// 🏥 MEDICAL INFO
            ProfileSection(
              title: "Medical Information",
              child: Column(
                children: [
                  Column(
                    children: [
                      ...ProfileData.medicalInfo.asMap().entries.map((entry) {
                        int index = entry.key;
                        var item = entry.value;

                        return ProfileField(item, medicalControllers[index]);
                      }).toList(),

                      const SizedBox(height: 12),

                      _secondaryButton("Update Medical Info"),
                    ],
                  ),
                ],
              ),
            ),

            /// ⚙️ PREFERENCES
            ProfileSection(
              title: "Preferences",
              child: Column(
                children: [
                  Column(
                    children: [
                      ...ProfileData.preferences.asMap().entries.map((entry) {
                        int index = entry.key;
                        var item = entry.value;

                        return ProfileField(item, preferenceControllers[index]);
                      }).toList(),
                    ],
                  ),

                  const SizedBox(height: 12),

                  _primaryButton("Update Preferences", Colors.deepOrange),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

/// 🔥 AVATAR
Widget _buildAvatar() {
  return Center(
    child: TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.9, end: 1),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutBack,

      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },

      child: Container(
        height: 115,
        width: 115,

        decoration: BoxDecoration(
          shape: BoxShape.circle,

          gradient: LinearGradient(
            colors: [
              Colors.purple.withOpacity(.2),
              Colors.deepOrange.withOpacity(.15),
            ],
          ),

          boxShadow: [
            BoxShadow(
              color: Colors.purple.withOpacity(.25),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),

        child: const Icon(Icons.person_outline, size: 52, color: Colors.purple),
      ),
    ),
  );
}

/// 🔥 PRIMARY BUTTON
Widget _primaryButton(String text, Color color) {
  return SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white)),
    ),
  );
}

/// 🔥 SECONDARY BUTTON
Widget _secondaryButton(String text) {
  return SizedBox(
    width: double.infinity,
    child: OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.purple),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: Text(text, style: const TextStyle(color: Colors.purple)),
    ),
  );
}
