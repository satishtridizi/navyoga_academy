import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show TickerCanceled;
import 'package:navyoga_academy/routes/app_routes.dart';
import 'package:navyoga_academy/utils/auth_manager.dart';
import 'package:video_player/video_player.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, this.isLoggedIn});

  final bool? isLoggedIn;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final VideoPlayerController _audioController;
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  static const _splashDuration = Duration(seconds: 3);

  @override
  void initState() {
    super.initState();
    _audioController = VideoPlayerController.asset(
      'assets/audio/splash.mp3',
    );
    _fadeController = AnimationController(
      vsync: this,
      duration: _splashDuration,
    );
    _fadeAnimation = TweenSequence<double>(
       [
        TweenSequenceItem(
          tween: Tween<double>(begin: 0, end: 1)
              .chain(CurveTween(curve: Curves.easeOutCubic)),
          weight: 15,
        ),
        TweenSequenceItem(tween: ConstantTween<double>(1), weight: 70),
        TweenSequenceItem(
          tween: Tween<double>(begin: 1, end: 0)
              .chain(CurveTween(curve: Curves.easeInCubic)),
          weight: 15,
        ),
      ],
    ).animate(_fadeController);
    unawaited(_runSplash());
  }

  Future<void> _runSplash() async {
    unawaited(_initializeAudio());
    final loginCheck = widget.isLoggedIn == null ? _checkLogin() : null;

    try {
      await _fadeController.forward().orCancel;
    } on TickerCanceled {
      return;
    }
    final loggedIn = widget.isLoggedIn ?? await loginCheck!;

    if (!mounted) return;
    Navigator.pushReplacementNamed(
      context,
      loggedIn ? AppRoutes.dashboard : AppRoutes.login,
    );
  }

  Future<void> _initializeAudio() async {
    try {
      await _audioController.initialize();
      await _audioController.setVolume(0.55);
      await _audioController.play();
    } catch (error) {
      debugPrint('Unable to play splash audio: $error');
    }
  }

  Future<bool> _checkLogin() async {
    final token = await AuthManager.getToken();
    return token != null && token.trim().isNotEmpty;
  }

  @override
  void dispose() {
    _fadeController.dispose();
    unawaited(_audioController.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox.expand(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Image.asset(
            'assets/images/navyoga_splash.jpeg',
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
        ),
      ),
    );
  }
}
