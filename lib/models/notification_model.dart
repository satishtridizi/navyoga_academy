class NotificationModel {
  final String id;
  final String title;
  final String message;
  final bool isRead;
  final String createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: (json["id"] ?? json["_id"] ?? "").toString(),
      title: (json["title"] ?? "Notification").toString(),
      message: (json["message"] ?? json["body"] ?? "").toString(),
      isRead: json["isRead"] == true || json["is_read"] == true,
      createdAt: (json["createdAt"] ?? json["created_at"] ?? "").toString(),
    );
  }
}
