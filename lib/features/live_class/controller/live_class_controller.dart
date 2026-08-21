import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:mediasfu_mediasoup_client/mediasfu_mediasoup_client.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:navyoga_academy/features/live_class/models/sfu_join_response_model.dart';

import '../models/live_class_arguments.dart';
import '../models/live_class_message.dart';
import '../models/sfu_participant.dart';
import '../services/sfu_socket_service.dart';

export '../services/sfu_socket_service.dart' show SfuConnectionStatus;

enum LiveClassViewState {
  initial,
  connecting,
  waiting,
  preparingMedia,
  joined,
  reconnecting,
  failed,
  ended,
}

class LiveClassController extends ChangeNotifier {
  LiveClassController({
    required this.arguments,
    required this.socketService,
    required this.token,
  });

  final LiveClassArguments arguments;
  final SfuSocketService socketService;
  final String token;

  // ─── State ───────────────────────────────────────────────────────────────
  LiveClassViewState state = LiveClassViewState.initial;

  int waitingCount = 0;
  List<SfuParticipant> participants = [];
  final List<LiveClassMessage> messages = [];
  SfuParticipant? self;
  String? errorMessage;
  bool endedByTrainer = false;

  bool isMicOn = true;
  bool isCameraOn = true;
  bool isFrontCamera = true;
  bool isSpeakerphoneOn = true;
  bool isHostSpeaking = false;

  /// Controls video object fit for tutor stage (true: Contain/Fit full body, false: Cover/Fill).
  bool isFitMode = true;

  // ─── WebRTC / mediasoup objects ──────────────────────────────────────────

  /// Local camera/mic stream from getUserMedia.
  MediaStream? localStream;

  /// RTCVideoRenderer for the local camera preview (PIP tile).
  final RTCVideoRenderer localRenderer = RTCVideoRenderer();

  /// All active remote consumers: producerId → Consumer.
  final Map<String, Consumer> _consumers = {};
  final Set<String> _pendingConsumers = {};
  final Map<String, String> _producerPeerIds = {};
  final Set<String> _hostProducerIds = {};

  /// RTCVideoRenderer per remote producer (for video): producerId → renderer.
  final Map<String, RTCVideoRenderer> remoteVideoRenderers = {};

  // Keep every remote audio stream alive. Audio tracks play without a widget,
  // but dropping the stream reference can stop playback on some platforms.
  final Map<String, MediaStream> _remoteAudioStreams = {};

  // mediasoup device – loaded with router RTP capabilities after joining.
  Device? _device;

  // Transports
  Transport? _sendTransport;
  Transport? _recvTransport;

  // Local producers
  Producer? _audioProducer;
  Producer? _videoProducer;

  // Tracks produced locally
  MediaStreamTrack? _localAudioTrack;
  MediaStreamTrack? _localVideoTrack;

  // Guards
  bool _disposed = false;
  bool _joining = false;
  bool _mediaSetupInProgress = false;
  bool _reconnectInProgress = false;
  bool _mediaSuspended = false;
  bool _restoreMicAfterInterruption = false;
  bool _restoreCameraAfterInterruption = false;
  bool _micToggleInProgress = false;
  bool _cameraToggleInProgress = false;

  // Socket subscriptions
  final List<StreamSubscription<dynamic>> _subscriptions = [];

  // ─── Convenience getters ─────────────────────────────────────────────────

  /// A verified instructor renderer. Never fall back to an attendee stream.
  RTCVideoRenderer? get hostVideoRenderer {
    if (remoteVideoRenderers.isEmpty) return null;
    for (final entry in remoteVideoRenderers.entries) {
      if (_hostProducerIds.contains(entry.key)) return entry.value;
      final peerId = _producerPeerIds[entry.key];
      if (peerId == null || peerId.isEmpty) continue;
      final isInstructor = participants.any(
        (participant) =>
            participant.isHost &&
            (participant.userId == peerId || participant.socketId == peerId),
      );
      if (isInstructor) return entry.value;
    }
    return null;
  }

  bool get hasRemoteVideo => hostVideoRenderer != null;

  /// Returns only media that is owned by [participant]. Host-stage selection
  /// remains separate, so an attendee can never replace the trainer on stage.
  RTCVideoRenderer? videoRendererForParticipant(SfuParticipant participant) {
    for (final entry in remoteVideoRenderers.entries) {
      if (participant.producerIds.contains(entry.key)) return entry.value;
      final peerId = _producerPeerIds[entry.key];
      if (peerId == participant.userId || peerId == participant.socketId) {
        return entry.value;
      }
    }
    return null;
  }
  bool get hasLocalVideoPreview =>
      _localVideoTrack != null &&
      _localVideoTrack!.enabled &&
      localRenderer.srcObject != null;
  bool get isChangingLocalMedia =>
      _micToggleInProgress || _cameraToggleInProgress;

  // ─── Initialise ──────────────────────────────────────────────────────────

  Future<void> initialize() async {
    if (state != LiveClassViewState.initial) return;

    // Initialise local renderer so it's always safe to pass to RTCVideoView.
    await localRenderer.initialize();

    _listenToSocketEvents();

    _setState(LiveClassViewState.connecting);

    try {
      await socketService.connect(token: token);
      await _joinRoom();
    } catch (error, stackTrace) {
      debugPrint('Live class initialization error: $error');
      debugPrintStack(stackTrace: stackTrace);
      _fail(_friendlyLiveClassError(error));
    }
  }

  // ─── Socket event listeners ───────────────────────────────────────────────

