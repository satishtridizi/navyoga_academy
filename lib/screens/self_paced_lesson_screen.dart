import 'package:flutter/material.dart';
import 'package:navyoga_academy/models/class_model.dart';
import 'package:navyoga_academy/screens/lesson_video_player.dart';
import 'package:navyoga_academy/services/self_paced_progress_service.dart';
import 'package:navyoga_academy/utils/auth_manager.dart';

class SelfPacedLessonScreen extends StatefulWidget {
  final ClassModel lesson;

  const SelfPacedLessonScreen({super.key, required this.lesson});

  @override
  State<SelfPacedLessonScreen> createState() => _SelfPacedLessonScreenState();
}

class _SelfPacedLessonScreenState extends State<SelfPacedLessonScreen> {
  bool isCompleting = false;

  final progressService = SelfPacedProgressService();

  Future<void> markLessonComplete() async {
    if (isCompleting) return;

    isCompleting = true;

    try {
      final token = await AuthManager.getToken();

      if (token == null) {
        isCompleting = false;
        return;
      }

      final response = await progressService.markComplete(
        token,
        widget.lesson.id,
      );

      print("PROGRESS RESPONSE => $response");

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Lesson completed")));

      Navigator.pop(context, true);
    } catch (e) {
      print("PROGRESS ERROR => $e");
      isCompleting = false;
    }
  }

  @override
  void initState() {
    super.initState();
    print("LESSON SCREEN INIT");
  }

  @override
  void dispose() {
    print("LESSON SCREEN DISPOSE");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("LESSON SCREEN BUILD");
    return Scaffold(
      appBar: AppBar(title: Text(widget.lesson.title)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LessonVideoPlayer(
              videoUrl: widget.lesson.video,
              onNinetyPercentWatched: markLessonComplete,
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.lesson.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text("Duration: ${widget.lesson.durationMinutes} minutes"),

                  const SizedBox(height: 20),

                  const Text(
                    "Description",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "Lesson Details",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),

                  const SizedBox(height: 10),

                  Text(widget.lesson.description),

                  const SizedBox(height: 30),

                  // SizedBox(
                  //   width: double.infinity,
                  //   child: ElevatedButton(
                  //     onPressed: markLessonComplete,
                  //     child: const Text("Mark Complete"),
                  //   ),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
