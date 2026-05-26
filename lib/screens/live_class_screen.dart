import 'package:flutter/material.dart';
import 'package:navyoga_academy/models/class_model.dart';
import 'package:navyoga_academy/services/live_class_service.dart';
import 'dart:async';
import 'package:navyoga_academy/utils/app_snackbar.dart';
import 'package:navyoga_academy/utils/auth_manager.dart';
import 'package:navyoga_academy/widgets/app_scaffold.dart';

class LiveClassScreen extends StatefulWidget {
  const LiveClassScreen({super.key});

  @override
  State<LiveClassScreen> createState() => _LiveClassScreenState();
}

class _LiveClassScreenState extends State<LiveClassScreen> {
  final service = LiveClassService();
  List classes = [];
  bool isLoading = true;
  bool isMicOn = true;
  bool isCameraOn = true;

  int liveSeconds = 0;
  late Timer timer;
  @override
  @override
  void initState() {
    super.initState();
    startTimer();
    loadLiveClasses();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;

      setState(() {
        liveSeconds++;
      });
    });
  }

  String get formattedTime {
    int min = liveSeconds ~/ 60;
    int sec = liveSeconds % 60;
    return "$min:${sec.toString().padLeft(2, '0')}";
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  Future<void> loadLiveClasses() async {
    final token = await AuthManager.getToken();
    if (token == null) return;

    final res = await service.getLiveClasses(token);

    if (res["success"] == true) {
      setState(() {
        classes = res["data"];
        isLoading = false;
      });
    } else {
      AppSnackbar.showError(
        context,
        res["message"] ?? "Failed to load live classes",
      );

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final classData = ModalRoute.of(context)!.settings.arguments as ClassModel;

    return AppScaffold(
      currentIndex: 0,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                /// 🌈 BACKGROUND
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xff1E0030),
                        Color(0xff45002E),
                        Color(0xff2B0040),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),

                /// 👤 USER CARD
                Positioned(
                  top: 80,
                  left: 20,

                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 20, end: 0),
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeOutCubic,

                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(0, value),
                        child: child,
                      );
                    },

                    child: Container(
                      width: 220,
                      height: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white24),
                        gradient: const LinearGradient(
                          colors: [Color(0xff2c7be5), Color(0xff0b2545)],
                        ),
                      ),

                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.account_circle,
                            size: 60,
                            color: Colors.white70,
                          ),

                          SizedBox(height: 6),

                          Text("You", style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                ),

                /// 🔴 LIVE TIMER
                Positioned(
                  bottom: 140,
                  left: 20,

                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.9, end: 1),
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.easeInOut,

                    builder: (context, value, child) {
                      return Transform.scale(scale: value, child: child);
                    },

                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),

                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(20),

                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.5),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),

                      child: Text(
                        "● LIVE • $formattedTime",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),

                /// 👩‍🏫 INSTRUCTOR
                Positioned(
                  bottom: 130,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white.withOpacity(0.12)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.purple,
                          child: Text(
                            classData.trainer.substring(0, 1),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              classData.trainer,
                              style: const TextStyle(color: Colors.white),
                            ),
                            const Text(
                              "Instructor",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "⏱ ${classData.duration} min session",
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                /// 🎛 CONTROLS
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.8),
                          Colors.transparent,
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        controlBtn(
                          isMicOn ? Icons.mic : Icons.mic_off,
                          onTap: () {
                            setState(() => isMicOn = !isMicOn);
                          },
                        ),
                        controlBtn(
                          isCameraOn ? Icons.videocam : Icons.videocam_off,
                          onTap: () {
                            setState(() => isCameraOn = !isCameraOn);
                          },
                        ),
                        controlBtn(Icons.settings),
                        controlBtn(Icons.chat),
                        controlBtn(
                          Icons.call_end,
                          isEnd: true,
                          onTap: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget controlBtn(IconData icon, {bool isEnd = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),

        width: 58,
        height: 58,

        decoration: BoxDecoration(
          shape: BoxShape.circle,

          gradient: isEnd
              ? const LinearGradient(colors: [Colors.red, Colors.deepOrange])
              : LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.18),
                    Colors.white.withOpacity(0.08),
                  ],
                ),

          border: Border.all(color: Colors.white.withOpacity(0.15)),

          boxShadow: [
            BoxShadow(
              color: isEnd
                  ? Colors.red.withOpacity(0.4)
                  : Colors.black.withOpacity(0.15),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),

        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}
