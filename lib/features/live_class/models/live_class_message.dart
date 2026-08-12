class LiveClassMessage {
  const LiveClassMessage({
    required this.id,
    required this.text,
    required this.senderId,
    required this.senderName,
    required this.sentAt,
  });

  final String id;
  final String text;
  final String senderId;
  final String senderName;
  final DateTime sentAt;

  factory LiveClassMessage.fromJson(Map<String, dynamic> json) {
    final sender = json['sender'] is Map
        ? Map<String, dynamic>.from(json['sender'] as Map)
        : const <String, dynamic>{};
    final rawTime = json['sentAt'] ?? json['createdAt'] ?? json['timestamp'];
    final milliseconds = rawTime is num
        ? rawTime.toInt()
        : int.tryParse(rawTime?.toString() ?? '');
    final sentAt = milliseconds != null
        ? DateTime.fromMillisecondsSinceEpoch(milliseconds).toLocal()
        : DateTime.tryParse(rawTime?.toString() ?? '')?.toLocal() ??
            DateTime.now();

    return LiveClassMessage(
      id: (json['id'] ?? json['_id'] ?? json['messageId'] ??
              '${sentAt.microsecondsSinceEpoch}')
          .toString(),
      text: (json['message'] ?? json['text'] ?? json['content'] ?? '')
          .toString()
          .trim(),
      senderId: (json['senderId'] ?? json['userId'] ?? json['socketId'] ??
              sender['id'] ?? sender['_id'])
          ?.toString() ??
          '',
      senderName: (json['senderName'] ?? json['name'] ??
              json['userName'] ?? sender['name'])
          ?.toString() ??
          'Participant',
      sentAt: sentAt,
    );
  }
}