  void _listenToSocketEvents() {
    _subscriptions.add(
      socketService.connectionStatusStream.listen((status) {
        switch (status) {
          case SfuConnectionStatus.reconnecting:
            _setState(LiveClassViewState.reconnecting);

          case SfuConnectionStatus.connected:
            // After reconnect the socket auto-rejoins via the reconnect handler
            // inside SfuSocketService. We watch for the join response via the
            // normal participantsStream / hostJoinedStream.
            break;

          case SfuConnectionStatus.disconnected:
            if (state == LiveClassViewState.joined ||
                state == LiveClassViewState.preparingMedia) {
              _setState(LiveClassViewState.reconnecting);
            }

          case SfuConnectionStatus.connecting:
          case SfuConnectionStatus.failed:
            break;
        }
      }),
    );

    _subscriptions.add(
      socketService.reconnectStream.listen((_) async {
        await _recoverAfterReconnect();
      }),
    );

    _subscriptions.add(
      socketService.waitingCountStream.listen((count) {
        waitingCount = count;
        _notify();
      }),
    );

    _subscriptions.add(
      socketService.hostJoinedStream.listen((data) async {
        debugPrint('hostJoined event received, state=$state');
        _registerHostMetadata(data);
        if (state == LiveClassViewState.waiting) {
          if (data.isNotEmpty) {
            final joinResponse = SfuJoinResponse.fromDynamic(data);
            if (joinResponse.isJoined &&
                joinResponse.routerRtpCapabilities != null &&
                joinResponse.routerRtpCapabilities!.isNotEmpty) {
              await _handleJoinResponse(joinResponse);
              return;
            }
          }
          await _joinRoomWithRetry();
        } else if (state == LiveClassViewState.joined) {
          // Host may have started a new stream — try consuming new producers.
          await _consumeAllRemoteProducers();
        }
      }),
    );

    _subscriptions.add(
      socketService.participantsStream.listen((value) {
        participants = _withSelf(value);
        _syncProducerOwnershipFromParticipants();
        final hosts = participants.where((participant) => participant.isHost);
        if (hosts.isNotEmpty && hosts.first.isMuted) {
          isHostSpeaking = false;
        }
        if (self != null) {
          final idx = participants.indexWhere(
            (p) =>
                p.userId == self!.userId ||
                (p.socketId.isNotEmpty && p.socketId == self!.socketId),
          );
          if (idx != -1) {
            self = participants[idx];
          }
        }
        if (state == LiveClassViewState.joined &&
            hostVideoRenderer == null &&
            participants.any((participant) => participant.isHost)) {
          unawaited(_consumeAllRemoteProducers());
        }
        _notify();
      }),
    );

    _subscriptions.add(
      socketService.mutedStatusStream.listen((data) {
        final userId = _eventParticipantId(data);
        final isMuted = _eventBool(
          data['isMuted'] ?? data['is_muted'] ?? data['muted'],
        );
        if (userId == null || userId.isEmpty) return;
        _updateParticipantState(userId: userId, isMuted: isMuted);
        if (isMuted && _isHostParticipantId(userId)) {
          isHostSpeaking = false;
          _notify();
        }
      }),
    );

    _subscriptions.add(
      socketService.speakingStatusStream.listen((data) {
        final userId = _eventParticipantId(data);
        final speaking = _eventBool(
          data['isSpeaking'] ?? data['is_speaking'] ?? data['speaking'] ??
              data['active'],
        );
        if (userId == null) return;
        if (!_isHostParticipantId(userId)) {
          if (speaking && isHostSpeaking) {
            isHostSpeaking = false;
            _notify();
          }
          return;
        }
        final host = participants.where((participant) => participant.isHost);
        isHostSpeaking = speaking &&
            (host.isEmpty || !host.first.isMuted);
        _notify();
      }),
    );

    _subscriptions.add(
      socketService.videoStatusStream.listen((data) {
        final userId = (data['userId'] ?? data['user_id'] ??
                data['socketId'] ?? data['socket_id'])
            ?.toString();
        final isVideoOff =
            data['isVideoOff'] == true || data['is_video_off'] == true;
        if (userId == null || userId.isEmpty) return;
        _updateParticipantState(userId: userId, isVideoOff: isVideoOff);
      }),
    );

    _subscriptions.add(
      socketService.errorStream.listen((message) {
        errorMessage = _friendlyLiveClassError(message);
        _notify();
      }),
    );

    _subscriptions.add(
      socketService.chatMessageStream.listen((data) {
        final message = LiveClassMessage.fromJson(data);
        if (message.text.isEmpty ||
            messages.any((item) => item.id == message.id)) {
          return;
        }
        messages.removeWhere(
          (item) =>
              item.id.startsWith('local-') &&
              item.senderId == message.senderId &&
              item.text == message.text &&
              message.sentAt.difference(item.sentAt).abs() <
                  const Duration(seconds: 15),
        );
        messages.add(message);
        _notify();
      }),
    );

    _subscriptions.add(
      socketService.newProducerStream.listen((data) async {
        debugPrint('newProducerStream event received: $data');
        final producerId = (data['producerId'] ?? data['producer_id'] ??
                data['id'])
            ?.toString() ?? '';
        if (producerId.isNotEmpty) {
          await _consumeSingleProducer({
            ...data,
            'id': producerId,
            'kind': data['kind']?.toString() ?? 'video',
          });
        } else {
          await _consumeAllRemoteProducers();
        }
      }),
    );

    _subscriptions.add(
      socketService.producerClosedStream.listen((producerId) async {
        debugPrint('producerClosed event received for $producerId');
        if (remoteVideoRenderers.containsKey(producerId)) {
          final renderer = remoteVideoRenderers.remove(producerId);
          renderer?.srcObject = null;
          await renderer?.dispose();
        }
        _consumers.remove(producerId);
        _remoteAudioStreams.remove(producerId);
        _producerPeerIds.remove(producerId);
        _hostProducerIds.remove(producerId);
        _notify();
      }),
    );

    _subscriptions.add(
      socketService.classEndedStream.listen((_) async {
        debugPrint('classEnded event received');
        endedByTrainer = true;
        _setState(LiveClassViewState.ended);
        await _teardownMediasoup();
      }),
    );
  }

  // ─── Room join flow ───────────────────────────────────────────────────────

  Future<void> _joinRoom() async {
    if (_joining) return;
    _joining = true;

    try {
      final response = await socketService.joinRoom(
        classId: arguments.classId,
        studentName: arguments.studentName,
      );
      await _handleJoinResponse(response);
    } catch (error) {
      _fail(_friendlyLiveClassError(error));
    } finally {
      _joining = false;
    }
  }

  Future<void> _joinRoomWithRetry({int maxRetries = 3}) async {
    for (int attempt = 0; attempt < maxRetries; attempt++) {
      await _joinRoom();
      if (state == LiveClassViewState.joined ||
          state == LiveClassViewState.preparingMedia) {
        return;
      }

      if (attempt < maxRetries - 1 && state == LiveClassViewState.waiting) {
        await Future.delayed(Duration(milliseconds: 500 * (attempt + 1)));
      } else {
        break;
      }
    }
  }

