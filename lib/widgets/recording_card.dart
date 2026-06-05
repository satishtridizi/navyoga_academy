import 'package:flutter/material.dart';
import 'package:navyoga_academy/models/recording_api_model.dart';
import 'package:navyoga_academy/screens/recording_player_screen.dart';

class RecordingCard extends StatelessWidget {
  final RecordingApiModel recording;
  const RecordingCard({super.key, required this.recording});

  @override
  Widget build(BuildContext context) {
    const Color color = Colors.deepPurple;
    const bool isCompleted = false;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RecordingPlayerScreen(recording: recording),
          ),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        margin: const EdgeInsets.only(bottom: 16),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),

          boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 10)],
        ),

        child: Column(
          children: [
            /// THUMBNAIL
            Stack(
              children: [
                Container(
                  height: 120,

                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withOpacity(0.7)],
                    ),

                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),

                  child: const Center(
                    child: Icon(
                      Icons.videocam,
                      size: 40,
                      color: Colors.white70,
                    ),
                  ),
                ),

                const Positioned(
                  right: 10,
                  top: 10,

                  child: CircleAvatar(
                    radius: 14,
                    backgroundColor: Colors.white,

                    child: Icon(Icons.favorite, size: 16, color: Colors.red),
                  ),
                ),

                Positioned(
                  right: 10,
                  bottom: 10,

                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),

                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(10),
                    ),

                    child: Text(
                      recording.level,

                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),

            /// DETAILS
            Padding(
              padding: const EdgeInsets.all(14),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    recording.title,

                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    recording.description,

                    style: const TextStyle(color: Colors.blueGrey),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      chip(recording.yogaType, color.withOpacity(0.2), color),

                      const SizedBox(width: 8),

                      if (isCompleted)
                        chip("Completed", Colors.green.shade100, Colors.green),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        recording.level,
                        style: const TextStyle(color: Colors.blueGrey),
                      ),
                      Text(
                        recording.yogaType,
                        style: const TextStyle(color: Colors.deepPurple),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget chip(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),

      decoration: BoxDecoration(
        color: bg,

        borderRadius: BorderRadius.circular(20),
      ),

      child: Text(text, style: TextStyle(color: fg, fontSize: 12)),
    );
  }
}
