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
    final status = json['status']?.toString().trim().toLowerCase();
    final readValue = json["isRead"] ??
        json["is_read"] ??
        json['read'] ??
        json['readStatus'] ??
        json['read_status'];
    return NotificationModel(
      id: (json["id"] ?? json["_id"] ?? "").toString(),
      title: (json["title"] ?? "Notification").toString(),
      message: (json["message"] ?? json["body"] ?? "").toString(),
      isRead: _toBool(readValue) ||
          json['readAt'] != null ||
          json['read_at'] != null ||
          status == 'read' ||
          status == 'seen',
      createdAt: (json["createdAt"] ?? json["created_at"] ?? "").toString(),
    );
  }

  NotificationModel copyWith({bool? isRead}) => NotificationModel(
        id: id,
        title: title,
        message: message,
        isRead: isRead ?? this.isRead,
        createdAt: createdAt,
      );

  static bool _toBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    final normalized = value?.toString().trim().toLowerCase();
    return normalized == 'true' || normalized == '1' || normalized == 'yes';
  }
}
