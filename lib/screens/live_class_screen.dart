import 'package:flutter/material.dart';
import 'package:navyoga_academy/models/class_model.dart';

class LiveClassScreen extends StatefulWidget {
  const LiveClassScreen({super.key});

  @override
  State<LiveClassScreen> createState() => _LiveClassScreenState();
}

class _LiveClassScreenState extends State<LiveClassScreen> {
  bool isMicOn = true;
  bool isCameraOn = true;

  int liveSeconds = 0;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;

      setState(() {
        liveSeconds++;
      });

      return true;
    });
  }

  String get formattedTime {
    int min = liveSeconds ~/ 60;
    int sec = liveSeconds % 60;
    return "$min:${sec.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final classData = ModalRoute.of(context)!.settings.arguments as ClassModel;

    return Scaffold(
      body: Stack(
        children: [
          /// 🌈 BACKGROUND
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xff2b0040), Color(0xff5a001f)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          /// 👤 USER CARD
          Positioned(
            top: 80,
            left: 20,
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
                  Icon(Icons.account_circle, size: 60, color: Colors.white70),
                  SizedBox(height: 6),
                  Text("You", style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ),

          /// 🔴 LIVE TIMER
          Positioned(
            bottom: 140,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "● LIVE • $formattedTime",
                style: const TextStyle(color: Colors.white),
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
                color: Colors.black.withOpacity(0.6),
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
                        style: TextStyle(color: Colors.white70, fontSize: 12),
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
                  colors: [Colors.black.withOpacity(0.8), Colors.transparent],
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
      child: CircleAvatar(
        radius: 26,
        backgroundColor: isEnd ? Colors.red : Colors.white24,
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}
