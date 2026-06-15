import 'package:flutter/material.dart';
import 'package:navyoga_academy/models/class_model.dart';
import 'package:navyoga_academy/routes/app_routes.dart';
//import 'package:navyoga_academy/services/certificate_service.dart';
import 'package:navyoga_academy/services/self_paced_service.dart';
import 'package:navyoga_academy/utils/auth_manager.dart';
import 'package:navyoga_academy/screens/self_paced_lesson_screen.dart';
import 'package:navyoga_academy/services/self_paced_progress_service.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';

class SelfPacedClassesScreen extends StatefulWidget {
  final String moduleId;
  final String title;

  const SelfPacedClassesScreen({
    super.key,
    required this.moduleId,
    required this.title,
  });

  @override
  State<SelfPacedClassesScreen> createState() => _SelfPacedClassesScreenState();
}

class _SelfPacedClassesScreenState extends State<SelfPacedClassesScreen> {
  final SelfPacedService service = SelfPacedService();

  bool isLoading = true;
  List<ClassModel> classes = [];
  final progressService = SelfPacedProgressService();
  // final certificateService = CertificateService();

  Set<String> completedLessonIds = {};
  @override
  void initState() {
    super.initState();
    loadClasses();
  }

  Future<void> loadClasses() async {
    try {
      final token = await AuthManager.getToken();

      if (token == null) return;

      final response = await service.getClasses(token, widget.moduleId);

      print("CLASSES RESPONSE => $response");

      final List data = response["data"] ?? [];

      final progressResponse = await progressService.getMyProgress(token);

      final progressList = progressResponse["data"] ?? [];

      final ids = progressList
          .where((e) => e["isCompleted"] == true)
          .map<String>((e) => e["classId"].toString())
          .toSet();
      print("COMPLETED IDS => $ids");
      setState(() {
        classes = data.map((e) => ClassModel.fromJson(e)).toList();

        completedLessonIds = ids;

        isLoading = false;
      });
    } catch (e) {
      print(e);

      setState(() {
        isLoading = false;
      });
    }
  }

  // Future<void> downloadCertificate() async {
  //   try {
  //     final file = await certificateService.generateCertificate(
  //       studentName: "Student",
  //       moduleName: widget.title,
  //     );

  //     await OpenFilex.open(file.path);
  //     await Share.shareXFiles([XFile(file.path)]);

  //     if (!mounted) return;

  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("Certificate generated successfully")),
  //     );
  //   } catch (e) {
  //     print("CERTIFICATE ERROR => $e");
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final totalLessons = classes.length;

    final completedLessonsInModule = classes
        .where((lesson) => completedLessonIds.contains(lesson.id))
        .length;

    final isModuleCompleted =
        totalLessons > 0 && completedLessonsInModule == totalLessons;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),

        actions: [
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.selfPacedProgress);
            },
          ),
        ],
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (isModuleCompleted)
                  Card(
                    margin: const EdgeInsets.all(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.workspace_premium,
                            size: 50,
                            color: Colors.amber,
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "Module Completed!",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          // ElevatedButton.icon(
                          //   onPressed: downloadCertificate,
                          //   icon: const Icon(Icons.download),
                          //   label: const Text("Download Certificate"),
                          // ),
                        ],
                      ),
                    ),
                  ),

                Expanded(
                  child: ListView.builder(
                    itemCount: classes.length,
                    itemBuilder: (context, index) {
                      final lesson = classes[index];
                      print("LESSON ID => ${lesson.id}");
                      return Card(
                        margin: const EdgeInsets.all(10),
                        child: ListTile(
                          leading: lesson.thumbnail.isNotEmpty
                              ? Image.network(
                                  lesson.thumbnail,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) {
                                    return const Icon(Icons.image);
                                  },
                                )
                              : const Icon(Icons.image),

                          title: Text(lesson.title),

                          subtitle: Text("${lesson.durationMinutes} min"),

                          trailing: completedLessonIds.contains(lesson.id)
                              ? const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                )
                              : const Icon(Icons.play_arrow),

                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    SelfPacedLessonScreen(lesson: lesson),
                              ),
                            );

                            if (result == true) {
                              loadClasses();
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
