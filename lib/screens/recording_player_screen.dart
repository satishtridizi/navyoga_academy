import 'package:flutter/material.dart';
import 'package:navyoga_academy/widgets/app_background.dart';
import '../models/recording_model.dart';
import 'package:flutter_animate/flutter_animate.dart';

class RecordingPlayerScreen extends StatefulWidget {
  final RecordingModel recording;

  const RecordingPlayerScreen({super.key, required this.recording});

  @override
  State<RecordingPlayerScreen> createState() => _RecordingPlayerScreenState();
}

class _RecordingPlayerScreenState extends State<RecordingPlayerScreen> {
  double currentProgress = 0.0;
  bool isPlaying = false;
  String currentTime = "0:00";

  String get totalTime => widget.recording.duration;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2E0F4F), Color(0xFF5A1E8A), Color(0xFF8E1C6F)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                /// 🔹 TOP INFO CARD
                Positioned(
                  top: 20,
                  left: 16,

                  child: Animate(
                    effects: const [
                      FadeEffect(duration: Duration(milliseconds: 500)),

                      SlideEffect(
                        begin: Offset(-0.2, 0),
                        end: Offset(0, 0),
                        duration: Duration(milliseconds: 500),
                      ),
                    ],

                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const CircleAvatar(
                                backgroundColor: Colors.white,
                                child: Text("RK"),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.recording.trainer,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Text(
                                    "Instructor",
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.recording.category,
                            style: const TextStyle(color: Colors.pinkAccent),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "⏱ ${widget.recording.duration}",
                            style: const TextStyle(color: Colors.white70),
                          ),
                          Text(
                            "⭐ ${widget.recording.rating}",
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                /// 🔹 PROGRESS CARD
                Positioned(
                  right: 16,
                  bottom: 160,

                  child: Animate(
                    delay: const Duration(milliseconds: 300),

                    effects: const [
                      FadeEffect(duration: Duration(milliseconds: 500)),

                      SlideEffect(
                        begin: Offset(0.2, 0),
                        end: Offset(0, 0),
                        duration: Duration(milliseconds: 500),
                      ),
                    ],

                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.purpleAccent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Your Progress",
                            style: TextStyle(color: Colors.white),
                          ),
                          const SizedBox(height: 6),
                          SizedBox(
                            width: 120,
                            child: LinearProgressIndicator(
                              value: currentProgress,
                              color: Colors.white,
                              backgroundColor: Colors.white30,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${(currentProgress * 100).toInt()}%",
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                /// 🔻 PLAYER BAR
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,

                  child: Animate(
                    delay: const Duration(milliseconds: 500),

                    effects: const [
                      FadeEffect(duration: Duration(milliseconds: 600)),

                      SlideEffect(
                        begin: Offset(0, 0.3),
                        end: Offset(0, 0),
                        duration: Duration(milliseconds: 600),
                      ),
                    ],

                    child: Container(
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 20),
                      decoration: const BoxDecoration(
                        color: Color(0xFF0F172A),
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          /// SLIDER
                          Row(
                            children: [
                              Text(
                                currentTime,
                                style: const TextStyle(color: Colors.white70),
                              ),
                              Expanded(
                                child: Slider(
                                  value: currentProgress,
                                  onChanged: (value) {
                                    setState(() {
                                      currentProgress = value;

                                      int totalSeconds = 1800;
                                      int currentSeconds =
                                          (totalSeconds * value).toInt();

                                      int minutes = currentSeconds ~/ 60;
                                      int seconds = currentSeconds % 60;

                                      currentTime =
                                          "$minutes:${seconds.toString().padLeft(2, '0')}";
                                    });
                                  },
                                  activeColor: Colors.white,
                                  inactiveColor: Colors.white24,
                                ),
                              ),
                              Text(
                                totalTime,
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          /// BUTTONS
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _btn(Icons.skip_previous),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isPlaying = !isPlaying;
                                  });
                                },
                                child: Animate(
                                  effects: const [
                                    ScaleEffect(
                                      begin: Offset(0.8, 0.8),
                                      end: Offset(1, 1),
                                      duration: Duration(milliseconds: 300),
                                    ),
                                  ],

                                  child: _btn(
                                    isPlaying ? Icons.pause : Icons.play_arrow,
                                    isMain: true,
                                  ),
                                ),
                              ),
                              _btn(Icons.skip_next),
                              _btn(Icons.volume_up),
                              _btn(Icons.settings),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 🔘 BUTTON
  Widget _btn(IconData icon, {bool isMain = false}) {
    return CircleAvatar(
      radius: isMain ? 28 : 22,
      backgroundColor: isMain ? Colors.purple : Colors.blueGrey.shade700,
      child: Icon(icon, color: Colors.white),
    );
  }
}
