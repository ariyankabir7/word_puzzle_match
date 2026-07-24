import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

/// Draws a simple cute owl using Canvas — no external animation file needed.
/// The owl has idle bob animation and can be set to "celebrate" mode.
class OwlMascot extends StatefulWidget {
  final double size;
  final OwlMood mood;

  const OwlMascot({
    super.key,
    this.size = 120,
    this.mood = OwlMood.idle,
  });

  @override
  State<OwlMascot> createState() => _OwlMascotState();
}

enum OwlMood { idle, happy, celebrate, surprised }

class _OwlMascotState extends State<OwlMascot>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: CustomPaint(
        painter: _OwlPainter(mood: widget.mood),
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .moveY(
          begin: 0,
          end: widget.mood == OwlMood.celebrate ? -12 : -6,
          duration: widget.mood == OwlMood.celebrate
              ? 400.ms
              : 1200.ms,
          curve: Curves.easeInOut,
        );
  }
}

class _OwlPainter extends CustomPainter {
  final OwlMood mood;
  _OwlPainter({required this.mood});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Body
    final bodyPaint = Paint()..color = const Color(0xFFB5832A);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.62), width: w * 0.68, height: h * 0.65),
      bodyPaint,
    );

    // Belly
    final bellyPaint = Paint()..color = const Color(0xFFF5DEB3);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.66), width: w * 0.38, height: h * 0.42),
      bellyPaint,
    );

    // Head
    final headPaint = Paint()..color = const Color(0xFFB5832A);
    canvas.drawCircle(Offset(w * 0.5, h * 0.32), w * 0.3, headPaint);

    // Graduation cap
    final capPaint = Paint()..color = const Color(0xFF2D3142);
    canvas.drawRect(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.08), width: w * 0.62, height: h * 0.06),
      capPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.1), width: w * 0.44, height: h * 0.08),
      capPaint,
    );
    // Tassel
    final ropePaint2 = Paint()
      ..color = AppColors.sunshineYellow
      ..strokeWidth = 2.0;
    canvas.drawLine(Offset(w * 0.72, h * 0.1), Offset(w * 0.78, h * 0.2), ropePaint2);

    // Eyes
    final eyeWhitePaint = Paint()..color = Colors.white;
    final eyePupilPaint = Paint()..color = const Color(0xFF2D3142);
    final eyeHighlightPaint = Paint()..color = Colors.white;

    // Left eye
    canvas.drawCircle(Offset(w * 0.38, h * 0.3), w * 0.1, eyeWhitePaint);
    canvas.drawCircle(Offset(w * 0.38, h * 0.3), w * 0.06,
        Paint()..color = const Color(0xFFFF6B35));
    canvas.drawCircle(Offset(w * 0.38, h * 0.3), w * 0.04, eyePupilPaint);
    canvas.drawCircle(Offset(w * 0.41, h * 0.28), w * 0.015, eyeHighlightPaint);

    // Right eye
    canvas.drawCircle(Offset(w * 0.62, h * 0.3), w * 0.1, eyeWhitePaint);
    canvas.drawCircle(Offset(w * 0.62, h * 0.3), w * 0.06,
        Paint()..color = const Color(0xFFFF6B35));
    canvas.drawCircle(Offset(w * 0.62, h * 0.3), w * 0.04, eyePupilPaint);
    canvas.drawCircle(Offset(w * 0.65, h * 0.28), w * 0.015, eyeHighlightPaint);

    // Beak
    final beakPaint = Paint()..color = const Color(0xFFF4A035);
    final beakPath = Path()
      ..moveTo(w * 0.44, h * 0.38)
      ..lineTo(w * 0.56, h * 0.38)
      ..lineTo(w * 0.5, h * 0.45)
      ..close();
    canvas.drawPath(beakPath, beakPaint);

    // Smile for happy/celebrate
    if (mood == OwlMood.happy || mood == OwlMood.celebrate) {
      final smilePaint = Paint()
        ..color = const Color(0xFF4A2000)
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      final smilePath = Path()
        ..moveTo(w * 0.44, h * 0.46)
        ..quadraticBezierTo(w * 0.5, h * 0.52, w * 0.56, h * 0.46);
      canvas.drawPath(smilePath, smilePaint);
    }

    // Wings
    final wingPaint = Paint()..color = const Color(0xFF8B5E1A);
    final leftWing = Path()
      ..moveTo(w * 0.16, h * 0.55)
      ..quadraticBezierTo(w * 0.04, h * 0.7, w * 0.14, h * 0.82)
      ..quadraticBezierTo(w * 0.2, h * 0.72, w * 0.28, h * 0.62)
      ..close();
    canvas.drawPath(leftWing, wingPaint);

    final rightWing = Path()
      ..moveTo(w * 0.84, h * 0.55)
      ..quadraticBezierTo(w * 0.96, h * 0.7, w * 0.86, h * 0.82)
      ..quadraticBezierTo(w * 0.8, h * 0.72, w * 0.72, h * 0.62)
      ..close();
    canvas.drawPath(rightWing, wingPaint);

    // Feet
    final feetPaint = Paint()
      ..color = const Color(0xFFF4A035)
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.38, h * 0.9), Offset(w * 0.3, h * 0.97), feetPaint);
    canvas.drawLine(Offset(w * 0.38, h * 0.9), Offset(w * 0.38, h * 0.98), feetPaint);
    canvas.drawLine(Offset(w * 0.38, h * 0.9), Offset(w * 0.46, h * 0.97), feetPaint);
    canvas.drawLine(Offset(w * 0.62, h * 0.9), Offset(w * 0.54, h * 0.97), feetPaint);
    canvas.drawLine(Offset(w * 0.62, h * 0.9), Offset(w * 0.62, h * 0.98), feetPaint);
    canvas.drawLine(Offset(w * 0.62, h * 0.9), Offset(w * 0.7, h * 0.97), feetPaint);

    // Celebrate stars effect
    if (mood == OwlMood.celebrate) {
      final starPaint = Paint()..color = AppColors.sunshineYellow;
      _drawStar(canvas, Offset(w * 0.1, h * 0.2), 8, starPaint);
      _drawStar(canvas, Offset(w * 0.9, h * 0.25), 6, starPaint);
    }
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final angle = (i * 144 - 90) * 3.14159 / 180;
      final x = center.dx + radius * 1.0 * _cos(angle);
      final y = center.dy + radius * 1.0 * _sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  double _cos(double angle) {
    if (angle < 0) return _cosPositive(-angle);
    return _cosPositive(angle);
  }
  double _sin(double angle) {
    const pi = 3.14159265;
    while (angle > 2 * pi) {
      angle -= 2 * pi;
    }
    if (angle < pi) return _sinPositive(angle);
    return -_sinPositive(angle - pi);
  }
  double _cosPositive(double angle) {
    const pi = 3.14159265;
    return _sinPositive(pi / 2 - angle);
  }
  double _sinPositive(double angle) {
    return angle - (angle * angle * angle) / 6 + (angle * angle * angle * angle * angle) / 120;
  }

  @override
  bool shouldRepaint(_OwlPainter old) => old.mood != mood;
}

class CurrencyDisplay extends StatelessWidget {
  final int coins;
  final int gems;

  const CurrencyDisplay({
    super.key,
    required this.coins,
    required this.gems,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _CurrencyChip(
          icon: '🪙',
          value: coins,
        ),
        const SizedBox(width: 8),
        _CurrencyChip(
          icon: '💎',
          value: gems,
        ),
      ],
    );
  }
}

class _CurrencyChip extends StatelessWidget {
  final String icon;
  final int value;

  const _CurrencyChip({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Text(
            value.toString(),
            style: AppTextStyles.coinCount,
          ),
        ],
      ),
    );
  }
}