  Future<void> _recoverAfterReconnect() async {
    if (_disposed || _reconnectInProgress) return;
    _reconnectInProgress = true;
    debugPrint('Socket reconnected. Rebuilding the live-class media session...');
    try {
      _setState(LiveClassViewState.reconnecting);
      await _teardownMediasoup();
      await _joinRoom();
    } catch (error, stackTrace) {
      debugPrint('Live-class reconnect failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (!_disposed) {
        _fail('The connection was interrupted. Rejoin the class to continue.');
      }
    } finally {
      _reconnectInProgress = false;
    }
  }

  Future<void> _handleJoinResponse(SfuJoinResponse response) async {
    if (response.isWaiting) {
      waitingCount = response.waitingCount;
      _setState(LiveClassViewState.waiting);
      return;
    }

    if (response.isJoined) {
      // The mobile client is always a student. Some rooms previously promoted
      // the first peer to host when no tutor was connected yet.
      self = response.self?.copyWith(role: 'student');
      participants = _withSelf(
        response.participants.map((participant) {
          final isCurrentUser = self != null &&
              (participant.userId == self!.userId ||
                  (self!.socketId.isNotEmpty &&
                      participant.socketId == self!.socketId));
          return isCurrentUser
              ? participant.copyWith(role: 'student')
              : participant;
        }).toList(),
      );
      _syncProducerOwnershipFromParticipants();

      final caps = response.routerRtpCapabilities;
      if (caps == null || caps.isEmpty) {
        _fail('The server did not return RTP capabilities.');
        return;
      }

      _setState(LiveClassViewState.preparingMedia);
      await _setupMediasoup(caps);
    }
  }

  // ─── mediasoup full setup ─────────────────────────────────────────────────

  Future<void> _setupMediasoup(Map<String, dynamic> routerCaps) async {
    if (_mediaSetupInProgress || _disposed) return;
    _mediaSetupInProgress = true;

    try {
      // 1. Request permissions (soft check - doesn't block room join if denied)
      await _requestPermissions();

      try {
        await Helper.setSpeakerphoneOn(true);
      } catch (e) {
        debugPrint('Failed to set speakerphone on: $e');
      }

      // 2. Load mediasoup Device
      _device = Device();
      final rtpCaps = RtpCapabilities.fromMap(routerCaps);
      await _device!.load(routerRtpCapabilities: rtpCaps);
      debugPrint('mediasoup Device loaded');

      // 3. Create send transport and produce local tracks (if permitted)
      try {
        await _createSendTransport();
        await _startLocalMediaAndProduce();
      } catch (e) {
        debugPrint('Send transport/media setup skipped or failed: $e');
        isMicOn = false;
        isCameraOn = false;
        await _publishLocalMediaStatus();
      }

      // 4. Create the recv transport (for the host's streams)
      await _createRecvTransport();

      // 5. Consume all existing remote producers (host audio + video)
      await _consumeAllRemoteProducers();

      if (!_disposed) {
        _setState(LiveClassViewState.joined);
      }
    } catch (error, stack) {
      debugPrint('mediasoup setup error: $error\n$stack');
      if (!_disposed) {
        _fail('Media setup failed: $error');
      }
    } finally {
      _mediaSetupInProgress = false;
    }
  }

  // ─── Permissions ─────────────────────────────────────────────────────────

  Future<void> _requestPermissions() async {
    try {
      final micStatus = await Permission.microphone.request();
      final camStatus = await Permission.camera.request();
      debugPrint('Mic permission: $micStatus  Camera: $camStatus');
    } catch (e) {
      debugPrint('Permission request error: $e');
    }
  }

  List<SfuParticipant> _withSelf(List<SfuParticipant> roomParticipants) {
    final currentSelf = self;
    if (currentSelf == null) return roomParticipants;
    var containsSelf = false;
    final normalizedParticipants = roomParticipants.map((participant) {
      final isCurrentUser =
          (currentSelf.userId.isNotEmpty &&
              participant.userId == currentSelf.userId) ||
          (currentSelf.socketId.isNotEmpty &&
              participant.socketId == currentSelf.socketId);
      if (!isCurrentUser) return participant;
      containsSelf = true;
      return participant.copyWith(role: 'student');
    }).toList();
    return containsSelf
        ? normalizedParticipants
        : <SfuParticipant>[
            ...normalizedParticipants,
            currentSelf.copyWith(role: 'student'),
          ];
  }

  // ─── Send transport ───────────────────────────────────────────────────────

  Future<void> _createSendTransport() async {
    final transportData = await socketService.createTransport(
      direction: 'send',
      sctpCapabilities: _device!.sctpCapabilities.toMap(),
    );
    debugPrint('Send transport data received: ${transportData.keys.toList()}');

    _sendTransport = _device!.createSendTransportFromMap(
      transportData,
      producerCallback: _onProducerCreated,
    );

    _sendTransport!.on('connect', (Map data) async {
      final dtlsParameters = data['dtlsParameters'] as DtlsParameters;
      final callback = data['callback'] as Function;
      final errback = data['errback'] as Function;

      try {
        await socketService.connectTransport(
          transportId: _sendTransport!.id,
          direction: 'send',
          dtlsParameters: dtlsParameters.toMap(),
        );
        callback();
      } catch (e) {
        errback(e);
      }
    });

    _sendTransport!.on('produce', (Map data) async {
      final kind = data['kind'] as String;
      final rtpParameters = data['rtpParameters'] as RtpParameters;
      final appData = Map<String, dynamic>.from(data['appData'] as Map? ?? {});
      final source = appData['source']?.toString() ??
          (kind == 'audio' ? 'mic' : 'camera');
      final callback = data['callback'] as Function;
      final errback = data['errback'] as Function;

      try {
        final producerId = await socketService.produce(
          transportId: _sendTransport!.id,
          kind: kind,
          source: source,
          rtpParameters: rtpParameters.toMap(),
          appData: appData,
        );
        callback(producerId);
      } catch (e) {
        errback(e);
      }
    });

    debugPrint('Send transport created: ${_sendTransport!.id}');
  }

  void _onProducerCreated(Producer producer) {
    debugPrint('Producer created: id=${producer.id} kind=${producer.source}');
    if (producer.source == 'mic' || producer.track.kind == 'audio') {
      _audioProducer = producer;
    } else if (producer.source == 'camera' ||
        producer.track.kind == 'video') {
      _videoProducer = producer;
    }
  }

  // ─── Local media ─────────────────────────────────────────────────────────

