class SfuParticipant {
  const SfuParticipant({
    required this.userId,
    required this.socketId,
    required this.name,
    required this.role,
    required this.isMuted,
    required this.isVideoOff,
    required this.isScreenSharing,
    this.joinedAt,
  });

  final String userId;
  final String socketId;
  final String name;
  final String role;

  final bool isMuted;
  final bool isVideoOff;
  final bool isScreenSharing;

  final DateTime? joinedAt;

  bool get isHost {
    final r = role.toLowerCase();
    return r == 'host' || r == 'tutor' || r == 'teacher' || r == 'instructor' || r == 'admin';
  }

  SfuParticipant copyWith({
    String? userId,
    String? socketId,
    String? name,
    String? role,
    bool? isMuted,
    bool? isVideoOff,
    bool? isScreenSharing,
    DateTime? joinedAt,
  }) {
    return SfuParticipant(
      userId: userId ?? this.userId,
      socketId: socketId ?? this.socketId,
      name: name ?? this.name,
      role: role ?? this.role,
      isMuted: isMuted ?? this.isMuted,
      isVideoOff: isVideoOff ?? this.isVideoOff,
      isScreenSharing: isScreenSharing ?? this.isScreenSharing,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }

  factory SfuParticipant.fromJson(
    Map<String, dynamic> json,
  ) {
    final user = json['user'] is Map
        ? Map<String, dynamic>.from(json['user'] as Map)
        : const <String, dynamic>{};
    return SfuParticipant(
      userId: (json['userId'] ?? json['user_id'] ?? json['_id'] ??
              user['id'] ?? user['_id'])
          ?.toString() ?? '',
      socketId: (json['socketId'] ?? json['socket_id'] ?? json['peerId'] ??
              json['peer_id'])
          ?.toString() ?? '',
      name: (json['name'] ?? json['studentName'] ?? json['displayName'] ??
              user['name'])
          ?.toString() ?? 'Participant',
      role: (json['role'] ?? json['userRole'] ?? user['role'])?.toString() ??
          'guest',
      isMuted: _asBool(
        json['isMuted'] ?? json['is_muted'],
        fallback: true,
      ),
      isVideoOff: _asBool(
        json['isVideoOff'] ?? json['is_video_off'],
        fallback: true,
      ),
      isScreenSharing: _asBool(
        json['isScreenSharing'] ?? json['is_screen_sharing'],
      ),
      joinedAt: _parseJoinedAt(json['joinedAt'] ?? json['joined_at']),
    );
  }

  static bool _asBool(
    dynamic value, {
    bool fallback = false,
  }) {
    if (value is bool) {
      return value;
    }

    if (value is num) {
      return value != 0;
    }

    switch (value?.toString().toLowerCase()) {
      case 'true':
      case '1':
        return true;

      case 'false':
      case '0':
        return false;

      default:
        return fallback;
    }
  }

  static DateTime? _parseJoinedAt(dynamic value) {
    if (value is int) {
      return DateTime
          .fromMillisecondsSinceEpoch(value)
          .toLocal();
    }

    if (value is num) {
      return DateTime
          .fromMillisecondsSinceEpoch(
            value.toInt(),
          )
          .toLocal();
    }

    final rawValue = value?.toString();

    if (rawValue == null || rawValue.isEmpty) {
      return null;
    }

    final milliseconds = int.tryParse(rawValue);

    if (milliseconds != null) {
      return DateTime
          .fromMillisecondsSinceEpoch(milliseconds)
          .toLocal();
    }

    return DateTime.tryParse(rawValue)?.toLocal();
  }
}
