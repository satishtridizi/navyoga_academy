import 'package:flutter/material.dart';
import 'package:navyoga_academy/services/self_paced_progress_service.dart';
import 'package:navyoga_academy/utils/auth_manager.dart';

class SelfPacedProgressScreen extends StatefulWidget {
  const SelfPacedProgressScreen({super.key});

  @override
  State<SelfPacedProgressScreen> createState() =>
      _SelfPacedProgressScreenState();
}

class _SelfPacedProgressScreenState extends State<SelfPacedProgressScreen> {
  final progressService = SelfPacedProgressService();

  bool isLoading = true;

  List progressList = [];

  int completedLessons = 0;

  @override
  void initState() {
    super.initState();
    loadProgress();
  }

  Future<void> loadProgress() async {
    try {
      final token = await AuthManager.getToken();

      if (token == null) return;

      final response = await progressService.getMyProgress(token);

      print("MY PROGRESS => $response");

      final List data = response["data"] ?? [];

      completedLessons = data.where((e) => e["isCompleted"] == true).length;

      setState(() {
        progressList = data;
        isLoading = false;
      });
    } catch (e) {
      print(e);

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalLessons = progressList.length;

    final percentage = totalLessons == 0
        ? 0.0
        : completedLessons / totalLessons;

    return Scaffold(
      appBar: AppBar(title: const Text("My Progress")),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Overall Progress",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 20),

                  Center(
                    child: SizedBox(
                      width: 140,
                      height: 140,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 140,
                            height: 140,
                            child: CircularProgressIndicator(
                              value: percentage,
                              strokeWidth: 12,
                            ),
                          ),

                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "${(percentage * 100).toInt()}%",
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const Text(
                                "Completed",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  Text(
                    "$completedLessons / $totalLessons Lessons Completed",
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 30),

                  const Text(
                    "Achievements",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 30),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      if (completedLessons >= 1)
                        Chip(
                          avatar: const Icon(Icons.emoji_events, size: 18),
                          label: const Text("First Lesson"),
                        ),

                      if (completedLessons >= 5)
                        Chip(
                          avatar: const Icon(Icons.workspace_premium, size: 18),
                          label: const Text("5 Lessons"),
                        ),

                      if (completedLessons >= 10)
                        Chip(
                          avatar: const Icon(Icons.military_tech, size: 18),
                          label: const Text("10 Lessons"),
                        ),

                      const Chip(label: Text("🏅 All Lessons Completed")),
                    ],
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    "Completed Lessons",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 15),

                  ...progressList.map(
                    (item) => Card(
                      child: ListTile(
                        leading: Icon(
                          item["isCompleted"] == true
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: item["isCompleted"] == true
                              ? Colors.green
                              : Colors.grey,
                        ),
                        title: Text(item["classId"] ?? ""),
                        subtitle: Text("Progress: ${item["progress"] ?? 0}%"),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