  Future<void> _startLocalMediaAndProduce() async {
    bool micGranted = false;
    bool camGranted = false;

    try {
      micGranted = await Permission.microphone.isGranted;
      camGranted = await Permission.camera.isGranted;
    } catch (_) {}

    if (!micGranted && !camGranted) {
      debugPrint('Neither mic nor camera granted. Joining in listen-only mode.');
      isMicOn = false;
      isCameraOn = false;
      await _publishLocalMediaStatus();
      return;
    }

    MediaStream? stream;

    try {
      // Request media with high-quality WebRTC audio processing & optimal video resolution
      stream = await navigator.mediaDevices.getUserMedia({
        'audio': micGranted
            ? {
                'echoCancellation': true,
                'noiseSuppression': true,
                'autoGainControl': true,
                'googEchoCancellation': true,
                'googAutoGainControl': true,
                'googNoiseSuppression': true,
                'googHighpassFilter': true,
                'googTypingNoiseDetection': true,
              }
            : false,
        'video': camGranted
            ? {
                'facingMode': isFrontCamera ? 'user' : 'environment',
                'width': {'ideal': 640, 'max': 1280},
                'height': {'ideal': 480, 'max': 720},
                'frameRate': {'ideal': 24, 'max': 30},
              }
            : false,
      });
    } catch (e) {
      debugPrint('getUserMedia high quality failed: $e – trying standard resolution');
      if (micGranted || camGranted) {
        try {
          stream = await navigator.mediaDevices.getUserMedia({
            'audio': micGranted
                ? {
                    'echoCancellation': true,
                    'noiseSuppression': true,
                    'autoGainControl': true,
                  }
                : false,
            'video': camGranted
                ? {
                    'facingMode': isFrontCamera ? 'user' : 'environment',
                    'width': {'ideal': 640},
                    'height': {'ideal': 480},
                  }
                : false,
          });
        } catch (err) {
          debugPrint(
            'getUserMedia standard failed: $err – trying tracks separately',
          );
          MediaStream? audioOnlyStream;
          MediaStream? videoOnlyStream;
          if (micGranted) {
            try {
              audioOnlyStream = await navigator.mediaDevices.getUserMedia({
                'audio': true,
                'video': false,
              });
            } catch (_) {}
          }
          if (camGranted) {
            try {
              videoOnlyStream = await navigator.mediaDevices.getUserMedia({
                'audio': false,
                'video': {
                  'facingMode': isFrontCamera ? 'user' : 'environment',
                  'width': {'ideal': 640},
                  'height': {'ideal': 480},
                },
              });
            } catch (_) {}
          }
          stream = videoOnlyStream ?? audioOnlyStream;
          if (stream != null &&
              audioOnlyStream != null &&
              !identical(stream, audioOnlyStream)) {
            for (final track in audioOnlyStream.getAudioTracks()) {
              stream!.addTrack(track);
            }
          }
        }
      }
    }

    if (stream == null) {
      debugPrint('No local media stream available.');
      isMicOn = false;
      isCameraOn = false;
      await _publishLocalMediaStatus();
      return;
    }

    localStream = stream;

    // Bind to local renderer for the PIP tile.
    localRenderer.srcObject = stream;

    // Audio track → produce.
    final audioTracks = stream.getAudioTracks();
    if (audioTracks.isNotEmpty && _sendTransport != null) {
      _localAudioTrack = audioTracks.first;
      _localAudioTrack!.enabled = isMicOn;

      _sendTransport!.produce(
        track: _localAudioTrack!,
        stream: stream,
        source: 'mic',
        appData: _localProducerAppData('mic'),
        stopTracks: false,
        disableTrackOnPause: false,
      );
    }

    // Video track → produce.
    final videoTracks = stream.getVideoTracks();
    if (videoTracks.isNotEmpty && _sendTransport != null) {
      _localVideoTrack = videoTracks.first;
      _localVideoTrack!.enabled = isCameraOn;

      _sendTransport!.produce(
        track: _localVideoTrack!,
        stream: stream,
        source: 'camera',
        appData: _localProducerAppData('camera'),
        stopTracks: false,
        disableTrackOnPause: false,
      );
      isCameraOn = _localVideoTrack!.enabled;
    }

    isMicOn = _localAudioTrack?.enabled ?? false;
    isCameraOn = _localVideoTrack?.enabled ?? false;
    await _publishLocalMediaStatus();
    _notify();
    debugPrint('Local media started. audio=$isMicOn video=$isCameraOn');
  }

  Future<void> _publishLocalMediaStatus() async {
    if (socketService.isConnected) {
      await Future.wait([
        socketService.toggleMute(isMuted: !isMicOn),
        socketService.toggleVideo(isVideoOff: !isCameraOn),
      ]);
    }
    final currentSelf = self;
    if (currentSelf != null) {
      _updateParticipantState(
        userId: currentSelf.userId.isNotEmpty
            ? currentSelf.userId
            : currentSelf.socketId,
        isMuted: !isMicOn,
        isVideoOff: !isCameraOn,
      );
    }
    _notify();
  }

  Map<String, dynamic> _localProducerAppData(String source) {
    final currentSelf = self;
    return {
      'source': source,
      'role': 'student',
      'isHost': false,
      if (currentSelf != null && currentSelf.userId.isNotEmpty)
        'userId': currentSelf.userId,
      if (currentSelf != null && currentSelf.socketId.isNotEmpty)
        'peerId': currentSelf.socketId,
      'name': arguments.studentName,
    };
  }

  // ─── Recv transport ───────────────────────────────────────────────────────

  Future<void> _createRecvTransport() async {
    final transportData = await socketService.createTransport(
      direction: 'recv',
      sctpCapabilities: _device!.sctpCapabilities.toMap(),
    );
    debugPrint('Recv transport data received: ${transportData.keys.toList()}');

    _recvTransport = _device!.createRecvTransportFromMap(
      transportData,
      consumerCallback: _onConsumerCreated,
    );

    _recvTransport!.on('connect', (Map data) async {
      final dtlsParameters = data['dtlsParameters'] as DtlsParameters;
      final callback = data['callback'] as Function;
      final errback = data['errback'] as Function;

      try {
        await socketService.connectTransport(
          transportId: _recvTransport!.id,
          direction: 'recv',
          dtlsParameters: dtlsParameters.toMap(),
        );
        callback();
      } catch (e) {
        errback(e);
      }
    });

    debugPrint('Recv transport created: ${_recvTransport!.id}');
  }

  // ─── Consume remote producers ─────────────────────────────────────────────

