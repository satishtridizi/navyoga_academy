import 'package:flutter/material.dart';
import 'package:navyoga_academy/Dashboard/dashboard_menu.dart';
import 'package:navyoga_academy/routes/app_routes.dart';
import 'package:navyoga_academy/widgets/app_background.dart';
import 'package:navyoga_academy/widgets/app_scaffold.dart';
import 'package:navyoga_academy/widgets/recording_card.dart';
import '../data/recordings_data.dart';
import 'package:flutter_animate/flutter_animate.dart';

class RecordingsDashboard extends StatelessWidget {
  const RecordingsDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    /// 📊 STATS DATA (DYNAMIC)

    return AppScaffold(
      currentIndex: 1,
      drawer: const CustomDrawer(),

      //backgroundColor: const Color(0xfff5f5f5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),

                decoration: const BoxDecoration(
                  color: Colors.deepPurple,
                  shape: BoxShape.circle,
                ),

                child: const Icon(Icons.menu, color: Colors.white),
              ),

              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        title: const Text(
          "NavYoga Academy",
          style: TextStyle(
            color: Colors.deepOrange,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// 🔥 HEADER CARD
            /// 🔥 HEADER CARD
            Animate(
              effects: const [
                FadeEffect(duration: Duration(milliseconds: 500)),

                SlideEffect(
                  begin: Offset(0, 0.2),
                  end: Offset(0, 0),
                  duration: Duration(milliseconds: 500),
                ),
              ],

              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.deepPurple, Colors.purple],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.3),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.videocam, color: Colors.white),
                        SizedBox(width: 10),
                        Text(
                          "Class\nRecordings",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Access and watch recorded yoga sessions anytime",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// 📊 STATS GRID
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: RecordingsData.stats.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.2,
              ),
              itemBuilder: (context, index) {
                final item = RecordingsData.stats[index];

                return Animate(
                  delay: Duration(milliseconds: 120 * index),

                  effects: const [
                    FadeEffect(duration: Duration(milliseconds: 400)),

                    ScaleEffect(
                      begin: Offset(0.9, 0.9),
                      end: Offset(1, 1),
                      duration: Duration(milliseconds: 400),
                    ),
                  ],

                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      if (item.route != null) {
                        Navigator.pushNamed(context, item.route!);
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            (item.color).withValues(alpha: 0.2),
                            (item.color).withValues(alpha: 0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          /// ICON + VALUE
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: item.color,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  item.icon,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                              Text(
                                item.value,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          /// TITLE
                          Text(
                            item.title,
                            style: const TextStyle(
                              color: Colors.blueGrey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            /// 🔍 SEARCH BAR
            /// 🔍 SEARCH BAR
            Animate(
              delay: const Duration(milliseconds: 300),

              effects: const [
                FadeEffect(duration: Duration(milliseconds: 500)),
              ],

              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    icon: Icon(Icons.search),
                    hintText: "Search recordings or instructors...",
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),

            /// 🔽 FILTER DROPDOWN
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: "All Categories",
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(
                      value: "All Categories",
                      child: Text("All Categories"),
                    ),
                    DropdownMenuItem(value: "Yoga", child: Text("Yoga")),
                  ],
                  onChanged: (value) {},
                ),
              ),
            ),
            const SizedBox(height: 20),

            /// 🔥 ALL RECORDINGS HEADER
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: Colors.deepOrange,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  "All Recordings (8)",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            /// 🎬 LIST
            Column(
              children: RecordingsData.recordings.asMap().entries.map((entry) {
                final index = entry.key;
                final recording = entry.value;

                return Animate(
                  delay: Duration(milliseconds: 120 * index),

                  effects: const [
                    FadeEffect(duration: Duration(milliseconds: 500)),

                    SlideEffect(
                      begin: Offset(0, 0.15),
                      end: Offset(0, 0),
                      duration: Duration(milliseconds: 500),
                    ),
                  ],

                  child: RecordingCard(recording: recording),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
