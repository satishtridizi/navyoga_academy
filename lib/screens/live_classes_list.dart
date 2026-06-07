import 'package:flutter/material.dart';
import 'package:navyoga_academy/utils/auth_manager.dart';
import '../services/live_class_service.dart';
import '../utils/app_snackbar.dart';
import '../models/class_model.dart';
import '../routes/app_routes.dart';

class LiveClassesListScreen extends StatefulWidget {
  const LiveClassesListScreen({super.key});

  @override
  State<LiveClassesListScreen> createState() => _LiveClassesListScreenState();
}

class _LiveClassesListScreenState extends State<LiveClassesListScreen> {
  final service = LiveClassService();

  List<ClassModel> classes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadClasses();
  }

  Future<void> loadClasses() async {
    final token = await AuthManager.getToken();

    if (token == null) return;

    final res = await service.getLiveClasses(token);

    if (res["success"] == true && res["data"] != null) {
      final List data = res["data"];

      setState(() {
        classes = data.map((e) => ClassModel.fromJson(e)).toList();
        isLoading = false;
      });
    } else {
      AppSnackbar.showError(
        context,
        res["message"] ?? "Failed to load classes",
      );

      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final classId = ModalRoute.of(context)?.settings.arguments as String?;

    print("SELECTED CLASS ID = $classId");

    return Scaffold(
      appBar: AppBar(title: const Text("Live Classes")),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : classes.isEmpty
          ? const Center(child: Text("No live classes available"))
          : ListView.builder(
              itemCount: classes.length,
              itemBuilder: (context, index) {
                final c = classes[index];

                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    leading: const Icon(Icons.live_tv),
                    title: Text(c.title),
                    subtitle: Text("${c.trainer} • ${c.duration} mins"),
                    trailing: const Icon(Icons.arrow_forward),

                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.liveClass,
                        arguments: c, // 🔥 VERY IMPORTANT
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