  Future<void> _consumeAllRemoteProducers() async {
    if (_recvTransport == null || _device == null) {
      debugPrint('_consumeAllRemoteProducers: recv transport not ready');
      return;
    }

    try {
      final producers = await socketService.listProducers();
      debugPrint('Remote producers listed: ${producers.length}');
      if (kDebugMode) {
        debugPrint(
          'Remote producer identities: ${jsonEncode(producers)}',
          wrapWidth: 1024,
        );
      }

      _syncProducerOwnershipFromParticipants();
      // Preserve the order returned by the room. Parallel consumption makes
      // whichever renderer finishes first appear as the trainer, even when a
      // later producer belongs to another student.
      for (final producer in producers) {
        await _consumeSingleProducer(producer);
      }
    } catch (e) {
      debugPrint('Error listing/consuming producers: $e');
    }
  }

  void _syncProducerOwnershipFromParticipants() {
    for (final participant in participants) {
      if (participant.isHost) {
        _hostProducerIds.addAll(participant.producerIds);
      } else {
        _hostProducerIds.removeAll(participant.producerIds);
      }
    }
  }

  void _registerHostMetadata(Map<String, dynamic> data) {
    final nestedValues = <dynamic>[
      data,
      data['data'],
      data['host'],
      data['trainer'],
      data['tutor'],
      data['participant'],
      data['peer'],
    ];
    final producerIds = <String>{};
    String? hostPeerId;

    void inspect(dynamic value) {
      if (value is List) {
        for (final item in value) {
          inspect(item);
        }
        return;
      }
      if (value is! Map) return;
      final map = Map<String, dynamic>.from(value);
      hostPeerId ??= _extractProducerPeerId(map);
      void addId(dynamic candidate) {
        if (candidate is Map || candidate is List) {
          inspect(candidate);
          return;
        }
        final id = candidate?.toString().trim();
        if (id != null && id.isNotEmpty) producerIds.add(id);
      }

      addId(map['producerId']);
      addId(map['producer_id']);
      if (map.containsKey('kind') ||
          map.containsKey('source') ||
          map.containsKey('rtpParameters')) {
        addId(map['id']);
      }
      addId(map['audioProducerId']);
      addId(map['videoProducerId']);
      addId(map['audioProducer']);
      addId(map['videoProducer']);
      addId(map['producerIds']);
      addId(map['producers']);
    }

    for (final value in nestedValues) {
      inspect(value);
    }
    _hostProducerIds.addAll(producerIds);
    if (hostPeerId != null) {
      for (final producerId in producerIds) {
        _producerPeerIds[producerId] = hostPeerId!;
      }
    }
    if (producerIds.isNotEmpty) {
      debugPrint('Registered host producers from host event: $producerIds');
    }
  }

  String? _extractProducerPeerId(Map<String, dynamic> data) {
    final appData = data['appData'] is Map
        ? Map<String, dynamic>.from(data['appData'] as Map)
        : const <String, dynamic>{};
    final peer = data['peer'] is Map
        ? Map<String, dynamic>.from(data['peer'] as Map)
        : const <String, dynamic>{};
    final user = data['user'] is Map
        ? Map<String, dynamic>.from(data['user'] as Map)
        : const <String, dynamic>{};
    final producer = data['producer'] is Map
        ? Map<String, dynamic>.from(data['producer'] as Map)
        : const <String, dynamic>{};
    final value = data['peerId'] ??
        data['peer_id'] ??
        data['socketId'] ??
        data['socket_id'] ??
        data['userId'] ??
        data['user_id'] ??
        data['ownerId'] ??
        data['owner_id'] ??
        data['participantId'] ??
        data['participant_id'] ??
        producer['peerId'] ??
        producer['peer_id'] ??
        producer['userId'] ??
        producer['ownerId'] ??
        peer['id'] ??
        peer['_id'] ??
        peer['socketId'] ??
        user['id'] ??
        user['_id'] ??
        appData['peerId'] ??
        appData['peer_id'] ??
        appData['userId'] ??
        appData['user_id'];
    final result = value?.toString().trim();
    return result == null || result.isEmpty ? null : result;
  }

  bool _isVerifiedHostProducer(
    Map<String, dynamic> data, {
    String? peerId,
  }) {
    final producerId = (data['id'] ?? data['producerId'] ?? data['producer_id'])
        ?.toString();
    if (producerId != null && producerId.isNotEmpty) {
      for (final participant in participants) {
        if (participant.producerIds.contains(producerId)) {
          return participant.isHost;
        }
      }
    }
    if (peerId != null && peerId.isNotEmpty) {
      final owner = participants.where(
        (participant) =>
            participant.userId == peerId || participant.socketId == peerId,
      );
      if (owner.isNotEmpty) return owner.first.isHost;
    }

    final appData = data['appData'] is Map
        ? Map<String, dynamic>.from(data['appData'] as Map)
        : const <String, dynamic>{};
    final peer = data['peer'] is Map
        ? Map<String, dynamic>.from(data['peer'] as Map)
        : const <String, dynamic>{};
    final user = data['user'] is Map
        ? Map<String, dynamic>.from(data['user'] as Map)
        : const <String, dynamic>{};
    final explicitlyHost = data['isHost'] == true ||
        data['is_host'] == true ||
        peer['isHost'] == true ||
        peer['is_host'] == true ||
        user['isHost'] == true ||
        user['is_host'] == true ||
        appData['isHost'] == true ||
        appData['is_host'] == true;
    if (explicitlyHost) return true;
    final role = (data['role'] ??
            data['userRole'] ??
            data['peerRole'] ??
            peer['role'] ??
            user['role'] ??
            appData['role'] ??
            appData['userRole'])
        ?.toString()
        .toLowerCase()
        .trim();
    if (role == 'host' ||
        role == 'tutor' ||
        role == 'teacher' ||
        role == 'instructor' ||
        role == 'admin') {
      return true;
    }

    final producerName = (data['name'] ??
            data['displayName'] ??
            data['trainerName'] ??
            peer['name'] ??
            user['name'] ??
            appData['name'] ??
            appData['displayName'])
        ?.toString()
        .trim()
        .toLowerCase();
    final trainerName = arguments.tutorName?.trim().toLowerCase();
    return trainerName != null &&
        trainerName.isNotEmpty &&
        producerName != null &&
        producerName == trainerName;
  }

