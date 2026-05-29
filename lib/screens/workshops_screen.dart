import 'package:flutter/material.dart';
import '../models/workshop_model.dart';
import '../services/workshop_service.dart';
import '../utils/auth_manager.dart';

class WorkshopsScreen extends StatefulWidget {
  const WorkshopsScreen({super.key});

  @override
  State<WorkshopsScreen> createState() => _WorkshopsScreenState();
}

class _WorkshopsScreenState extends State<WorkshopsScreen> {
  final WorkshopService service = WorkshopService();

  List<WorkshopModel> workshops = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadWorkshops();
  }

  Future<void> loadWorkshops() async {
    final token = await AuthManager.getToken();

    if (token == null) return;

    final res = await service.getWorkshops(token);

    print("WORKSHOP RESPONSE");
    print(res);

    if (res["success"] == true) {
      final List data = res["data"]["items"] ?? [];

      setState(() {
        workshops = data.map((e) => WorkshopModel.fromJson(e)).toList();
        loading = false;
      });
    } else {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Workshops")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: workshops.length,
              itemBuilder: (context, index) {
                final workshop = workshops[index];

                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(workshop.title),
                    subtitle: Text(workshop.instructorName),
                    trailing: Text("₹${workshop.price}"),
                  ),
                );
              },
            ),
    );
  }
}
