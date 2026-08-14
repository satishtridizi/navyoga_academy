import 'dart:async';

import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../models/recording_api_model.dart';

class RecordingPlayerScreen extends StatefulWidget {
  const RecordingPlayerScreen({super.key, required this.recording});

  final RecordingApiModel recording;

  @override
  State<RecordingPlayerScreen> createState() => _RecordingPlayerScreenState();
}

class _RecordingPlayerScreenState extends State<RecordingPlayerScreen> {
  late final Player _player;
  late final VideoController _videoController;
  StreamSubscription<String>? _errorSubscription;
  String? _error;

  @override
  void initState() {
    super.initState();
    _player = Player();
    _videoController = VideoController(_player);
    _errorSubscription = _player.stream.error.listen((message) {
      if (mounted && message.trim().isNotEmpty) {
        setState(() => _error = message);
      }
    });
    _openRecording();
  }

  Future<void> _openRecording() async {
    final url = widget.recording.videoUrl.trim();
    if (url.isEmpty) {
      setState(() => _error = 'This recording does not have a video URL.');
      return;
    }

    try {
      await _player.open(
        Media(url, httpHeaders: const {'Accept': '*/*'}),
        play: true,
      );
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    }
  }

  @override
  void dispose() {
    _errorSubscription?.cancel();
    _player.dispose();
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
            Expanded(
              child: Center(
                child: _error == null
                    ? Video(
                        controller: _videoController,
                        fit: BoxFit.contain,
                      )
                    : Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'Unable to play this recording.\n\n$_error',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ),
              ),
            ),
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
}
