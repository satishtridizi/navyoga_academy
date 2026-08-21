import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  Future<void> _deleteDismissedNotification(String id) async {
    final token = await AuthManager.getToken();
    if (token == null) return;
    try {
      await service.deleteNotification(token, id);
    } catch (_) {
      if (!mounted) return;
      AppSnackbar.showError(
        context,
        'Unable to delete the notification. Refresh to restore it.',
      );
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

  Future<void> markAllAsRead() async {
    final unread = notifications.where((item) => !item.isRead).toList();
    if (unread.isEmpty) return;
    final token = await AuthManager.getToken();
    if (token == null) return;
    try {
      await Future.wait(
        unread.map((item) => service.markAsRead(token, item.id)),
      );
      if (!mounted) return;
      setState(() {
        notifications = notifications
            .map((item) => item.copyWith(isRead: true))
            .toList();
      });
      AppSnackbar.showSuccess(context, 'All notifications marked as read.');
    } catch (_) {
      if (mounted) {
        AppSnackbar.showError(context, 'Unable to update notifications.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F5FA),
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh notifications',
            onPressed: isLoading ? null : loadNotifications,
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: isLoading
          ? _buildLoadingState()
          : notifications.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  color: const Color(0xFF7B0AA5),
                  onRefresh: loadNotifications,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                    itemCount: notifications.length + 1,
                    itemBuilder: (_, index) {
                      if (index == 0) return _buildSummaryHeader();
                      return _buildNotificationCard(notifications[index - 1]);
                    },
                  ),
                ),
    );
  }

  Widget _buildSummaryHeader() {
    final unreadCount = notifications.where((item) => !item.isRead).length;
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF642D), Color(0xFF7B0AA5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x337B0AA5),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(Icons.notifications_active_outlined, color: Colors.white),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      unreadCount == 0 ? 'You are all caught up' : '$unreadCount unread',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${notifications.length} notification${notifications.length == 1 ? '' : 's'} in your inbox',
                      style: TextStyle(color: Colors.white.withOpacity(0.82), fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              if (unreadCount > 0)
                Expanded(
                  child: _headerAction(
                    icon: Icons.done_all_rounded,
                    label: 'Mark all read',
                    onTap: markAllAsRead,
                  ),
                ),
              if (unreadCount > 0) const SizedBox(width: 10),
              Expanded(
                child: _headerAction(
                  icon: Icons.delete_sweep_outlined,
                  label: isClearing ? 'Clearing...' : 'Clear all',
                  onTap: isClearing ? null : clearAllNotifications,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerAction({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.white.withOpacity(0.16),
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    final accent = _notificationColor(notification);
    return Dismissible(
      key: ValueKey(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        setState(
          () => notifications.removeWhere((item) => item.id == notification.id),
        );
        _deleteDismissedNotification(notification.id);
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.only(right: 24),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: const Color(0xFFE54B4B),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delete_outline_rounded, color: Colors.white),
            SizedBox(height: 2),
            Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: notification.isRead ? Colors.white : const Color(0xFFFFFCF8),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: notification.isRead ? const Color(0xFFECE7EF) : accent.withOpacity(0.35),
          ),
          boxShadow: const [
            BoxShadow(color: Color(0x0D241B32), blurRadius: 12, offset: Offset(0, 4)),
          ],
        ),
        child: InkWell(
          onTap: notification.isRead ? null : () => markAsRead(notification.id),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(15, 15, 8, 15),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(_notificationIcon(notification), color: accent, size: 23),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                color: const Color(0xFF241B32),
                                fontSize: 15,
                                height: 1.25,
                                fontWeight: notification.isRead ? FontWeight.w600 : FontWeight.w800,
                              ),
                            ),
                          ),
                          if (!notification.isRead) ...[
                            const SizedBox(width: 8),
                            Container(width: 8, height: 8, decoration: BoxDecoration(color: accent, shape: BoxShape.circle)),
                          ],
                        ],
                      ),
                      if (notification.message.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          notification.message,
                          style: const TextStyle(color: Color(0xFF686071), fontSize: 13, height: 1.4),
                        ),
                      ],
                      const SizedBox(height: 9),
                      Row(
                        children: [
                          Icon(Icons.schedule_rounded, size: 14, color: accent),
                          const SizedBox(width: 5),
                          Text(
                            _formatTimestamp(notification.createdAt),
                            style: TextStyle(color: accent, fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                          if (!notification.isRead) ...[
                            const Spacer(),
                            const Text(
                              'Tap to mark read',
                              style: TextStyle(color: Color(0xFF81798C), fontSize: 10),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Delete notification',
                  onPressed: () => deleteNotification(notification.id),
                  icon: const Icon(Icons.close_rounded, size: 19),
                  color: const Color(0xFF938B9B),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: Color(0xFF7B0AA5)),
          SizedBox(height: 16),
          Text('Loading your notifications...'),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return RefreshIndicator(
      onRefresh: loadNotifications,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.sizeOf(context).height * 0.16),
          Center(
            child: Container(
              width: 92,
              height: 92,
              decoration: const BoxDecoration(color: Color(0xFFFFE8DE), shape: BoxShape.circle),
              child: const Icon(Icons.notifications_none_rounded, size: 44, color: Color(0xFFFF642D)),
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'You are all caught up!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF241B32)),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Class updates, reminders and account alerts will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF81798C), height: 1.45),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(String value) {
    final parsed = DateTime.tryParse(value)?.toLocal();
    if (parsed == null) return 'Recently';
    final difference = DateTime.now().difference(parsed);
    if (difference.isNegative) return DateFormat('d MMM, h:mm a').format(parsed);
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes} min ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays == 1) return 'Yesterday, ${DateFormat('h:mm a').format(parsed)}';
    return DateFormat('d MMM, h:mm a').format(parsed);
  }

  IconData _notificationIcon(NotificationModel notification) {
    final text = '${notification.title} ${notification.message}'.toLowerCase();
    if (text.contains('class') || text.contains('yoga')) return Icons.self_improvement_rounded;
    if (text.contains('payment') || text.contains('subscription')) return Icons.workspace_premium_outlined;
    if (text.contains('reward') || text.contains('referral')) return Icons.card_giftcard_rounded;
    return Icons.notifications_active_outlined;
  }

  Color _notificationColor(NotificationModel notification) {
    final text = '${notification.title} ${notification.message}'.toLowerCase();
    if (text.contains('payment') || text.contains('subscription')) return const Color(0xFF7B0AA5);
    if (text.contains('reward') || text.contains('referral')) return const Color(0xFFDA8B00);
    return const Color(0xFFFF642D);
  }
}
