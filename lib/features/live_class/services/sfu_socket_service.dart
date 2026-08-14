import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:navyoga_academy/features/live_class/models/sfu_join_response_model.dart';
import 'package:socket_io_client/socket_io_client.dart'
    as io;

import '../constants/sfu_events.dart';
import '../models/sfu_participant.dart';

enum SfuConnectionStatus {
  disconnected,
  connecting,
  connected,
  reconnecting,
  failed,
}

class SfuSocketException implements Exception {
  const SfuSocketException(this.message);

  final String message;

  @override
  String toString() => message;
}

class SfuSocketService {
  SfuSocketService({
    this.baseUrl =
        'https://d20fx2gucmvzba.cloudfront.net',
  });

  final String baseUrl;

  io.Socket? _socket;

  bool _disposed = false;
  bool _classEndEmitted = false;

  final StreamController<SfuConnectionStatus>
      _connectionController =
      StreamController<SfuConnectionStatus>.broadcast();

  final StreamController<int>
      _waitingCountController =
      StreamController<int>.broadcast();

  final StreamController<Map<String, dynamic>>
      _hostJoinedController =
      StreamController<Map<String, dynamic>>.broadcast();

  final StreamController<List<SfuParticipant>>
      _participantsController =
      StreamController<List<SfuParticipant>>.broadcast();

  final StreamController<String>
      _errorController =
      StreamController<String>.broadcast();

  final StreamController<Map<String, dynamic>>
      _mutedStatusController =
      StreamController<Map<String, dynamic>>.broadcast();

  final StreamController<Map<String, dynamic>>
      _videoStatusController =
      StreamController<Map<String, dynamic>>.broadcast();

  final StreamController<Map<String, dynamic>>
      _newProducerController =
      StreamController<Map<String, dynamic>>.broadcast();

  final StreamController<String>
      _producerClosedController =
      StreamController<String>.broadcast();

  final StreamController<void>
      _classEndedController =
      StreamController<void>.broadcast();

  final StreamController<void>
      _reconnectController =
      StreamController<void>.broadcast();

  final StreamController<Map<String, dynamic>>
      _chatMessageController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<SfuConnectionStatus>
      get connectionStatusStream =>
          _connectionController.stream;

  Stream<int> get waitingCountStream =>
      _waitingCountController.stream;

  Stream<Map<String, dynamic>> get hostJoinedStream =>
      _hostJoinedController.stream;

  Stream<List<SfuParticipant>>
      get participantsStream =>
          _participantsController.stream;

  Stream<String> get errorStream =>
      _errorController.stream;

  Stream<Map<String, dynamic>> get mutedStatusStream =>
      _mutedStatusController.stream;

  Stream<Map<String, dynamic>> get videoStatusStream =>
      _videoStatusController.stream;

  Stream<Map<String, dynamic>> get newProducerStream =>
      _newProducerController.stream;

  Stream<String> get producerClosedStream =>
      _producerClosedController.stream;

  Stream<void> get classEndedStream =>
      _classEndedController.stream;

  Stream<void> get reconnectStream =>
      _reconnectController.stream;

  Stream<Map<String, dynamic>> get chatMessageStream =>
      _chatMessageController.stream;

  bool get isConnected =>
      _socket?.connected == true;

  Future<void> connect({
    required String token,
  }) async {
    if (_disposed) {
      throw const SfuSocketException(
        'Socket service has already been disposed.',
      );
    }

    await disconnect();

    _emitConnectionStatus(
      SfuConnectionStatus.connecting,
    );

    final socket = io.io(
      '$baseUrl/sfu',
      io.OptionBuilder()
          .setPath('/socket.io/')
          .setTransports(['websocket'])
          .setAuth({
            'token': token,
          })
          .setQuery({
            'token': token,
          })
          .disableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(10)
          .setReconnectionDelay(1000)
          .setReconnectionDelayMax(5000)
          .setTimeout(20000)
          .build(),
    );

    _socket = socket;
    _registerCoreListeners(socket);

    final completer = Completer<void>();

    late void Function(dynamic) connectHandler;
    late void Function(dynamic) errorHandler;

    connectHandler = (_) {
      if (!completer.isCompleted) {
        completer.complete();
      }
    };

    errorHandler = (dynamic error) {
      if (!completer.isCompleted) {
        completer.completeError(
          SfuSocketException(
            _extractErrorMessage(error),
          ),
        );
      }
    };

    socket.once('connect', connectHandler);
    socket.once('connect_error', errorHandler);

    socket.connect();

    try {
      await completer.future.timeout(
        const Duration(seconds: 20),
      );
    } on TimeoutException {
      throw const SfuSocketException(
        'Live-class connection timed out.',
      );
    }
  }

