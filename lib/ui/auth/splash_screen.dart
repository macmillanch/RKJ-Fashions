import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/foundation.dart';
import '../../main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      // On web, show logo for a short duration instead of video
      Future.delayed(const Duration(seconds: 2), () {
        _navigateToHome();
      });
      return;
    }
    _controller = VideoPlayerController.asset('assets/videos/splash.mp4')
      ..initialize()
          .then((_) {
            setState(() {
              _initialized = true;
            });
            _controller.play();
          })
          .catchError((e) {
            debugPrint('Video error: $e');
            _navigateToHome();
          });

    _controller.addListener(_checkVideo);
  }

  void _checkVideo() {
    if (_controller.value.isInitialized &&
        _controller.value.position >= _controller.value.duration) {
      _controller.removeListener(_checkVideo);
      _navigateToHome();
    }
  }

  void _navigateToHome() {
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const AuthWrapper(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  @override
  void dispose() {
    if (!kIsWeb) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: kIsWeb || !_initialized
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/logo.png', width: 200),
                  const SizedBox(height: 20),
                  const CircularProgressIndicator(
                    color: Color(0xFFD912BB), // Primary color
                  ),
                ],
              )
            : AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
      ),
    );
  }
}