  Future<void> _consumeSingleProducer(
      Map<String, dynamic> producerInfo) async {
    final nestedProducer = producerInfo['producer'] is Map
        ? Map<String, dynamic>.from(producerInfo['producer'] as Map)
        : const <String, dynamic>{};
    final producerId = (producerInfo['id'] ?? producerInfo['producerId'] ??
            producerInfo['producer_id'] ?? nestedProducer['id'] ??
            nestedProducer['producerId'])
        ?.toString() ?? '';
    if (producerId.isEmpty) return;

    final peerId = _extractProducerPeerId(producerInfo);
    if (peerId != null && peerId.isNotEmpty) {
      _producerPeerIds[producerId] = peerId;
      final currentSelf = self;
      final isOwnProducer = currentSelf != null &&
          (currentSelf.userId == peerId || currentSelf.socketId == peerId);
      if (isOwnProducer) {
        debugPrint('Skipping own producer $producerId');
        return;
      }
    }

    if (_isVerifiedHostProducer(producerInfo, peerId: peerId)) {
      _hostProducerIds.add(producerId);
    }

    // Skip already consumed producers.
    if (_consumers.containsKey(producerId) ||
        !_pendingConsumers.add(producerId)) {
      debugPrint('Already consuming producer $producerId');
      return;
    }

    try {
      final rtpCapabilities = _device!.rtpCapabilities;
      final consumeData = await socketService.consume(
        transportId: _recvTransport!.id,
        producerId: producerId,
        rtpCapabilities: rtpCapabilities.toMap(),
      );
      final responsePeerId = _extractProducerPeerId(consumeData);
      if (responsePeerId != null && responsePeerId.isNotEmpty) {
        _producerPeerIds[producerId] = responsePeerId;
      }
      if (_isVerifiedHostProducer(
        consumeData,
        peerId: responsePeerId ?? peerId,
      )) {
        _hostProducerIds.add(producerId);
      }

      final consumerId = consumeData['id']?.toString() ?? '';
      final kindStr = consumeData['kind']?.toString() ?? 'audio';
      final rtpParamsRaw =
          consumeData['rtpParameters'] ?? consumeData['rtp_parameters'];

      // Never promote an unidentified stream to the host stage. The server
      // must identify the trainer by role, peer ownership, or producer ID.
      // All other streams are still consumed as attendee media.

      // Keep this at the application boundary: setRemoteDescription failures
      // originate from the SDP generated from these server RTP parameters.
      debugPrint(
        'Consume response for $producerId: '
        '${jsonEncode(consumeData)}',
        wrapWidth: 1024,
      );

      if (consumerId.isEmpty || rtpParamsRaw is! Map) {
        debugPrint(
          'Invalid consume response for producer $producerId: '
          'id=${consumeData['id']}, kind=${consumeData['kind']}, '
          'rtpParametersType=${rtpParamsRaw.runtimeType}',
        );
        return;
      }

      final kind = kindStr == 'video'
          ? RTCRtpMediaType.RTCRtpMediaTypeVideo
          : RTCRtpMediaType.RTCRtpMediaTypeAudio;

      final rtpParameters = RtpParameters.fromMap(rtpParamsRaw);

      _recvTransport!.consume(
        id: consumerId,
        producerId: producerId,
        kind: kind,
        rtpParameters: rtpParameters,
        peerId: responsePeerId ?? peerId ?? '',
        appData: Map<String, dynamic>.from(producerInfo['appData'] as Map? ?? {}),
      );
    } catch (e) {
      debugPrint('Failed to consume producer $producerId: $e');
    } finally {
      _pendingConsumers.remove(producerId);
    }
  }

  /// Called by the Transport via consumerCallback when a Consumer is ready.
  void _onConsumerCreated(Consumer consumer, Function? accept) async {
    final producerId = consumer.producerId;
    _consumers[producerId] = consumer;

    debugPrint(
        'Consumer created: id=${consumer.id} kind=${consumer.kind} producer=$producerId');

    try {
      if (consumer.kind == 'video') {
        await _setupVideoConsumer(consumer);
      } else {
        await _setupAudioConsumer(consumer);
      }
    } catch (error, stackTrace) {
      debugPrint('Unable to prepare remote ${consumer.kind}: $error');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      // Call accept even if renderer/audio-route setup fails so the transport
      // callback is never left hanging.
      accept?.call();
    }

    final recvTransport = _recvTransport;
    if (recvTransport != null) {
      try {
        await socketService.resumeConsumer(
          transportId: recvTransport.id,
          consumerId: consumer.id,
        );
        debugPrint('Consumer resumed: ${consumer.id}');
      } catch (error) {
        debugPrint('Failed to resume consumer ${consumer.id}: $error');
      }
    }

    _notify();
  }

  Future<void> _setupVideoConsumer(Consumer consumer) async {
    final renderer = RTCVideoRenderer();
    await renderer.initialize();

    if (_disposed || !_consumers.containsKey(consumer.producerId)) {
      await renderer.dispose();
      return;
    }

    final stream = consumer.stream;
    renderer.srcObject = stream;

    remoteVideoRenderers[consumer.producerId] = renderer;
    debugPrint('Video renderer set for producer ${consumer.producerId}');
    _notify();
  }

  Future<void> _setupAudioConsumer(Consumer consumer) async {
    final remoteAudioStream = consumer.stream;
    _remoteAudioStreams[consumer.producerId] = remoteAudioStream;
    try {
      if (remoteAudioStream.getAudioTracks().isNotEmpty) {
        final audioTrack = remoteAudioStream.getAudioTracks().first;
        audioTrack.enabled = true;
      }
      await Helper.setSpeakerphoneOn(isSpeakerphoneOn);
    } catch (e) {
      debugPrint('Error enabling speakerphone on audio consumer: $e');
    }
    debugPrint('Audio consumer ready for producer ${consumer.producerId}');
  }

  // ─── Mic / Camera toggles ─────────────────────────────────────────────────

