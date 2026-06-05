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
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  StudentModel? student;
  File? selectedImage;
  String? profileImageUrl;
  final ImagePicker _picker = ImagePicker();
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
      profileImageUrl = studentData.profileImage;
    });
  }

  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image == null) return;

    setState(() {
      selectedImage = File(image.path);
    });

    await uploadProfileImage();
  }

  Future<void> uploadProfileImage() async {
    if (selectedImage == null) return;

    final token = await AuthManager.getToken();

    final response = await profileService.uploadProfileImage(
      token: token!,
      imageFile: selectedImage!,
    );

    if (ApiHelper.isSuccess(response)) {
      setState(() {
        profileImageUrl = response["image_url"];
      });

      AppSnackbar.showSuccess(context, "Profile image updated");
    }
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
      drawer: const CustomDrawer(currentPage: "Profile"),

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
          style: TextStyle(
            color: Colors.deepOrange,
            fontWeight: FontWeight.bold,
          ),
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

            ProfileSection(
              title: "Security",
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.changePassword);
                      },
                      icon: const Icon(Icons.lock, color: Colors.white),
                      label: const Text(
                        "Change Password",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
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

                  // SizedBox(
                  //   width: double.infinity,
                  //   child: OutlinedButton.icon(
                  //     onPressed: () {
                  //       // future: open add goal screen
                  //     },
                  //     icon: const Icon(
                  //       Icons.track_changes,
                  //       color: Colors.purple,
                  //     ),
                  //     label: const Text("Set New Goal"),
                  //     style: OutlinedButton.styleFrom(
                  //       side: const BorderSide(
                  //         color: Colors.purple,
                  //         width: 1.5,
                  //       ),
                  //       padding: const EdgeInsets.symmetric(vertical: 14),
                  //       shape: RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.circular(30),
                  //       ),
                  //     ),
                  //   ),
                  // ),
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

  /// 🔥 AVATAR
  Widget _buildAvatar() {
    return Center(
      child: GestureDetector(
        onTap: pickImage,
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.deepOrange, width: 3),
              ),
              child: ClipOval(
                child: selectedImage != null
                    ? Image.file(selectedImage!, fit: BoxFit.cover)
                    : profileImageUrl != null
                    ? Image.network(profileImageUrl!, fit: BoxFit.cover)
                    : const Icon(Icons.person, size: 60, color: Colors.purple),
              ),
            ),

            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.deepOrange,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
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
