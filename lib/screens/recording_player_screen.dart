import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../models/recording_api_model.dart';

class RecordingPlayerScreen extends StatefulWidget {
  const RecordingPlayerScreen({super.key, required this.recording});

  final RecordingApiModel recording;

  @override
  State<RecordingPlayerScreen> createState() => _RecordingPlayerScreenState();
}

class _RecordingPlayerScreenState extends State<RecordingPlayerScreen> {
  VideoPlayerController? _controller;
  String? _error;
  double? _dragPositionSeconds;
  bool _seekInProgress = false;
  bool _fillVideo = false;

  @override
  void initState() {
    super.initState();
    _openRecording();
  }

  Future<void> _openRecording() async {
    final url = widget.recording.videoUrl.trim();
    if (url.isEmpty) {
      setState(() => _error = 'This recording does not have a video URL.');
      return;
    }

    final controller = VideoPlayerController.networkUrl(
      Uri.parse(url),
      httpHeaders: const {'Accept': '*/*'},
    );
    _controller = controller;

    try {
      await controller.initialize();
      await controller.play();
      if (mounted) setState(() {});
    } catch (error) {
      await controller.dispose();
      if (identical(_controller, controller)) _controller = null;
      if (mounted) setState(() => _error = error.toString());
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(widget.recording.title),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: Center(child: _buildPlayer())),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      widget.recording.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${widget.recording.yogaType}  •  ${widget.recording.level}',
                    style: const TextStyle(color: Colors.orangeAccent),
                  ),
                  if (widget.recording.description.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      widget.recording.description,
                      style: const TextStyle(color: Colors.white60),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayer() {
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'Unable to play this recording.\n\n$_error',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70),
        ),
      );
    }

    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return const CircularProgressIndicator(color: Colors.orangeAccent);
    }

    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final reportedDurationSeconds = value.duration.inSeconds;
        final fallbackDurationSeconds = widget.recording.durationSeconds > 0
            ? widget.recording.durationSeconds
            : widget.recording.durationMinutes * 60;
        final observedPositionSeconds = value.position.inSeconds;
        final hasInvalidShortDuration = reportedDurationSeconds > 0 &&
            reportedDurationSeconds < 30;
        final hasReliableDuration = !hasInvalidShortDuration &&
            reportedDurationSeconds >= 30;
        final knownDurationSeconds = hasReliableDuration
            ? reportedDurationSeconds
            : fallbackDurationSeconds;
        final durationSeconds = [
          knownDurationSeconds,
          observedPositionSeconds,
          1,
        ].reduce((largest, item) => item > largest ? item : largest);
        final canSeek = knownDurationSeconds > 0;
        final positionSeconds = value.position.inSeconds.clamp(
          0,
          durationSeconds,
        );
        final sliderValue =
            (_dragPositionSeconds ?? positionSeconds.toDouble()).clamp(
          0.0,
          durationSeconds > 0 ? durationSeconds.toDouble() : 1.0,
        );
        final nativeAspectRatio = value.aspectRatio > 0
            ? value.aspectRatio
            : 16 / 9;

        return AspectRatio(
          aspectRatio: _fillVideo ? 16 / 9 : nativeAspectRatio,
          child: Stack(
            alignment: Alignment.center,
            children: [
              ClipRect(
                child: SizedBox.expand(
                  child: FittedBox(
                    fit: _fillVideo ? BoxFit.cover : BoxFit.contain,
                    child: SizedBox(
                      width: value.size.width > 0 ? value.size.width : 16,
                      height: value.size.height > 0 ? value.size.height : 9,
                      child: VideoPlayer(controller),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () async {
                  if (value.isPlaying) {
                    await controller.pause();
                  } else {
                    if (durationSeconds > 0 &&
                        positionSeconds >= durationSeconds) {
                      await controller.seekTo(Duration.zero);
                    }
                    await controller.play();
                  }
                },
                child: SizedBox.expand(
                  child: Center(
                    child: AnimatedOpacity(
                      opacity: value.isPlaying ? 0 : 1,
                      duration: const Duration(milliseconds: 180),
                      child: const CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.black54,
                        child: Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 38,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: _buildFitControl(),
              ),
              Positioned(
                left: 8,
                right: 8,
                bottom: 2,
                child: Row(
                  children: [
                    Text(
                      _formatTime(Duration(seconds: sliderValue.round())),
                      style: const TextStyle(color: Colors.white, fontSize: 11),
                    ),
                    Expanded(
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: Colors.deepOrange,
                          inactiveTrackColor: Colors.white30,
                          thumbColor: Colors.deepOrange,
                          overlayColor: Colors.deepOrange.withValues(alpha: 0.2),
                          trackHeight: 3,
                        ),
                        child: Slider(
                          min: 0,
                          max: durationSeconds > 0
                              ? durationSeconds.toDouble()
                              : 1,
                          value: sliderValue,
                          onChanged: !canSeek || _seekInProgress
                              ? null
                              : (newValue) {
                                  setState(
                                    () => _dragPositionSeconds = newValue,
                                  );
                                },
                          onChangeEnd: !canSeek
                              ? null
                              : (newValue) => _seekTo(controller, newValue),
                        ),
                      ),
                    ),
                    Text(
                      canSeek
                          ? _formatTime(
                              Duration(seconds: knownDurationSeconds),
                            )
                          : '--:--',
                      style: const TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _seekTo(
    VideoPlayerController controller,
    double positionSeconds,
  ) async {
    if (_seekInProgress) return;
    setState(() => _seekInProgress = true);
    try {
      await controller.seekTo(Duration(seconds: positionSeconds.round()));
    } catch (error) {
      debugPrint('Unable to seek recording: $error');
    } finally {
      if (mounted) {
        setState(() {
          _dragPositionSeconds = null;
          _seekInProgress = false;
        });
      }
    }
  }

  Widget _buildFitControl() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _displayModeButton(
            label: 'Fit',
            icon: Icons.fit_screen_outlined,
            selected: !_fillVideo,
            onTap: () => setState(() => _fillVideo = false),
          ),
          _displayModeButton(
            label: 'Fill',
            icon: Icons.fullscreen_outlined,
            selected: _fillVideo,
            onTap: () => setState(() => _fillVideo = true),
          ),
        ],
      ),
    );
  }

  Widget _displayModeButton({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: selected ? Colors.deepOrange : Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 16),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(Duration value) {
    final hours = value.inHours;
    final minutes = value.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = value.inSeconds.remainder(60).toString().padLeft(2, '0');
    return hours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
  }
}