  Future<void> toggleMic() async {
    if (_micToggleInProgress || _mediaSuspended) return;
    _micToggleInProgress = true;
    final previousValue = isMicOn;
    isMicOn = !previousValue;
    final isMuted = !isMicOn;

    debugPrint('Toggling Mic: isMicOn=$isMicOn');

    if (_localAudioTrack != null) {
      _localAudioTrack!.enabled = isMicOn;
    }

    try {
      if (isMicOn && _localAudioTrack == null) {
        await _createMicrophoneTrack();
      }
      if (isMicOn && _localAudioTrack == null) {
        throw StateError('Microphone permission is unavailable.');
      }
      if (isMicOn &&
          _sendTransport != null &&
          _localAudioTrack != null &&
          localStream != null) {
        if (_audioProducer == null || _audioProducer!.closed) {
          _sendTransport!.produce(
            track: _localAudioTrack!,
            stream: localStream!,
            source: 'mic',
            appData: _localProducerAppData('mic'),
            stopTracks: false,
            disableTrackOnPause: false,
          );
        }
      }

      await socketService.toggleMute(isMuted: isMuted);
      errorMessage = null;

      if (self != null) {
        _updateParticipantState(
          userId: self!.userId.isNotEmpty ? self!.userId : self!.socketId,
          isMuted: isMuted,
        );
      }
    } catch (e) {
      debugPrint('Error toggling mic: $e');
      isMicOn = previousValue;
      if (_localAudioTrack != null) {
        _localAudioTrack!.enabled = previousValue;
      }
      errorMessage =
          'Unable to change the microphone. Check its permission and connection.';
    }

    _micToggleInProgress = false;
    _notify();
  }

  Future<void> _createMicrophoneTrack() async {
    final granted = await Permission.microphone.request().isGranted;
    if (!granted) return;
    final microphoneStream = await navigator.mediaDevices.getUserMedia({
      'audio': {
        'echoCancellation': true,
        'noiseSuppression': true,
        'autoGainControl': true,
      },
      'video': false,
    });
    if (microphoneStream.getAudioTracks().isEmpty) {
      await microphoneStream.dispose();
      return;
    }
    _localAudioTrack = microphoneStream.getAudioTracks().first;
    if (localStream == null) {
      localStream = microphoneStream;
      localRenderer.srcObject = localStream;
    } else {
      localStream!.addTrack(_localAudioTrack!);
    }
  }

  void sendChatMessage(String value) {
    final text = value.trim();
    if (text.isEmpty || !socketService.isConnected) return;
    socketService.sendChatMessage(
      classId: arguments.classId,
      message: text,
    );
    final now = DateTime.now();
    messages.add(
      LiveClassMessage(
        id: 'local-${now.microsecondsSinceEpoch}',
        text: text,
        senderId: self?.userId ?? '',
        senderName: self?.name ?? arguments.studentName,
        sentAt: now,
      ),
    );
    _notify();
  }

  Future<void> toggleCamera() async {
    if (_cameraToggleInProgress || _mediaSuspended) return;
    _cameraToggleInProgress = true;
    final previousValue = isCameraOn;
    isCameraOn = !previousValue;
    final isVideoOff = !isCameraOn;

    debugPrint('Toggling Camera: isCameraOn=$isCameraOn');

    try {
      if (isCameraOn) {
        if (_localVideoTrack == null) {
          final camGranted = await Permission.camera.request().isGranted;
          if (camGranted) {
            final camStream = await navigator.mediaDevices.getUserMedia({
              'audio': false,
              'video': {
                'facingMode': isFrontCamera ? 'user' : 'environment',
                'width': {'ideal': 640},
                'height': {'ideal': 480},
              },
            });
            if (camStream.getVideoTracks().isNotEmpty) {
              _localVideoTrack = camStream.getVideoTracks().first;
              if (localStream != null) {
                localStream!.addTrack(_localVideoTrack!);
              } else {
                localStream = camStream;
              }
              localRenderer.srcObject = localStream;
            }
          }
        }

        if (_localVideoTrack != null && localStream != null) {
          _localVideoTrack!.enabled = true;
          if (_sendTransport != null &&
              (_videoProducer == null || _videoProducer!.closed)) {
            _sendTransport!.produce(
              track: _localVideoTrack!,
              stream: localStream!,
              source: 'camera',
              appData: _localProducerAppData('camera'),
              stopTracks: false,
              disableTrackOnPause: false,
            );
          }
        } else {
          throw StateError('Camera permission is unavailable.');
        }
      } else {
        if (_localVideoTrack != null) {
          _localVideoTrack!.enabled = false;
        }
      }

      await socketService.toggleVideo(isVideoOff: isVideoOff);
      errorMessage = null;

      if (self != null) {
        _updateParticipantState(
          userId: self!.userId.isNotEmpty ? self!.userId : self!.socketId,
          isVideoOff: isVideoOff,
        );
      }
    } catch (e) {
      debugPrint('Error toggling camera: $e');
      isCameraOn = previousValue;
      if (_localVideoTrack != null) {
        _localVideoTrack!.enabled = previousValue;
      }
      errorMessage =
          'Unable to change the camera. Check its permission and connection.';
    }

    _cameraToggleInProgress = false;
    _notify();
  }

  Future<void> switchCamera() async {
    isFrontCamera = !isFrontCamera;
    debugPrint('Switched camera: isFront=$isFrontCamera');

    if (_localVideoTrack != null) {
      try {
        await Helper.switchCamera(_localVideoTrack!);
      } catch (e) {
        debugPrint('switchCamera failed: $e');
      }
    }

    _notify();
  }

  Future<void> toggleSpeakerphone() async {
    isSpeakerphoneOn = !isSpeakerphoneOn;
    try {
      await Helper.setSpeakerphoneOn(isSpeakerphoneOn);
    } catch (e) {
      debugPrint('Failed to toggle speakerphone: $e');
    }
    _notify();
  }

  Future<void> suspendMediaForInterruption() async {
    if (_mediaSuspended) return;
    _mediaSuspended = true;
    _restoreMicAfterInterruption = isMicOn;
    _restoreCameraAfterInterruption = isCameraOn;

    if (_localAudioTrack != null) _localAudioTrack!.enabled = false;
    if (_localVideoTrack != null) _localVideoTrack!.enabled = false;
    isMicOn = false;
    isCameraOn = false;
    _notify();

    if (socketService.isConnected) {
      try {
        await Future.wait([
          socketService.toggleMute(isMuted: true),
          socketService.toggleVideo(isVideoOff: true),
        ]);
      } catch (error) {
        debugPrint('Unable to publish interrupted media state: $error');
      }
    }
  }

