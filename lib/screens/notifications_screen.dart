import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/notification_model.dart';
import '../services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final service = NotificationService();

  List<NotificationModel> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token == null) return;

    final response = await service.getNotifications(token);

    if (response["success"] == true) {
      final list = response["data"] as List;

      setState(() {
        notifications = list.map((e) => NotificationModel.fromJson(e)).toList();
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  Future<void> markAsRead(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token == null) return;

    await service.markAsRead(token, id);
    loadNotifications(); // refresh
  }

  Future<void> deleteNotification(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token == null) return;

    await service.deleteNotification(token, id);
    loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notifications")),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : notifications.isEmpty
          ? const Center(child: Text("No notifications"))
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (_, i) {
                final n = notifications[i];

                return ListTile(
                  title: Text(n.title),
                  subtitle: Text(n.message),

                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!n.isRead)
                        IconButton(
                          icon: const Icon(Icons.check),
                          onPressed: () => markAsRead(n.id),
                        ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => deleteNotification(n.id),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
