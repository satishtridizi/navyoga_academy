import 'dart:convert';

import 'sfu_participant.dart';

enum SfuJoinStatus {
  waiting,
  joined,
  unknown,
}

class SfuJoinResponse {
  const SfuJoinResponse({
    required this.status,
    required this.waitingCount,
    required this.participants,
    this.self,
    this.routerRtpCapabilities,
    this.message,
  });

  final SfuJoinStatus status;
  final int waitingCount;

  final SfuParticipant? self;
  final List<SfuParticipant> participants;

  final Map<String, dynamic>? routerRtpCapabilities;
  final String? message;

  bool get isWaiting {
    return status == SfuJoinStatus.waiting;
  }

  bool get isJoined {
    return status == SfuJoinStatus.joined;
  }

  factory SfuJoinResponse.fromDynamic(dynamic value) {
    final json = _asMap(value);

    final dataMap = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : <String, dynamic>{};

    final statusValue = json['status']?.toString().toLowerCase() ??
        json['roomState']?.toString().toLowerCase() ??
        json['state']?.toString().toLowerCase() ??
        dataMap['status']?.toString().toLowerCase() ??
        dataMap['roomState']?.toString().toLowerCase() ??
        dataMap['state']?.toString().toLowerCase();

    final status = switch (statusValue) {
      'waiting' => SfuJoinStatus.waiting,
      'joined' || 'success' || 'ok' => SfuJoinStatus.joined,
      _ => SfuJoinStatus.unknown,
    };

    final participantsData = json['participants'] ??
        json['peers'] ??
        dataMap['participants'] ??
        dataMap['peers'];

    final participants = participantsData is List
        ? participantsData
            .whereType<Map>()
            .map(
              (item) => SfuParticipant.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList()
        : <SfuParticipant>[];

    final selfData = json['self'] ??
        json['participant'] ??
        json['peer'] ??
        dataMap['self'] ??
        dataMap['participant'] ??
        dataMap['peer'];

    final rawRouterCapabilities = json['routerRtpCapabilities'] ??
        json['rtpCapabilities'] ??
        json['router_rtp_capabilities'] ??
        json['rtp_capabilities'] ??
        json['capabilities'] ??
        json['routerRtp'] ??
        dataMap['routerRtpCapabilities'] ??
        dataMap['rtpCapabilities'] ??
        dataMap['router_rtp_capabilities'] ??
        dataMap['rtp_capabilities'] ??
        dataMap['capabilities'];

    Map<String, dynamic>? routerRtpCapabilities;
    if (rawRouterCapabilities is Map) {
      routerRtpCapabilities = Map<String, dynamic>.from(rawRouterCapabilities);
    } else if (rawRouterCapabilities is String) {
      try {
        final decoded = jsonDecode(rawRouterCapabilities);
        if (decoded is Map) {
          routerRtpCapabilities = Map<String, dynamic>.from(decoded);
        }
      } catch (_) {}
    }

    final finalStatus = (status == SfuJoinStatus.unknown &&
            (routerRtpCapabilities != null || selfData != null))
        ? SfuJoinStatus.joined
        : status;

    return SfuJoinResponse(
      status: finalStatus,
      waitingCount: _asInt(
        json['waitingCount'] ?? dataMap['waitingCount'],
      ),
      self: selfData is Map
          ? SfuParticipant.fromJson(
              Map<String, dynamic>.from(selfData),
            )
          : null,
      participants: participants,
      routerRtpCapabilities: routerRtpCapabilities,
      message: json['message']?.toString() ?? dataMap['message']?.toString(),
    );
  }

  static Map<String, dynamic> _asMap(
    dynamic value,
  ) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    if (value is List &&
        value.isNotEmpty &&
        value.first is Map) {
      return Map<String, dynamic>.from(
        value.first as Map,
      );
    }

    return <String, dynamic>{};
  }

  static int _asInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }
}
