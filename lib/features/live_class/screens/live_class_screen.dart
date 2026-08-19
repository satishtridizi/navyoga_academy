import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:navyoga_academy/features/live_class/controller/live_class_controller.dart';
import 'package:navyoga_academy/features/live_class/models/sfu_participant.dart';
import 'package:navyoga_academy/features/live_class/services/sfu_socket_service.dart';
import 'package:navyoga_academy/models/live_class_arguments.dart';
import 'package:navyoga_academy/utils/auth_manager.dart';

class LiveClassScreen extends StatefulWidget {
  const LiveClassScreen({
    super.key,
    required this.arguments,
  });

  final LiveClassArguments arguments;

  @override
  State<LiveClassScreen> createState() {
    return _LiveClassScreenState();
  }
}

class _LiveClassScreenState extends State<LiveClassScreen>
    with WidgetsBindingObserver {
  static const MethodChannel _screenChannel =
      MethodChannel('navyoga/screen_awake');
  final SfuSocketService _socketService = SfuSocketService();
  LiveClassController? _controller;

  Timer? _sessionTimer;
  final ValueNotifier<int> _sessionSecondsNotifier = ValueNotifier<int>(0);

  bool _showParticipantsSheet = false;
  bool _showChatSheet = false;
  bool _trainerEndHandled = false;
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_setKeepScreenAwake(true));
    _startSessionTimer();
    _initController();
  }

  Future<void> _setKeepScreenAwake(bool enabled) async {
    try {
      await _screenChannel.invokeMethod<void>(
        'setKeepScreenAwake',
        <String, bool>{'enabled': enabled},
      );
    } catch (error) {
      debugPrint('Unable to change keep-awake state: $error');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (controller == null) return;
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached) {
      unawaited(controller.suspendMediaForInterruption());
    } else if (state == AppLifecycleState.resumed) {
      unawaited(controller.resumeMediaAfterInterruption());
    }
  }

  Future<void> _initController() async {
    final token = await AuthManager.getToken();

    if (!mounted) return;

    if (token == null || token.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Authentication token unavailable. Please log in again.')),
      );
      return;
    }

    final controller = LiveClassController(
      arguments: widget.arguments,
      socketService: _socketService,
      token: token,
    );

    controller.addListener(_onControllerStateChanged);

    setState(() {
      _controller = controller;
    });

    await controller.initialize();
  }

  void _onControllerStateChanged() {
    if (!mounted) return;

    final controller = _controller;
    if (controller?.state == LiveClassViewState.ended &&
        controller?.endedByTrainer == true &&
        !_trainerEndHandled) {
      _trainerEndHandled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('The trainer has ended the live class.'),
          ),
        );
        Navigator.of(context).maybePop();
      });
      return;
    }

    setState(() {});
  }

  void _startSessionTimer() {
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        _sessionSecondsNotifier.value++;
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_setKeepScreenAwake(false));
    unawaited(SystemChrome.setPreferredOrientations(DeviceOrientation.values));
    _sessionTimer?.cancel();
    _sessionSecondsNotifier.dispose();
    _controller?.removeListener(_onControllerStateChanged);
    _controller?.dispose();
    _chatController.dispose();
    _chatScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    return Scaffold(
      backgroundColor: const Color(0xFF101014),
      appBar: _buildAppBar(controller),
      body: SafeArea(
        child: controller == null
            ? _buildConnectingView()
            : _buildBody(controller),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(LiveClassController? controller) {
    final participantCount = controller?.participants.length ?? 0;

    return AppBar(
      backgroundColor: const Color(0xFF101014),
      elevation: 0,
      foregroundColor: Colors.white,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.arguments.title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: (controller?.state == LiveClassViewState.joined)
                      ? Colors.green.withValues(alpha: 0.2)
                      : Colors.orange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: (controller?.state == LiveClassViewState.joined)
                        ? Colors.greenAccent.withValues(alpha: 0.5)
                        : Colors.orangeAccent.withValues(alpha: 0.5),
                  ),
                ),
                child: Text(
                  (controller?.state == LiveClassViewState.joined)
                      ? 'LIVE'
                      : (controller?.state == LiveClassViewState.waiting
                          ? 'WAITING FOR TRAINER'
                          : 'CONNECTING'),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: (controller?.state == LiveClassViewState.joined)
                        ? Colors.greenAccent
                        : Colors.orangeAccent,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ValueListenableBuilder<int>(
                valueListenable: _sessionSecondsNotifier,
                builder: (context, sessionSecs, _) {
                  final minutes = (sessionSecs ~/ 60).toString().padLeft(2, '0');
                  final seconds = (sessionSecs % 60).toString().padLeft(2, '0');
                  return Text(
                    '● LIVE • $minutes:$seconds',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: controller == null ? null : _toggleChatSheet,
          icon: Badge(
            label: Text('${controller?.messages.length ?? 0}'),
            isLabelVisible: (controller?.messages.isNotEmpty ?? false),
            child: const Icon(Icons.chat_bubble_outline),
          ),
          tooltip: 'Class chat',
        ),
        IconButton(
          onPressed: () => _toggleParticipantsSheet(),
          icon: Badge(
            label: Text('$participantCount'),
            isLabelVisible: participantCount > 0,
            child: const Icon(Icons.people_alt_outlined),
          ),
          tooltip: 'Participants',
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildBody(LiveClassController controller) {
    switch (controller.state) {
      case LiveClassViewState.initial:
      case LiveClassViewState.connecting:
        return _buildConnectingView();

      case LiveClassViewState.waiting:
        return _buildWaitingView(controller);

      case LiveClassViewState.failed:
        return _buildErrorView(controller);

      case LiveClassViewState.reconnecting:
        return _buildReconnectingView();

      case LiveClassViewState.preparingMedia:
      case LiveClassViewState.joined:
        return _buildStageView(controller);

      case LiveClassViewState.ended:
        return _buildEndedView();
    }
  }

  Widget _buildConnectingView() {
    final stateStr = _controller?.state.name ?? 'initial';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                color: Colors.deepPurpleAccent,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Connecting to ${widget.arguments.title}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.sensors_outlined,
                    size: 16,
                    color: Colors.deepPurpleAccent,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    stateStr == 'preparingMedia'
                        ? 'Setting up WebRTC audio & video streams...'
                        : 'Establishing secure SFU socket connection...',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaitingView(LiveClassController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.18),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.hourglass_top_rounded,
                size: 52,
                color: Colors.deepPurpleAccent,
              ),
            ),
            const SizedBox(height: 26),
            const Text(
              'Waiting for the tutor',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'The class will start automatically when the tutor opens the room.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white60,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 11,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF23232B),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                '${controller.waitingCount} ${controller.waitingCount == 1 ? 'student' : 'students'} waiting',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReconnectingView() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: Colors.amberAccent),
          SizedBox(height: 18),
          Text(
            'Reconnecting to live session...',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(LiveClassController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 20),
            const Text(
              'Unable to join class',
              style: TextStyle(
                color: Colors.white,
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              controller.errorMessage ?? 'Something went wrong.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white60,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => controller.retry(),
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEndedView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle_outline,
              size: 64,
              color: Colors.greenAccent,
            ),
            const SizedBox(height: 20),
            const Text(
              'Class Session Ended',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Thank you for joining today\'s live yoga session.',
              style: TextStyle(color: Colors.white60),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Return to App'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStageView(LiveClassController controller) {
    final host = controller.participants.firstWhere(
      (p) => p.isHost,
      orElse: () => SfuParticipant(
        userId: 'host',
        socketId: '',
        name: widget.arguments.tutorName ?? 'Instructor',
        role: 'host',
        isMuted: false,
        isVideoOff: false,
        isScreenSharing: false,
      ),
    );

    return Stack(
      children: [
        /// 1. MAIN TUTOR / HOST STAGE
        Positioned.fill(
          child: _buildHostStage(controller, host),
        ),

        /// 2. PIP LOCAL STUDENT TILE
        Positioned(
          top: 16,
          right: 16,
          child: _buildLocalStudentTile(controller),
        ),

        /// 3. BOTTOM CONTROL TOOLBAR
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _buildControlToolbar(controller),
        ),

        /// 4. PARTICIPANTS SHEET OVERLAY
        if (_showParticipantsSheet)
          Positioned.fill(
            child: _buildParticipantsSheet(controller),
          ),

        if (_showChatSheet)
          Positioned.fill(
            child: _buildChatSheet(controller),
          ),
      ],
    );
  }

  Widget _buildHostStage(LiveClassController controller, SfuParticipant host) {
    final hostRenderer = controller.hostVideoRenderer;
    final showHostVideo = hostRenderer != null &&
        hostRenderer.srcObject != null &&
        !host.isVideoOff;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF1E0030),
            Color(0xFF101018),
            Color(0xFF00152B),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Host Live WebRTC Video Stream (if active)
          if (showHostVideo)
            Positioned.fill(
              child: RTCVideoView(
                hostRenderer,
                objectFit: controller.isFitMode
                    ? RTCVideoViewObjectFit.RTCVideoViewObjectFitContain
                    : RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
              ),
            ),

          // Host Avatar / Placeholder View (if video off or renderer null)
          if (!showHostVideo)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Colors.purpleAccent, Colors.deepPurple],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withOpacity(0.4),
                        blurRadius: 24,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      host.name.isNotEmpty
                          ? host.name.substring(0, 1).toUpperCase()
                          : 'H',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      host.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'INSTRUCTOR',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      host.isMuted ? Icons.mic_off : Icons.mic,
                      size: 16,
                      color:
                          host.isMuted ? Colors.redAccent : Colors.greenAccent,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      host.isMuted ? 'Muted' : 'Speaking',
                      style: TextStyle(
                        fontSize: 13,
                        color: host.isMuted
                            ? Colors.redAccent
                            : Colors.greenAccent,
                      ),
                    ),
                  ],
                ),
              ],
            ),

          // Host Label & Aspect Ratio Control at Bottom-Left of Stage
          Positioned(
            bottom: 110,
            left: 20,
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.65),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        host.isMuted ? Icons.mic_off : Icons.mic,
                        size: 16,
                        color:
                            host.isMuted ? Colors.redAccent : Colors.greenAccent,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        host.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => controller.toggleFitMode(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.65),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: controller.isFitMode
                            ? Colors.deepPurpleAccent
                            : Colors.white24,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          controller.isFitMode
                              ? Icons.aspect_ratio
                              : Icons.fullscreen,
                          size: 16,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          controller.isFitMode ? 'Fill screen' : 'Fit video',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocalStudentTile(LiveClassController controller) {
    final isCameraOn = controller.isCameraOn;
    final isMicOn = controller.isMicOn;
    final studentName = widget.arguments.studentName;
    final localStreamAvailable = controller.localRenderer.srcObject != null &&
        controller.localRenderer.textureId != null;

    return Container(
      width: 120,
      height: 160,
      decoration: BoxDecoration(
        color: const Color(0xFF23232B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCameraOn ? Colors.deepPurpleAccent : Colors.white24,
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          children: [
            Positioned.fill(
              child: (isCameraOn && localStreamAvailable)
                  ? RTCVideoView(
                      controller.localRenderer,
                      mirror: controller.isFrontCamera,
                      objectFit:
                          RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                    )
                  : Container(
                      color: const Color(0xFF1A1A22),
                      child: Center(
                        child: CircleAvatar(
                          radius: 26,
                          backgroundColor: Colors.deepPurple,
                          child: Text(
                            studentName.isNotEmpty
                                ? studentName.substring(0, 1).toUpperCase()
                                : 'Y',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
            ),

            // Top Status Bar (Mic Indicator)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isMicOn ? Icons.mic : Icons.mic_off,
                  size: 14,
                  color: isMicOn ? Colors.greenAccent : Colors.redAccent,
                ),
              ),
            ),

            // Bottom Name Tag
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.65),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'You',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlToolbar(LiveClassController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.black.withOpacity(0.95),
            Colors.black.withOpacity(0.7),
            Colors.transparent,
          ],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
          /// MIC ON/OFF TOGGLE
          _buildControlButton(
            icon: controller.isMicOn ? Icons.mic : Icons.mic_off,
            label: controller.isMicOn ? 'Mute' : 'Unmute',
            isActive: controller.isMicOn,
            activeColor: Colors.greenAccent,
            inactiveColor: Colors.redAccent,
            onTap: () => controller.toggleMic(),
          ),

          /// VIDEO ON/OFF TOGGLE
          _buildControlButton(
            icon: controller.isCameraOn ? Icons.videocam : Icons.videocam_off,
            label: controller.isCameraOn ? 'Stop Video' : 'Start Video',
            isActive: controller.isCameraOn,
            activeColor: Colors.deepPurpleAccent,
            inactiveColor: Colors.redAccent,
            onTap: () => controller.toggleCamera(),
          ),

          /// SWITCH CAMERA
          _buildControlButton(
            icon: Icons.cameraswitch,
            label: 'Flip',
            isActive: true,
            activeColor: Colors.white,
            onTap: () => controller.switchCamera(),
          ),

          /// SCREEN ORIENTATION TOGGLE
          _buildControlButton(
            icon: Icons.screen_rotation,
            label: 'Rotate',
            isActive: true,
            activeColor: Colors.white,
            onTap: _rotateScreen,
          ),

          /// SPEAKER / EARPIECE TOGGLE
          _buildControlButton(
            icon: controller.isSpeakerphoneOn
                ? Icons.volume_up
                : Icons.phone_in_talk,
            label: controller.isSpeakerphoneOn ? 'Speaker' : 'Earpiece',
            isActive: controller.isSpeakerphoneOn,
            activeColor: Colors.cyanAccent,
            inactiveColor: Colors.orangeAccent,
            onTap: () => controller.toggleSpeakerphone(),
          ),

          /// PARTICIPANTS
          /// PARTICIPANTS
          _buildControlButton(
            icon: Icons.people,
            label: 'Participants',
            isActive: true,
            activeColor: Colors.white,
            onTap: () => _toggleParticipantsSheet(),
          ),

          /// LEAVE CLASS
          _buildControlButton(
            icon: Icons.call_end,
            label: 'Leave',
            isEnd: true,
            activeColor: Colors.redAccent,
            onTap: () => _confirmLeave(controller),
          ),
          ],
        ),
      ),
    );
  }

  Future<void> _rotateScreen() async {
    final isPortrait =
        MediaQuery.orientationOf(context) == Orientation.portrait;

    await SystemChrome.setPreferredOrientations(
      isPortrait
          ? const [
              DeviceOrientation.landscapeLeft,
              DeviceOrientation.landscapeRight,
            ]
          : const [
              DeviceOrientation.portraitUp,
              DeviceOrientation.portraitDown,
            ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
    bool isEnd = false,
    Color activeColor = Colors.white,
    Color inactiveColor = Colors.redAccent,
  }) {
    final buttonColor = isEnd
        ? Colors.red
        : (isActive ? activeColor.withOpacity(0.2) : inactiveColor.withOpacity(0.25));

    final iconColor = isEnd ? Colors.white : (isActive ? activeColor : inactiveColor);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
        GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: buttonColor,
              border: Border.all(
                color: isEnd ? Colors.redAccent : iconColor.withOpacity(0.5),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: isEnd ? Colors.red.withOpacity(0.4) : Colors.black26,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
          ),
        ),
        ],
      ),
    );
  }

  void _toggleParticipantsSheet() {
    setState(() {
      _showParticipantsSheet = !_showParticipantsSheet;
      if (_showParticipantsSheet) _showChatSheet = false;
    });
  }

  void _toggleChatSheet() {
    setState(() {
      _showChatSheet = !_showChatSheet;
      if (_showChatSheet) _showParticipantsSheet = false;
    });
    if (_showChatSheet) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollChatToEnd());
    }
  }

  void _sendChatMessage(LiveClassController controller) {
    final text = _chatController.text.trim();
    if (text.isEmpty) return;
    controller.sendChatMessage(text);
    _chatController.clear();
  }

  void _scrollChatToEnd() {
    if (!_chatScrollController.hasClients) return;
    _chatScrollController.animateTo(
      _chatScrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  Widget _buildChatSheet(LiveClassController controller) {
    final selfId = controller.self?.userId ?? '';
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollChatToEnd());

    return GestureDetector(
      onTap: _toggleChatSheet,
      child: Container(
        color: Colors.black54,
        alignment: Alignment.bottomCenter,
        child: GestureDetector(
          onTap: () {},
          child: Container(
            height: MediaQuery.of(context).size.height * 0.62,
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              // Scaffold already resizes the body for the keyboard. Applying
              // viewInsets again here caused the bottom sheet to overflow.
              bottom: 12,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFF1E1E26),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'CLASS CHAT',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _toggleChatSheet,
                      icon: const Icon(Icons.close, color: Colors.white70),
                    ),
                  ],
                ),
                const Divider(color: Colors.white12),
                Expanded(
                  child: controller.messages.isEmpty
                      ? const Center(
                          child: Text(
                            'No messages yet. Say hello!',
                            style: TextStyle(color: Colors.white54),
                          ),
                        )
                      : ListView.builder(
                          controller: _chatScrollController,
                          itemCount: controller.messages.length,
                          itemBuilder: (context, index) {
                            final message = controller.messages[index];
                            final isMine = message.senderId == selfId;
                            return Align(
                              alignment: isMine
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                constraints: const BoxConstraints(maxWidth: 300),
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 9,
                                ),
                                decoration: BoxDecoration(
                                  color: isMine
                                      ? Colors.deepPurple
                                      : const Color(0xFF30303A),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (!isMine)
                                      Text(
                                        message.senderName,
                                        style: const TextStyle(
                                          color: Colors.lightBlueAccent,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    Text(
                                      message.text,
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _chatController,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendChatMessage(controller),
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Message everyone...',
                          hintStyle: const TextStyle(color: Colors.white38),
                          filled: true,
                          fillColor: const Color(0xFF2A2A33),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      onPressed: () => _sendChatMessage(controller),
                      icon: const Icon(Icons.send),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildParticipantsSheet(LiveClassController controller) {
    final participants = controller.participants;

    return GestureDetector(
      onTap: () => _toggleParticipantsSheet(),
      child: Container(
        color: Colors.black54,
        alignment: Alignment.bottomCenter,
        child: GestureDetector(
          onTap: () {}, // Prevent taps inside sheet from closing it
          child: Container(
            height: MediaQuery.of(context).size.height * 0.55,
            decoration: const BoxDecoration(
              color: Color(0xFF1E1E26),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white30,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'PARTICIPANTS (${participants.length})',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    IconButton(
                      onPressed: () => _toggleParticipantsSheet(),
                      icon: const Icon(Icons.close, color: Colors.white70),
                    ),
                  ],
                ),
                const Divider(color: Colors.white12),
                Expanded(
                  child: participants.isEmpty
                      ? const Center(
                          child: Text(
                            'No participants found in room.',
                            style: TextStyle(color: Colors.white54),
                          ),
                        )
                      : ListView.separated(
                          itemCount: participants.length,
                          separatorBuilder: (_, _) => const Divider(color: Colors.white10),
                          itemBuilder: (context, index) {
                            final p = participants[index];
                            final isSelf = controller.self != null && p.userId == controller.self!.userId;

                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: p.isHost ? Colors.purple : Colors.deepPurple,
                                child: Text(
                                  p.name.isNotEmpty ? p.name.substring(0, 1).toUpperCase() : 'P',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              title: Row(
                                children: [
                                  Text(
                                    p.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (isSelf) ...[
                                    const SizedBox(width: 6),
                                    const Text(
                                      '(You)',
                                      style: TextStyle(
                                        color: Colors.white54,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              subtitle: Text(
                                p.isHost ? 'Instructor' : 'Student',
                                style: TextStyle(
                                  color: p.isHost ? Colors.purpleAccent : Colors.white38,
                                  fontSize: 12,
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    p.isMuted ? Icons.mic_off : Icons.mic,
                                    color: p.isMuted ? Colors.redAccent : Colors.greenAccent,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Icon(
                                    p.isVideoOff ? Icons.videocam_off : Icons.videocam,
                                    color: p.isVideoOff ? Colors.redAccent : Colors.greenAccent,
                                    size: 20,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmLeave(LiveClassController controller) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF23232B),
          title: const Text('Leave Class?', style: TextStyle(color: Colors.white)),
          content: const Text(
            'Are you sure you want to exit the live yoga class session?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: () async {
                final nav = Navigator.of(context);
                nav.pop();
                await controller.leave();
                nav.pop();
              },
              child: const Text('Leave'),
            ),
          ],
        );
      },
    );
  }
}
