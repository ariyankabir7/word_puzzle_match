import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_images.dart';
import '../../core/router/app_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _loadingProgress = 0.0;
  String _statusText = 'Loading adventure...';
  bool _startedLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_startedLoading) {
        _startedLoading = true;
        _initAndPreload();
      }
    });
  }

  Future<void> _initAndPreload() async {
    final startTime = DateTime.now();

    final imagePaths = [
      AppImages.bgHome,
      AppImages.bgMap,
      AppImages.bgGameplay,
      AppImages.bgVictory,
      AppImages.logoTitle,
      AppImages.iconChest,
      AppImages.iconCoin,
      AppImages.iconGem,
      AppImages.iconStar,
      AppImages.gear,
      AppImages.wordsGridBg,
      AppImages.coinsBalanceBg,
      AppImages.levelComplete,
    ];

    int loaded = 0;
    for (final path in imagePaths) {
      if (!mounted) return;
      try {
        await precacheImage(AssetImage(path), context);
      } catch (_) {
        // Ignore precache errors for missing/optional assets
      }
      loaded++;
      if (mounted) {
        setState(() {
          _loadingProgress = loaded / imagePaths.length;
          if (_loadingProgress < 0.4) {
            _statusText = 'Loading graphics...';
          } else if (_loadingProgress < 0.8) {
            _statusText = 'Preparing word puzzles...';
          } else {
            _statusText = 'Ready to play!';
          }
        });
      }
    }

    // Ensure minimum splash duration for smooth visual experience
    final elapsedMs = DateTime.now().difference(startTime).inMilliseconds;
    final remainingMs = AppConstants.splashDurationMs - elapsedMs;
    if (remainingMs > 0) {
      await Future.delayed(Duration(milliseconds: remainingMs));
    }

    if (mounted) {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image matching Home Screen
          Positioned.fill(
            child: Image.asset(
              AppImages.bgHome,
              fit: BoxFit.cover,
            ),
          ),

          // Subtle Darkening Overlay for contrast
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.15),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.35),
                  ],
                ),
              ),
            ),
          ),

          // Floating Animated Decorative Clouds
          ..._buildClouds(),

          // Floating Sparkling Stars
          ..._buildSparkles(),

          // Main Center Content
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),

                // 3D Title Logo (Includes built-in tagline ribbon)
                Image.asset(
                      AppImages.logoTitle,
                      width: 420,
                      height: 240,
                      fit: BoxFit.contain,
                    )
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .scale(
                      begin: const Offset(0.8, 0.8),
                      duration: 700.ms,
                      curve: Curves.elasticOut,
                    )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .moveY(
                      begin: -6,
                      end: 6,
                      duration: 2.seconds,
                      curve: Curves.easeInOut,
                    ),

                const Spacer(flex: 3),


                // Loading Status Text
                Text(
                  _statusText,
                  style: GoogleFonts.fredoka(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    shadows: const [
                      Shadow(
                        color: Color(0x66000000),
                        offset: Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 400.ms, duration: 300.ms),

                const SizedBox(height: 10),

                // 3D Game Loading Progress Bar
                Container(
                  width: 250,
                  height: 22,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: const Color(0xBB000000),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.9),
                      width: 2,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x44000000),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Stack(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                            width: constraints.maxWidth * _loadingProgress,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ).animate().fadeIn(delay: 500.ms, duration: 400.ms),

                const SizedBox(height: 6),

                // Percentage Text
                Text(
                  '${(_loadingProgress * 100).toInt()}%',
                  style: GoogleFonts.fredoka(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withValues(alpha: 0.9),
                    shadows: const [
                      Shadow(
                        color: Color(0x55000000),
                        offset: Offset(0, 1),
                        blurRadius: 3,
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 1),

                // Version string
                Text(
                  'v1.0.0',
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildClouds() {
    return [
      Positioned(
        left: -30,
        top: 50,
        child: Opacity(
          opacity: 0.4,
          child: Container(
            width: 140,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
      )
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .moveX(begin: 0, end: 20, duration: 4.seconds, curve: Curves.easeInOut),
      Positioned(
        right: -20,
        top: 130,
        child: Opacity(
          opacity: 0.35,
          child: Container(
            width: 110,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
            ),
          ),
        ),
      )
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .moveX(begin: 0, end: -15, duration: 5.seconds, curve: Curves.easeInOut),
    ];
  }

  List<Widget> _buildSparkles() {
    return [
      Positioned(
        top: 140,
        left: 40,
        child: Icon(
          Icons.star_rounded,
          color: const Color(0xFFFFD700).withValues(alpha: 0.8),
          size: 24,
        ),
      )
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scale(begin: const Offset(0.7, 0.7), end: const Offset(1.2, 1.2), duration: 1500.ms),
      Positioned(
        top: 180,
        right: 45,
        child: Icon(
          Icons.auto_awesome,
          color: const Color(0xFFFFEA00).withValues(alpha: 0.9),
          size: 28,
        ),
      )
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scale(begin: const Offset(1.1, 1.1), end: const Offset(0.7, 0.7), duration: 1800.ms),
    ];
  }
}

