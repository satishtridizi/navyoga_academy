import 'package:flutter/material.dart';
import 'package:navyoga_academy/api/api_constants.dart';
import '../models/workshop_model.dart';
import '../services/workshop_service.dart';
import '../utils/auth_manager.dart';

class WorkshopDetailsScreen extends StatefulWidget {
  final WorkshopModel workshop;

  const WorkshopDetailsScreen({super.key, required this.workshop});

  @override
  State<WorkshopDetailsScreen> createState() => _WorkshopDetailsScreenState();
}

class _WorkshopDetailsScreenState extends State<WorkshopDetailsScreen> {
  final WorkshopService _service = WorkshopService();

  bool isEnrolled = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    isEnrolled = widget.workshop.isEnrolled;
  }

  Future<void> _enrollWorkshop() async {
    setState(() {
      isLoading = true;
    });

    final token = await AuthManager.getToken();

    if (token == null) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      return;
    }

    final res = await _service.enrollWorkshop(widget.workshop.id, token);

    if (!mounted) return;

    if (res["success"] == true) {
      setState(() {
        isEnrolled = true;
        isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Enrolled successfully")));
    } else {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res["message"] ?? "Enrollment failed")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = widget.workshop.thumbnail.startsWith("http")
        ? widget.workshop.thumbnail
        : "${ApiConstants.baseUrl}${widget.workshop.thumbnail}";
    return Scaffold(
      appBar: AppBar(title: Text(widget.workshop.title)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            widget.workshop.thumbnail.isNotEmpty
                ? Image.network(
                    imageUrl,
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 220,
                        color: Colors.grey.shade300,
                        child: const Center(
                          child: Icon(Icons.image_not_supported, size: 60),
                        ),
                      );
                    },
                  )
                : Container(
                    height: 220,
                    color: Colors.grey.shade300,
                    child: const Center(child: Icon(Icons.image, size: 60)),
                  ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.workshop.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    widget.workshop.description,
                    style: const TextStyle(fontSize: 16),
                  ),

                  const SizedBox(height: 20),

                  Wrap(
                    spacing: 8,
                    children: [
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.person),
                          title: Text(widget.workshop.instructorName),
                          subtitle: const Text("Instructor"),
                        ),
                      ),
                      Chip(label: Text(widget.workshop.yogaType)),
                      Chip(label: Text(widget.workshop.level)),
                      Chip(label: Text(widget.workshop.mode)),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Text(
                    "₹${widget.workshop.price.toStringAsFixed(0)}",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isEnrolled || isLoading
                          ? null
                          : _enrollWorkshop,
                      child: Text(
                        isLoading
                            ? "Loading..."
                            : isEnrolled
                            ? "Already Enrolled"
                            : "Enroll Now",
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
  }
}
