import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class LessonVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final VoidCallback onNinetyPercentWatched;

  const LessonVideoPlayer({
    super.key,
    required this.videoUrl,
    required this.onNinetyPercentWatched,
  });

  @override
  State<LessonVideoPlayer> createState() => _LessonVideoPlayerState();
}

class _LessonVideoPlayerState extends State<LessonVideoPlayer> {
  VideoPlayerController? controller;
  bool isReady = false;
  String? error;
  bool hasTriggeredCompletion = false;
  @override
  void initState() {
    super.initState();

    print("VIDEO SCREEN INIT");
    print("VIDEO URL => ${widget.videoUrl}");

    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    print("VIDEO INITIALIZING");
    controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));

    try {
      await controller!.initialize();
      controller!.addListener(() {
        if (hasTriggeredCompletion) return;

        final duration = controller!.value.duration;
        final position = controller!.value.position;

        if (duration.inMilliseconds == 0) return;

        final progress = position.inMilliseconds / duration.inMilliseconds;

        if (progress >= 0.9) {
          hasTriggeredCompletion = true;

          print("90% WATCHED");

          widget.onNinetyPercentWatched();
        }
      });
      print("VIDEO READY");
      print(controller!.value.aspectRatio);
      print(controller!.value.duration);

      await controller!.play();

      if (!mounted) return;

      setState(() {
        isReady = true;
      });
    } catch (e) {
      debugPrint("VIDEO ERROR => $e");

      if (mounted) {
        setState(() {
          error = e.toString();
        });
      }
    }
  }

  @override
  void dispose() {
    print("VIDEO SCREEN DISPOSE");

    controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (error != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(error!, style: TextStyle(color: Colors.red)),
        ),
      );
    }

    print("VIDEO BUILD");
    print("IS READY => $isReady");
    if (!isReady) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        SizedBox(
          height: 250,
          width: double.infinity,
          child: AspectRatio(
            aspectRatio: controller!.value.aspectRatio,
            child: VideoPlayer(controller!),
          ),
        ),
        IconButton(
          icon: Icon(
            controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
          ),
          onPressed: () {
            setState(() {
              if (controller!.value.isPlaying) {
                controller!.pause();
              } else {
                controller!.play();
              }
            });
          },
        ),
      ],
    );
  }
}