  void _registerCoreListeners(io.Socket socket) {
    socket.onConnect((_) {
      debugPrint(
        'SFU socket connected: ${socket.id}',
      );

      _emitConnectionStatus(
        SfuConnectionStatus.connected,
      );
    });

    socket.onConnectError((dynamic error) {
      final message = _extractErrorMessage(error);

      debugPrint(
        'SFU connect error: $message',
      );

      _emitConnectionStatus(
        SfuConnectionStatus.failed,
      );

      _emitError(message);
    });

    socket.onError((dynamic error) {
      final message = _extractErrorMessage(error);

      debugPrint('SFU socket error: $message');

      _emitError(message);
    });

    socket.onDisconnect((dynamic reason) {
      debugPrint(
        'SFU disconnected: $reason',
      );

      _emitConnectionStatus(
        SfuConnectionStatus.disconnected,
      );
    });

    socket.io.on('reconnect_attempt', (_) {
      _emitConnectionStatus(
        SfuConnectionStatus.reconnecting,
      );
    });

    socket.io.on('reconnect', (_) {
      _emitConnectionStatus(
        SfuConnectionStatus.connected,
      );

      if (!_reconnectController.isClosed) {
        _reconnectController.add(null);
      }

      // The controller owns the full room/media rejoin. A socket reconnect
      // invalidates the server-side mediasoup transports, so rejoining here
      // alone would leave the UI connected to stale transports.
    });

    socket.on(
      SfuEvents.waitingUpdate,
      (dynamic data) {
        final payload = _asMap(data);

        final waitingCount = _asInt(
          payload['waitingCount'],
        );

        _waitingCountController.add(
          waitingCount,
        );
      },
    );

    socket.on(
      SfuEvents.hostJoined,
      (dynamic data) {
        debugPrint('SFU event ← ${SfuEvents.hostJoined}: $data');
        _hostJoinedController.add(_asMap(data));
      },
    );

    socket.on(
      SfuEvents.participantUpdate,
      (dynamic data) {
        final payload = _asMap(data);

        final nested = payload['data'] is Map
            ? Map<String, dynamic>.from(payload['data'] as Map)
            : const <String, dynamic>{};
        final participantsValue = payload['participants'] ??
            payload['peers'] ??
            nested['participants'] ??
            nested['peers'];

        final participants =
            participantsValue is List
                ? participantsValue
                    .whereType<Map>()
                    .map(
                      (item) =>
                          SfuParticipant.fromJson(
                        Map<String, dynamic>.from(
                          item,
                        ),
                      ),
                    )
                    .toList()
                : <SfuParticipant>[];

        _participantsController.add(
          participants,
        );
      },
    );

    socket.on(
      SfuEvents.participantMutedStatus,
      (dynamic data) {
        debugPrint('SFU event ← ${SfuEvents.participantMutedStatus}: $data');
        _mutedStatusController.add(_unwrapEventData(data));
      },
    );

    socket.on(
      SfuEvents.participantVideoStatus,
      (dynamic data) {
        debugPrint('SFU event ← ${SfuEvents.participantVideoStatus}: $data');
        _videoStatusController.add(_unwrapEventData(data));
      },
    );

    socket.on(
      SfuEvents.newProducer,
      (dynamic data) {
        debugPrint('SFU event ← ${SfuEvents.newProducer}: $data');
        _newProducerController.add(_unwrapEventData(data));
      },
    );

    socket.on(
      'newProducer',
      (dynamic data) {
        debugPrint('SFU event ← newProducer: $data');
        _newProducerController.add(_unwrapEventData(data));
      },
    );

    socket.on(
      'sfu:producer-added',
      (dynamic data) {
        debugPrint('SFU event ← sfu:producer-added: $data');
        _newProducerController.add(_unwrapEventData(data));
      },
    );

    final producerClosedHandler = (dynamic data) {
      debugPrint('SFU event ← producerClosed: $data');
      final map = _asMap(data);
      final producerId = map['producerId']?.toString() ??
          map['id']?.toString() ??
          data?.toString() ??
          '';
      if (producerId.isNotEmpty) {
        _producerClosedController.add(producerId);
      }
    };

    socket.on(SfuEvents.producerClosed, producerClosedHandler);
    socket.on('producerClosed', producerClosedHandler);
    socket.on('producer-closed', producerClosedHandler);
    socket.on('sfu:producer-removed', producerClosedHandler);

    final classEndedHandler = (dynamic data) {
      debugPrint('SFU event ← classEnded: $data');
      if (!_classEndEmitted && !_classEndedController.isClosed) {
        _classEndEmitted = true;
        _classEndedController.add(null);
      }
    };

    socket.on('sfu:class-ended', classEndedHandler);
    socket.on('sfu:class-end', classEndedHandler);
    socket.on('sfu:end-class', classEndedHandler);
    socket.on('classEnded', classEndedHandler);
    socket.on('class-ended', classEndedHandler);
    socket.on('sfu:room-ended', classEndedHandler);
    socket.on('sfu:room-closed', classEndedHandler);
    socket.on('room-ended', classEndedHandler);
    socket.on('room-closed', classEndedHandler);
    socket.on('sfu:host-left', classEndedHandler);
    socket.on('host-left', classEndedHandler);
    socket.on('trainer-left', classEndedHandler);

    void chatMessageHandler(dynamic data) {
      final payload = _unwrapEventData(data);
      debugPrint('SFU event ← chat message: $payload');
      if (!_chatMessageController.isClosed) {
        _chatMessageController.add(payload);
      }
    }

    // The web client and backend have used different chat broadcast names over
    // time. Socket.IO's catch-all listener lets the mobile client receive the
    // active contract without registering the same payload multiple times.
    socket.onAny((String event, dynamic data) {
      final eventName = event.toLowerCase();
      if (eventName.contains('chat') || eventName.contains('message')) {
        debugPrint('SFU chat event name: $event');
        chatMessageHandler(data);
      }

      final isClassEndEvent =
          eventName.contains('class-end') ||
          eventName.contains('end-class') ||
          eventName.contains('room-end') ||
          eventName.contains('room-close') ||
          eventName.contains('host-left') ||
          eventName.contains('trainer-left');
      if (isClassEndEvent) {
        debugPrint('SFU class-end event name: $event');
        classEndedHandler(data);
      }
    });
  }

