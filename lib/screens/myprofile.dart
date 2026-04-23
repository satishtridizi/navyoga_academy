import 'package:flutter/material.dart';
import 'package:navyoga_academy/Dashboard/dashboard_menu.dart';

class ProfileStat {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  ProfileStat(this.title, this.value, this.icon, this.color);
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    /// DATA
    final stats = [
      ProfileStat(
        "Member Since",
        "Jan 2025",
        Icons.calendar_today,
        Colors.orange,
      ),
      ProfileStat("Total Classes", "124", Icons.track_changes, Colors.purple),
      ProfileStat("Achievements", "12", Icons.emoji_events, Colors.green),
      ProfileStat(
        "Skill Level",
        "Intermediate",
        Icons.trending_up,
        Colors.amber,
      ),
    ];

    final personalInfo = [
      {"label": "Full Name", "value": "Rajesh Kumar"},
      {
        "label": "Email Address",
        "value": "rajesh.kumar@email.com",
        "icon": Icons.email,
      },
      {
        "label": "Phone Number",
        "value": "+91 98765 43210",
        "icon": Icons.phone,
      },
      {
        "label": "Address",
        "value": "Enter your address",
        "icon": Icons.location_on,
        "isMultiline": true,
      },
    ];

    final medicalInfo = [
      {"label": "Age", "value": "32"},
      {"label": "Blood Group", "value": "O+"},
      {"label": "Emergency Contact", "value": "+91 98765 12345"},
      {
        "label": "Medical Conditions (if any)",
        "value": "List any medical conditions",
        "isMultiline": true,
      },
    ];

    final preferences = [
      {"label": "Yoga Experience", "value": "2 years"},
      {"label": "Current Level", "value": "Intermediate"},
      {
        "label": "Areas of Interest",
        "value": "Hatha, Vinyasa",
        "isMultiline": true,
      },
      {
        "label": "Fitness Goals",
        "value": "What do you want to achieve?",
        "isMultiline": true,
      },
    ];

    final healthGoals = [
      {
        "title": "Improve Flexibility",
        "progress": 0.75,
        "subtitle": "Achieve full splits by June 2026",
      },
      {
        "title": "Build Core Strength",
        "progress": 0.60,
        "subtitle": "Hold plank for 5 minutes",
      },
      {
        "title": "Master Meditation",
        "progress": 0.85,
        "subtitle": "30 minutes daily meditation",
      },
      {
        "title": "Weight Management",
        "progress": 0.45,
        "subtitle": "Reach ideal body weight",
      },
    ];

    final achievements = [
      {
        "title": "30-Day Streak",
        "subtitle": "Attended classes for 30 days",
        "date": "Mar 1, 2026",
        "icon": "🔥",
      },
      {
        "title": "Early Bird",
        "subtitle": "10 morning classes",
        "date": "Feb 15, 2026",
        "icon": "🌅",
      },
      {
        "title": "Meditation Master",
        "subtitle": "20 sessions completed",
        "date": "Feb 28, 2026",
        "icon": "🧘",
      },
      {
        "title": "Flexible Warrior",
        "subtitle": "Advanced flexibility",
        "date": "Jan 20, 2026",
        "icon": "💪",
      },
      {
        "title": "Power House",
        "subtitle": "15 power yoga sessions",
        "date": "Feb 10, 2026",
        "icon": "⚡",
      },
      {
        "title": "Breath Master",
        "subtitle": "10 pranayama techniques",
        "date": "Jan 30, 2026",
        "icon": "🌬️",
      },
    ];

    return Scaffold(
      drawer: const CustomDrawer(),
      backgroundColor: const Color(0xfff5f5f5),
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.deepPurple),

            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
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
            /// HEADER
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
            ),

            const SizedBox(height: 20),

            /// STATS
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: stats.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemBuilder: (context, i) {
                final s = stats[i];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        s.color.withValues(alpha: 0.04),
                        s.color.withValues(alpha: 0.02),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: s.color.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(s.icon, color: s.color),
                      ),
                      const Spacer(),
                      Text(
                        s.title,
                        style: const TextStyle(color: Colors.blueGrey),
                      ),
                      Text(
                        s.value,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            /// PERSONAL INFO
            section(
              "Personal Information",
              Column(
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.purple.withValues(alpha: 0.1),
                    child: const Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.purple,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ...personalInfo.map((e) => field(e)),
                  button("Update Profile", Colors.purple),
                ],
              ),
            ),

            /// HEALTH GOALS
            section(
              "Health Goals",
              Column(
                children: [
                  ...healthGoals.map((g) {
                    final title = g["title"] as String;
                    final progress = g["progress"] as double;
                    final subtitle = g["subtitle"] as String;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(title),
                              Text("${(progress * 100).toInt()}%"),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 8,
                              backgroundColor: Colors.grey.shade300,
                              valueColor: const AlwaysStoppedAnimation(
                                Colors.purple,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            subtitle,
                            style: const TextStyle(color: Colors.blueGrey),
                          ),
                        ],
                      ),
                    );
                  }),
                  outlineButton(
                    "Set New Goal",
                    icon: Icons.track_changes,
                    color: Colors.purple,
                  ),
                ],
              ),
            ),

            /// ACHIEVEMENTS
            section(
              "Your Achievements",
              Column(
                children: [
                  ...achievements.map((a) {
                    return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.green, width: 1.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          Text(
                            a["icon"] as String,
                            style: const TextStyle(fontSize: 36),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            a["title"] as String,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            a["subtitle"] as String,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(a["date"] as String),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),

            /// MEDICAL
            section(
              "Medical Information",
              Column(
                children: [
                  ...medicalInfo.map((e) => field(e)),
                  Center(
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        side: const BorderSide(
                          color: Color.fromARGB(255, 248, 198, 118),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          SizedBox(width: 8),
                          Text(
                            "Update Medical Info",
                            style: TextStyle(
                              color: Color.fromARGB(255, 0, 0, 0),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /// PREFERENCES
            section(
              "Preferences",
              Column(
                children: [
                  ...preferences.map((e) => field(e)),
                  button("Update Preferences", Colors.deepOrange),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// SECTION
  Widget section(String title, Widget child) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.deepOrange,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  /// FIELD
  Widget field(Map<String, dynamic> item) {
    final multi = item["isMultiline"] == true;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item["label"] as String,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),

          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 14,
              vertical: multi ? 18 : 14,
            ),
            decoration: BoxDecoration(
              color: Colors.white, // ✅ changed from grey
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.orange.withValues(alpha: 0.3), // ✅ border added
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),

            child: Row(
              children: [
                if (item["icon"] != null) ...[
                  Icon(
                    item["icon"],
                    size: 18,
                    color: const Color.fromARGB(255, 0, 0, 0),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    item["value"] as String,
                    style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// BUTTON
  Widget button(String text, Color color) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: Text(text),
    );
  }

  /// OUTLINE BUTTON
  Widget outlineButton(
    String text, {
    IconData? icon,
    Color color = Colors.orange,
  }) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: Icon(icon ?? Icons.circle, color: color),
      label: Text(text, style: TextStyle(color: color)),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    );
  }
}