  Future<void> resumeMediaAfterInterruption() async {
    if (!_mediaSuspended) return;
    _mediaSuspended = false;
    isMicOn = _restoreMicAfterInterruption && _localAudioTrack != null;
    isCameraOn = _restoreCameraAfterInterruption && _localVideoTrack != null;
    if (_localAudioTrack != null) _localAudioTrack!.enabled = isMicOn;
    if (_localVideoTrack != null) _localVideoTrack!.enabled = isCameraOn;
    _notify();

    if (socketService.isConnected) {
      try {
        await Future.wait([
          socketService.toggleMute(isMuted: !isMicOn),
          socketService.toggleVideo(isVideoOff: !isCameraOn),
        ]);
      } catch (error) {
        debugPrint('Unable to restore media after interruption: $error');
      }
    }
  }

  void toggleFitMode() {
    isFitMode = !isFitMode;
    _notify();
  }

  // ─── Retry / Leave ───────────────────────────────────────────────────────

  Future<void> retry() async {
    errorMessage = null;
    await _teardownMediasoup();
    await socketService.disconnect();

    _setState(LiveClassViewState.connecting);

    try {
      await socketService.connect(token: token);
      await _joinRoom();
    } catch (error) {
      _fail(_friendlyLiveClassError(error));
    }
  }

  Future<void> leave() async {
    _setState(LiveClassViewState.ended);
    await _teardownMediasoup();
    await socketService.disconnect();
  }

  // ─── Mediasoup teardown ──────────────────────────────────────────────────

  Future<void> _teardownMediasoup() async {
    debugPrint('Tearing down mediasoup resources...');

    // Stop producers
    try {
      _audioProducer = null;
      _videoProducer = null;
    } catch (_) {}

    // Close transports (automatically closes producers/consumers)
    try {
      await _sendTransport?.close();
    } catch (_) {}
    _sendTransport = null;

    try {
      await _recvTransport?.close();
    } catch (_) {}
    _recvTransport = null;

    // Dispose remote video renderers
    for (final renderer in remoteVideoRenderers.values) {
      renderer.srcObject = null;
      await renderer.dispose();
    }
    remoteVideoRenderers.clear();
    _remoteAudioStreams.clear();
    _consumers.clear();
    _pendingConsumers.clear();
    _producerPeerIds.clear();
    _hostProducerIds.clear();

    // Stop local tracks
    if (localStream != null) {
      for (final track in localStream!.getTracks()) {
        await track.stop();
      }
      await localStream!.dispose();
      localStream = null;
    }
    _localAudioTrack = null;
    _localVideoTrack = null;

    localRenderer.srcObject = null;

    _device = null;
    isHostSpeaking = false;
  }

  // ─── Participant state helpers ────────────────────────────────────────────

  String? _eventParticipantId(Map<String, dynamic> data) {
    final speakerValue = data['speaker'] ?? data['activeSpeaker'];
    final peerValue = data['peer'] ?? speakerValue;
    final peer = peerValue is Map
        ? Map<String, dynamic>.from(peerValue)
        : const <String, dynamic>{};
    final user = data['user'] is Map
        ? Map<String, dynamic>.from(data['user'] as Map)
        : const <String, dynamic>{};
    final producerId = (data['producerId'] ?? data['producer_id'])?.toString();
    final value = data['userId'] ??
        data['user_id'] ??
        data['socketId'] ??
        data['socket_id'] ??
        data['peerId'] ??
        data['peer_id'] ??
        data['activeSpeakerId'] ??
        data['active_speaker_id'] ??
        peer['id'] ??
        peer['_id'] ??
        peer['socketId'] ??
        user['id'] ??
        user['_id'] ??
        (producerId == null ? null : _producerPeerIds[producerId]);
    final id = value?.toString().trim();
    if (id != null && id.isNotEmpty) return id;

    final name = (data['name'] ??
            data['displayName'] ??
            peer['name'] ??
            user['name'])
        ?.toString()
        .trim()
        .toLowerCase();
    if (name == null || name.isEmpty) return null;
    for (final participant in participants) {
      if (participant.name.trim().toLowerCase() == name) {
        return participant.userId.isNotEmpty
            ? participant.userId
            : participant.socketId;
      }
    }
    return null;
  }

  bool _isHostParticipantId(String id) => participants.any(
        (participant) =>
            participant.isHost &&
            (participant.userId == id || participant.socketId == id),
      );

  bool _eventBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    final normalized = value?.toString().trim().toLowerCase();
    return normalized == 'true' ||
        normalized == '1' ||
        normalized == 'yes' ||
        normalized == 'on';
  }

  void _updateParticipantState({
    required String userId,
    bool? isMuted,
    bool? isVideoOff,
  }) {
    bool updated = false;

    participants = participants.map((p) {
      if (p.userId == userId ||
          (p.socketId.isNotEmpty && p.socketId == userId)) {
        updated = true;
        return p.copyWith(
          isMuted: isMuted ?? p.isMuted,
          isVideoOff: isVideoOff ?? p.isVideoOff,
        );
      }
      return p;
    }).toList();

    if (self != null &&
        (self!.userId == userId || self!.socketId == userId)) {
      self = self!.copyWith(
        isMuted: isMuted ?? self!.isMuted,
        isVideoOff: isVideoOff ?? self!.isVideoOff,
      );
    }

    if (updated) _notify();
  }

  // ─── State helpers ───────────────────────────────────────────────────────

  String _friendlyLiveClassError(Object error) {
    final value = error.toString().toLowerCase();
    if (value.contains('permission') || value.contains('notallowed')) {
      return 'Camera and microphone access is required to join the class.';
    }
    if (value.contains('timeout')) {
      return 'The live class is taking too long to connect. Please try again.';
    }
    if (value.contains('token') || value.contains('unauthorized')) {
      return 'Your session has expired. Please sign in again.';
    }
    if (value.contains('socket') ||
        value.contains('connection') ||
        value.contains('network')) {
      return 'The live-class connection was interrupted. Please check your internet and retry.';
    }
    return 'Unable to join the live class right now. Please try again.';
  }

  void _fail(String message) {
    errorMessage =
        message.replaceFirst('SfuSocketException: ', '').replaceFirst(
          'Exception: ',
          '',
        );
    _setState(LiveClassViewState.failed);
  }

  void _setState(LiveClassViewState value) {
    state = value;
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  // ─── Dispose ─────────────────────────────────────────────────────────────

  @override
  Future<void> dispose() async {
    _disposed = true;

    for (final subscription in _subscriptions) {
      unawaited(subscription.cancel());
    }

    await _teardownMediasoup();
    await localRenderer.dispose();
    unawaited(socketService.dispose());

    super.dispose();
  }
}
