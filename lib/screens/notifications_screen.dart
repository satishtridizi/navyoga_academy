import 'package:flutter/material.dart';
import 'package:navyoga_academy/utils/auth_manager.dart';
import 'package:navyoga_academy/utils/app_snackbar.dart';

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
  bool isClearing = false;

  @override
  void initState() {
    super.initState();
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    final token = await AuthManager.getToken();

    if (token == null) {
      if (mounted) setState(() => isLoading = false);
      return;
    }

    try {
      final list = await service.getNotifications(token);
      if (!mounted) return;
      setState(() {
        notifications = list
            .whereType<Map>()
            .map((e) => NotificationModel.fromJson(Map<String, dynamic>.from(e)))
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      });
    } catch (_) {
      if (mounted) {
        AppSnackbar.showError(
          context,
          'Unable to load notifications. Please try again.',
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> markAsRead(String id) async {
    final token = await AuthManager.getToken();

    if (token == null) return;

    try {
      await service.markAsRead(token, id);
      if (!mounted) return;
      setState(() {
        final index = notifications.indexWhere((item) => item.id == id);
        if (index >= 0) notifications[index] = notifications[index].copyWith(isRead: true);
      });
    } catch (_) {
      if (mounted) AppSnackbar.showError(context, 'Unable to update this notification.');
    }
  }

  Future<void> deleteNotification(String id) async {
    final token = await AuthManager.getToken();

    if (token == null) return;

    try {
      await service.deleteNotification(token, id);
      if (mounted) setState(() => notifications.removeWhere((item) => item.id == id));
    } catch (_) {
      if (mounted) AppSnackbar.showError(context, 'Unable to delete this notification.');
    }
  }

  Future<void> clearAllNotifications() async {
    if (notifications.isEmpty || isClearing) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear all notifications?'),
        content: const Text('This will permanently remove every notification.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Clear all')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final token = await AuthManager.getToken();
    if (token == null) return;
    setState(() => isClearing = true);
    try {
      await service.clearAll(token, notifications.map((item) => item.id).toList());
      if (!mounted) return;
      setState(() => notifications.clear());
      AppSnackbar.showSuccess(context, 'All notifications cleared.');
    } catch (_) {
      if (mounted) AppSnackbar.showError(context, 'Unable to clear notifications. Please try again.');
    } finally {
      if (mounted) setState(() => isClearing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        actions: [
          if (notifications.isNotEmpty)
            TextButton.icon(
              onPressed: isClearing ? null : clearAllNotifications,
              icon: isClearing
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.delete_sweep_outlined),
              label: const Text('Clear all'),
            ),
          const SizedBox(width: 8),
        ],
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : notifications.isEmpty
          ? const Center(child: Text("No notifications"))
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (_, i) {
                final n = notifications[i];

                return ListTile(
                  minVerticalPadding: 14,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  tileColor: n.isRead ? null : Theme.of(context).colorScheme.primaryContainer.withOpacity(0.24),
                  title: Text(n.title),
                  subtitle: Text(n.message),
                  onTap: n.isRead ? null : () => markAsRead(n.id),

                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!n.isRead)
                        IconButton(
                          tooltip: 'Mark as read',
                          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                          icon: const Icon(Icons.check),
                          onPressed: () => markAsRead(n.id),
                        ),
                      IconButton(
                        tooltip: 'Delete notification',
                        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
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