  Future<SfuJoinResponse> joinRoom({
    required String classId,
    required String studentName,
  }) async {
    final socket = _requireConnectedSocket();

    final response = await _emitWithAck(
      socket: socket,
      event: SfuEvents.joinRoom,
      payload: {
        'classId': classId,
        'name': studentName,
      },
    );

    final joinResponse =
        SfuJoinResponse.fromDynamic(response);

    if (joinResponse.status ==
        SfuJoinStatus.unknown) {
      throw SfuSocketException(
        joinResponse.message ??
            'The server returned an unknown room state.',
      );
    }

    if (joinResponse.isWaiting) {
      _waitingCountController.add(
        joinResponse.waitingCount,
      );
    }

    if (joinResponse.isJoined) {
      _participantsController.add(
        joinResponse.participants,
      );
    }

    return joinResponse;
  }

  Future<Map<String, dynamic>>
      createTransport({
    required String direction,
    Map<String, dynamic>? sctpCapabilities,
  }) async {
    assert(
      direction == 'send' ||
          direction == 'recv',
    );

    final socket = _requireConnectedSocket();

    final response = await _emitWithAck(
      socket: socket,
      event: SfuEvents.createTransport,
      payload: {
        'direction': direction,
        if (sctpCapabilities != null)
          'sctpCapabilities': sctpCapabilities,
      },
    );

    final map = _asMap(response);
    final data = map['data'] ??
        map['params'] ??
        map['transportOptions'] ??
        map['options'] ??
        map['transport'] ??
        map;

    return _asMap(data);
  }

