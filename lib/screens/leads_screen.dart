import 'package:flutter/material.dart';
import 'package:navyoga_academy/utils/api_helper.dart';
import 'package:navyoga_academy/utils/auth_manager.dart';
import '../services/leads_service.dart';

class LeadsScreen extends StatefulWidget {
  const LeadsScreen({super.key});

  @override
  State<LeadsScreen> createState() => _LeadsScreenState();
}

class _LeadsScreenState extends State<LeadsScreen> {
  final LeadsService leadsService = LeadsService();

  List leads = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadLeads();
  }

  Future<void> loadLeads() async {
    final token = await AuthManager.getToken();

    if (token == null) return;
    final response = await leadsService.getLeads(token);

    if (ApiHelper.isSuccess(response)) {
      setState(() {
        leads = response["data"]["items"];
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Leads")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : leads.isEmpty
          ? const Center(child: Text("No leads found"))
          : ListView.builder(
              itemCount: leads.length,
              itemBuilder: (context, index) {
                final lead = leads[index];

                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(lead["name"] ?? ""),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(lead["email"] ?? ""),
                        Text("Status: ${lead["status"]}"),
                      ],
                    ),
                    trailing: Text(lead["source"] ?? ""),
                  ),
                );
              },
            ),
    );
  }
}
