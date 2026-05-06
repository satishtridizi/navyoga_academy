import 'package:flutter/material.dart';
import 'package:navyoga_academy/widgets/animatedItem.dart';
import 'package:navyoga_academy/widgets/app_background.dart';

class DownloadDataScreen extends StatelessWidget {
  const DownloadDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          "Download My Data",
          style: TextStyle(
            color: Colors.deepOrange,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      body: AppBackground(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 🔥 HEADER
              AnimatedItem(
                index: 0,
                child: const Text(
                  "Download\nYour Data",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              AnimatedItem(
                index: 1,
                child: const Text(
                  "Export your classes, recordings, achievements, attendance, and account activity securely.",
                  style: TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              /// 📦 DATA CARD
              AnimatedItem(
                index: 2,
                child: Container(
                  padding: const EdgeInsets.all(22),

                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.deepOrange.withOpacity(0.12),
                        Colors.orange.withOpacity(0.05),
                      ],
                    ),

                    borderRadius: BorderRadius.circular(28),

                    border: Border.all(
                      color: Colors.deepOrange.withOpacity(0.25),
                    ),

                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),

                  child: Column(
                    children: [
                      /// ICON
                      Container(
                        padding: const EdgeInsets.all(18),

                        decoration: BoxDecoration(
                          color: Colors.deepOrange,
                          borderRadius: BorderRadius.circular(22),

                          boxShadow: [
                            BoxShadow(
                              color: Colors.deepOrange.withOpacity(0.4),
                              blurRadius: 14,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),

                        child: const Icon(
                          Icons.download_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        "Your data package includes:",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff1E1B39),
                        ),
                      ),

                      const SizedBox(height: 18),

                      _featureRow(Icons.menu_book, "Enrolled Classes"),
                      _featureRow(Icons.videocam, "Recordings History"),
                      _featureRow(Icons.emoji_events, "Achievements"),
                      _featureRow(Icons.calendar_today, "Attendance Reports"),
                      _featureRow(Icons.person, "Profile Information"),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),

              /// 🚀 DOWNLOAD BUTTON
              AnimatedItem(
                index: 3,
                child: SizedBox(
                  width: double.infinity,

                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Preparing your download..."),
                        ),
                      );

                      // 👉 Future API integration
                    },

                    icon: const Icon(Icons.download, color: Colors.white),

                    label: const Text(
                      "Download My Data",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      elevation: 6,

                      padding: const EdgeInsets.symmetric(vertical: 18),

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// 🔒 FOOTER NOTE
              AnimatedItem(
                index: 4,
                child: Center(
                  child: Text(
                    "Your exported data is securely protected.",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ✅ FEATURE ROW
  static Widget _featureRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),

      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),

            decoration: BoxDecoration(
              color: Colors.deepOrange.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),

            child: Icon(icon, color: Colors.deepOrange, size: 18),
          ),

          const SizedBox(width: 14),

          Text(
            text,
            style: const TextStyle(fontSize: 15, color: Color(0xff1E1B39)),
          ),
        ],
      ),
    );
  }
}