  Future<void> connectTransport({
    required String transportId,
    required String direction,
    required Map<String, dynamic>
        dtlsParameters,
  }) async {
    final socket = _requireConnectedSocket();

    final response = await _emitWithAck(
      socket: socket,
      event: SfuEvents.connectTransport,
      payload: {
        'transportId': transportId,
        'direction': direction,
        'dtlsParameters': dtlsParameters,
      },
    );

    final payload = _asMap(response);

    final isOk = payload['ok'] == true ||
        payload['success'] == true ||
        payload['connected'] == true ||
        payload['status'] == 'ok' ||
        (payload.isNotEmpty && payload['error'] == null);

    if (!isOk) {
      throw SfuSocketException(
        payload['message']?.toString() ??
            payload['error']?.toString() ??
            'Unable to connect the media transport.',
      );
    }
  }

  Future<String> produce({
    required String transportId,
    required String kind,
    required String source,
    required Map<String, dynamic>
        rtpParameters,
    Map<String, dynamic>? appData,
  }) async {
    final socket = _requireConnectedSocket();

    final response = await _emitWithAck(
      socket: socket,
      event: SfuEvents.produce,
      payload: {
        'transportId': transportId,
        'kind': kind,
        'source': source,
        'rtpParameters': rtpParameters,
        if (appData != null)
          'appData': appData,
      },
    );

    final map = _asMap(response);
    final data = map['data'] is Map ? map['data'] : map;
    final producerId =
        data['id']?.toString() ?? data['producerId']?.toString();

    if (producerId == null ||
        producerId.isEmpty) {
      throw SfuSocketException(
        map['message']?.toString() ??
            map['error']?.toString() ??
            'The server did not return a producer ID.',
      );
    }

    return producerId;
  }

  Future<List<Map<String, dynamic>>>
      listProducers() async {
    final socket = _requireConnectedSocket();

    final response = await _emitWithAck(
      socket: socket,
      event: SfuEvents.listProducers,
      payload: <String, dynamic>{},
    );

    final map = _asMap(response);
    final nestedData = map['data'];
    final producersValue = map['producers'] ??
        (nestedData is Map ? nestedData['producers'] : nestedData) ??
        (response is List ? response : null);

    if (producersValue is! List) {
      return [];
    }

    return producersValue
        .whereType<Map>()
        .map(
          (item) =>
              Map<String, dynamic>.from(item),
        )
        .toList();
  }

  Future<Map<String, dynamic>> consume({
    required String transportId,
    required String producerId,
    required Map<String, dynamic>
        rtpCapabilities,
  }) async {
    final socket = _requireConnectedSocket();

    final response = await _emitWithAck(
      socket: socket,
      event: SfuEvents.consume,
      payload: {
        'transportId': transportId,
        'producerId': producerId,
        'rtpCapabilities':
            rtpCapabilities,
      },
    );

    final map = _asMap(response);
    final data = map['data'] ??
        map['params'] ??
        map['consumer'] ??
        map['options'] ??
        map;

    return _asMap(data);
  }

  Future<void> resumeConsumer({
    required String transportId,
    required String consumerId,
  }) async {
    final socket = _requireConnectedSocket();

    final response = await _emitWithAck(
      socket: socket,
      event: SfuEvents.resumeConsumer,
      payload: {
        'transportId': transportId,
        'consumerId': consumerId,
      },
    );

    final payload = _asMap(response);
    final isOk = payload['ok'] == true ||
        payload['success'] == true ||
        payload['resumed'] == true ||
        payload['status'] == 'ok' ||
        (payload.isNotEmpty && payload['error'] == null);

    if (!isOk) {
      throw SfuSocketException(
        payload['message']?.toString() ??
            payload['error']?.toString() ??
            'Unable to resume the remote media consumer.',
      );
    }
  }

