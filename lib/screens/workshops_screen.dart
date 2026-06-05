import 'package:flutter/material.dart';
import 'package:navyoga_academy/Dashboard/dashboard_menu.dart';
import 'package:navyoga_academy/api/api_constants.dart';
import 'package:navyoga_academy/screens/workshop_details_screen.dart';
import '../models/workshop_model.dart';
import '../services/workshop_service.dart';
import '../utils/auth_manager.dart';
import 'package:navyoga_academy/widgets/app_scaffold.dart';

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
    for (final item in res["data"]["items"]) {}
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
    return AppScaffold(
      currentIndex: null,
      drawer: const CustomDrawer(currentPage: "Workshops"),
      appBar: AppBar(title: const Text("Workshops")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : workshops.isEmpty
          ? const Center(child: Text("No workshops found"))
          : ListView.builder(
              itemCount: workshops.length,
              itemBuilder: (context, index) {
                try {
                  final workshop = workshops[index];

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                WorkshopDetailsScreen(workshop: workshop),
                          ),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                            child: workshop.thumbnail.isNotEmpty
                                ? Image.network(
                                    workshop.thumbnail.startsWith("http")
                                        ? workshop.thumbnail
                                        : "${ApiConstants.baseUrl}${workshop.thumbnail}",
                                    height: 180,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      height: 180,
                                      color: Colors.orange.shade50,
                                      child: const Center(
                                        child: Icon(
                                          Icons.self_improvement,
                                          size: 60,
                                        ),
                                      ),
                                    ),
                                  )
                                : Container(
                                    height: 180,
                                    color: Colors.orange.shade50,
                                    child: const Center(
                                      child: Icon(
                                        Icons.self_improvement,
                                        size: 60,
                                      ),
                                    ),
                                  ),
                          ),

                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  workshop.title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 10),

                                Wrap(
                                  spacing: 8,
                                  children: [
                                    Chip(
                                      avatar: const Icon(
                                        Icons.self_improvement,
                                        size: 16,
                                      ),
                                      label: Text(workshop.yogaType),
                                    ),

                                    Chip(
                                      avatar: const Icon(Icons.star, size: 16),
                                      label: Text(workshop.level),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 10),

                                Text(
                                  "Instructor: ${workshop.instructorName}",
                                  style: const TextStyle(fontSize: 14),
                                ),

                                const SizedBox(height: 10),

                                Text(
                                  "₹${workshop.price}",
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                if (workshop.isEnrolled)
                                  Container(
                                    margin: const EdgeInsets.only(top: 8),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade100,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      "✓ Enrolled",
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                } catch (e) {
                  return const ListTile(title: Text("Error loading workshop"));
                }
              },
            ),
    );
  }
}
