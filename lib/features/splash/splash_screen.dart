import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../core/router/app_router.dart';
import '../../shared/widgets/owl_mascot.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(
      Duration(milliseconds: AppConstants.splashDurationMs),
      () {
        if (mounted) context.go(AppRoutes.home);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF87CEEB),
              Color(0xFF5CB8E4),
              Color(0xFF3A9EC9),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              ..._buildClouds(),

              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLogo()
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 200.ms)
                        .scale(
                          begin: const Offset(0.7, 0.7),
                          duration: 600.ms,
                          curve: Curves.elasticOut,
                        ),

                    const SizedBox(height: 16),

                    Text(
                      'Fun Words, Big Smiles!',
                      style: AppTextStyles.tagline,
                    )
                        .animate()
                        .fadeIn(delay: 500.ms, duration: 400.ms)
                        .slideY(begin: 0.3, end: 0),

                    const SizedBox(height: 40),

                    const OwlMascot(size: 140, mood: OwlMood.happy)
                        .animate()
                        .fadeIn(delay: 300.ms, duration: 500.ms)
                        .scale(
                          begin: const Offset(0.5, 0.5),
                          duration: 700.ms,
                          curve: Curves.elasticOut,
                        ),

                    const SizedBox(height: 40),

                    SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        color: Colors.white.withValues(alpha: 0.7),
                        strokeWidth: 3,
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 800.ms, duration: 400.ms),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Word\n',
                style: AppTextStyles.logoTitle.copyWith(
                  fontSize: 52,
                  color: AppColors.sunshineYellow,
                  fontWeight: FontWeight.w900,
                ),
              ),
              TextSpan(
                text: 'Puzzle\n',
                style: AppTextStyles.logoTitle.copyWith(
                  fontSize: 48,
                  color: Colors.white,
                ),
              ),
              TextSpan(
                text: 'Match',
                style: AppTextStyles.logoTitle.copyWith(
                  fontSize: 48,
                  color: AppColors.lushGreen,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildClouds() {
    return [
      const _Cloud(left: -20, top: 60, scale: 1.2)
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .moveX(begin: 0, end: 15, duration: 4000.ms, curve: Curves.easeInOut),
      const _Cloud(right: -10, top: 120, scale: 0.8)
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .moveX(begin: 0, end: -10, duration: 5000.ms, curve: Curves.easeInOut),
      const _Cloud(left: 40, bottom: 180, scale: 0.7)
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .moveX(begin: 0, end: 12, duration: 6000.ms, curve: Curves.easeInOut),
    ];
  }
}

class _Cloud extends StatelessWidget {
  final double? left, right, top, bottom;
  final double scale;

  const _Cloud({this.left, this.right, this.top, this.bottom, this.scale = 1});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
      child: Transform.scale(
        scale: scale,
        child: const CustomPaint(
          size: Size(130, 60),
          painter: _CloudPainter(),
        ),
      ),
    );
  }
}

class _CloudPainter extends CustomPainter {
  const _CloudPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.55);
    canvas.drawCircle(Offset(size.width * 0.3, size.height * 0.6), size.height * 0.42, paint);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.45), size.height * 0.52, paint);
    canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.6), size.height * 0.38, paint);
    canvas.drawRect(
      Rect.fromLTRB(size.width * 0.1, size.height * 0.6, size.width * 0.9, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}
