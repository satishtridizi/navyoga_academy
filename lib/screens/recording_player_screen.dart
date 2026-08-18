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

    return AspectRatio(
      aspectRatio: controller.value.aspectRatio,
      child: Stack(
        alignment: Alignment.center,
        children: [
          VideoPlayer(controller),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              setState(() {
                controller.value.isPlaying
                    ? controller.pause()
                    : controller.play();
              });
            },
            child: SizedBox.expand(
              child: Center(
                child: AnimatedOpacity(
                  opacity: controller.value.isPlaying ? 0 : 1,
                  duration: const Duration(milliseconds: 180),
                  child: const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.black54,
                    child: Icon(Icons.play_arrow, color: Colors.white, size: 38),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: VideoProgressIndicator(
              controller,
              allowScrubbing: true,
              colors: const VideoProgressColors(
                playedColor: Colors.deepOrange,
                bufferedColor: Colors.white38,
                backgroundColor: Colors.white24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
