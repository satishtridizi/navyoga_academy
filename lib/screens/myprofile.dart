import 'package:flutter/material.dart';
import 'package:navyoga_academy/Dashboard/dashboard_menu.dart';
import 'package:navyoga_academy/models/profile_field_model.dart';
import 'package:navyoga_academy/widgets/goal_myprofile_widget.dart';
import '../data/profile_data.dart';
import '../widgets/profile_stat_card.dart';
import '../widgets/profile_section.dart';
import '../widgets/profile_field.dart';
import '../widgets/achievement_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  List<TextEditingController> medicalControllers = [];
  @override
  void initState() {
    super.initState();

    medicalControllers = ProfileData.medicalInfo
        .map((e) => TextEditingController(text: e.value))
        .toList();
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
    return Scaffold(
      drawer: const CustomDrawer(),
      backgroundColor: const Color(0xfff5f5f5),

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
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔥 HEADER
            const Text(
              "My Profile",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              "Manage your personal information and track your progress",
              style: TextStyle(color: Colors.blueGrey),
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
                      onPressed: () {
                        setState(() {
                          ProfileData.personalInfo[0] = ProfileFieldModel(
                            label: "Full Name",
                            value: nameController.text,
                          );

                          ProfileData.personalInfo[1] = ProfileFieldModel(
                            label: "Email Address",
                            value: emailController.text,
                          );

                          ProfileData.personalInfo[2] = ProfileFieldModel(
                            label: "Phone Number",
                            value: phoneController.text,
                          );

                          ProfileData.personalInfo[3] = ProfileFieldModel(
                            label: "Address",
                            value: addressController.text,
                            isMultiline: true,
                          );
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
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
    child: Container(
      height: 110,
      width: 110,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.purple.withOpacity(.15),
      ),
      child: const Icon(Icons.person_outline, size: 50, color: Colors.purple),
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
