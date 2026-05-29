import 'package:flutter/material.dart';
import '../models/batch_model.dart';
import '../services/batch_service.dart';
import '../utils/auth_manager.dart';

class BatchesScreen extends StatefulWidget {
  const BatchesScreen({super.key});

  @override
  State<BatchesScreen> createState() => _BatchesScreenState();
}

class _BatchesScreenState extends State<BatchesScreen> {
  final BatchService service = BatchService();

  List<BatchModel> batches = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadBatches();
  }

  Future<void> loadBatches() async {
    final token = await AuthManager.getToken();

    if (token == null) return;

    final res = await service.getBatches(token);

    if (res["success"] == true) {
      final List data = res["data"]["items"] ?? [];

      setState(() {
        batches = data.map((e) => BatchModel.fromJson(e)).toList();
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
      appBar: AppBar(title: const Text("Batches")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : batches.isEmpty
          ? const Center(child: Text("No batches found"))
          : ListView.builder(
              itemCount: batches.length,
              itemBuilder: (context, index) {
                final batch = batches[index];

                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(
                      batch.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                );
              },
            ),
    );
  }
}
