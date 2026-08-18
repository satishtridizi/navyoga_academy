import 'dart:async';

import 'package:flutter/material.dart';
import 'package:navyoga_academy/routes/app_routes.dart';
import 'package:navyoga_academy/utils/auth_manager.dart';
import 'package:video_player/video_player.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, this.isLoggedIn});

  final bool? isLoggedIn;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late final VideoPlayerController _audioController;
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    _audioController = VideoPlayerController.asset(
      'assets/audio/om_chant.wav',
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _visible = true);
    });
    unawaited(_runSplash());
  }

  Future<void> _runSplash() async {
    unawaited(_playChant());
    await Future<void>.delayed(const Duration(milliseconds: 2800));
    final loggedIn = widget.isLoggedIn ?? await _checkLogin();

    if (!mounted) return;
    Navigator.pushReplacementNamed(
      context,
      loggedIn ? AppRoutes.dashboard : AppRoutes.login,
    );
  }

  Future<void> _playChant() async {
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
    unawaited(_audioController.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedOpacity(
        opacity: _visible ? 1 : 0,
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeOut,
        child: SizedBox.expand(
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