  void sendChatMessage({
    required String classId,
    required String message,
  }) {
    final socket = _requireConnectedSocket();
    final payload = {
      'classId': classId,
      'roomId': classId,
      'message': message,
      'text': message,
      'content': message,
    };
    debugPrint('SFU emit → ${SfuEvents.sendChatMessage}: $payload');
    socket.emit(SfuEvents.sendChatMessage, payload);
  }

  Future<void> toggleMute({
    required bool isMuted,
  }) async {
    final socket = _requireConnectedSocket();
    debugPrint('SFU emit → ${SfuEvents.toggleMute}: is_muted=$isMuted');
    socket.emit(SfuEvents.toggleMute, {
      'is_muted': isMuted,
    });
  }

  Future<void> toggleVideo({
    required bool isVideoOff,
  }) async {
    final socket = _requireConnectedSocket();
    debugPrint('SFU emit → ${SfuEvents.toggleVideo}: is_video_off=$isVideoOff');
    socket.emit(SfuEvents.toggleVideo, {
      'is_video_off': isVideoOff,
    });
  }

  Future<void> closeProducer({
    required String source,
    String? producerId,
  }) async {
    final socket = _requireConnectedSocket();
    debugPrint('SFU emit → ${SfuEvents.closeProducer}: source=$source');
    socket.emit(SfuEvents.closeProducer, {
      'source': source,
      if (producerId != null) 'producerId': producerId,
    });
  }

  Future<dynamic> _emitWithAck({
    required io.Socket socket,
    required String event,
    required Map<String, dynamic> payload,
  }) async {
    final completer = Completer<dynamic>();

    debugPrint(
      'SFU emit → $event: $payload',
    );

    socket.emitWithAck(
      event,
      payload,
      ack: (dynamic response) {
        debugPrint(
          'SFU ack ← $event: $response',
        );

        if (!completer.isCompleted) {
          completer.complete(response);
        }
      },
    );

    try {
      return await completer.future.timeout(
        const Duration(seconds: 20),
      );
    } on TimeoutException {
      throw SfuSocketException(
        'No acknowledgement received for $event.',
      );
    }
  }

  io.Socket _requireConnectedSocket() {
    final socket = _socket;

    if (socket == null ||
        !socket.connected) {
      throw const SfuSocketException(
        'The live-class socket is not connected.',
      );
    }

    return socket;
  }

  Future<void> disconnect() async {
    final socket = _socket;

    _socket = null;

    if (socket == null) {
      return;
    }

    socket.clearListeners();
    socket.disconnect();
    socket.dispose();

    _emitConnectionStatus(
      SfuConnectionStatus.disconnected,
    );
  }

  void _emitConnectionStatus(
    SfuConnectionStatus status,
  ) {
    if (!_connectionController.isClosed) {
      _connectionController.add(status);
    }
  }

  void _emitError(String message) {
    if (!_errorController.isClosed) {
      _errorController.add(message);
    }
  }

  String _extractErrorMessage(dynamic error) {
    if (error is Map) {
      final map = Map<String, dynamic>.from(error);

      return map['message']?.toString() ??
          map['error']?.toString() ??
          error.toString();
    }

    return error?.toString() ??
        'Unknown socket error.';
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

  static Map<String, dynamic> _unwrapEventData(dynamic value) {
    final payload = _asMap(value);
    return payload['data'] is Map
        ? Map<String, dynamic>.from(payload['data'] as Map)
        : payload;
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

  Future<void> dispose() async {
    if (_disposed) {
      return;
    }

    _disposed = true;

    await disconnect();

    await _connectionController.close();
    await _waitingCountController.close();
    await _hostJoinedController.close();
    await _participantsController.close();
    await _errorController.close();
    await _mutedStatusController.close();
    await _videoStatusController.close();
    await _newProducerController.close();
    await _producerClosedController.close();
    await _classEndedController.close();
    await _reconnectController.close();
    await _chatMessageController.close();
  }
}
