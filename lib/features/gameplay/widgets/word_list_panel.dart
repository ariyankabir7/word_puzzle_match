import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WordListPanel extends StatelessWidget {
  final List<String> words;
  final Set<String> foundWords;
  final Map<String, int> wordColorIndices;

  const WordListPanel({
    super.key,
    required this.words,
    required this.foundWords,
    required this.wordColorIndices,
  });

  static const List<Color> _wordColors = [
    Color(0xFF2E7D32), // Green
    Color(0xFFD84315), // Deep Orange
    Color(0xFFC2185B), // Pink
    Color(0xFF1565C0), // Blue
    Color(0xFF6A1B9A), // Purple
    Color(0xFFE65100), // Orange
    Color(0xFF00838F), // Teal
  ];

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: const _CloudRectBorderPainter(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          children: [
            Text(
              'FIND THESE WORDS',
              style: GoogleFonts.fredoka(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF8E24AA),
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 14,
              runSpacing: 6,
              alignment: WrapAlignment.center,
              children: List.generate(words.length, (index) {
                final word = words[index];
                final isFound = foundWords.contains(word);
                final textColor = _wordColors[index % _wordColors.length];

                return Text(
                  word,
                  style: GoogleFonts.fredoka(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isFound ? textColor.withValues(alpha: 0.35) : textColor,
                    decoration: isFound ? TextDecoration.lineThrough : null,
                    decorationThickness: 2,
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _CloudRectBorderPainter extends CustomPainter {
  const _CloudRectBorderPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    if (w <= 0 || h <= 0) return;

    final path = Path();
    const cr = 14.0; // Corner radius
    const r = 4.5;   // Cloud bump radius

    // Top edge
    path.moveTo(cr, 0);
    final topLength = w - 2 * cr;
    final topSteps = (topLength / 18).round().clamp(2, 60);
    final topStepW = topLength / topSteps;
    for (int i = 0; i < topSteps; i++) {
      final x1 = cr + i * topStepW;
      final x2 = cr + (i + 1) * topStepW;
      path.quadraticBezierTo((x1 + x2) / 2, -r, x2, 0);
    }

    // Top-Right Corner
    path.quadraticBezierTo(w + r, -r, w + r * 0.5, cr);

    // Right edge
    final rightLength = h - 2 * cr;
    final rightSteps = (rightLength / 18).round().clamp(2, 60);
    final rightStepH = rightLength / rightSteps;
    for (int i = 0; i < rightSteps; i++) {
      final y1 = cr + i * rightStepH;
      final y2 = cr + (i + 1) * rightStepH;
      path.quadraticBezierTo(w + r, (y1 + y2) / 2, w, y2);
    }

    // Bottom-Right Corner
    path.quadraticBezierTo(w + r, h + r, w - cr, h + r * 0.5);

    // Bottom edge
    final bottomSteps = topSteps;
    final bottomStepW = topStepW;
    for (int i = 0; i < bottomSteps; i++) {
      final x1 = (w - cr) - i * bottomStepW;
      final x2 = (w - cr) - (i + 1) * bottomStepW;
      path.quadraticBezierTo((x1 + x2) / 2, h + r, x2, h);
    }

    // Bottom-Left Corner
    path.quadraticBezierTo(-r, h + r, -r * 0.5, h - cr);

    // Left edge
    final leftSteps = rightSteps;
    final leftStepH = rightStepH;
    for (int i = 0; i < leftSteps; i++) {
      final y1 = (h - cr) - i * leftStepH;
      final y2 = (h - cr) - (i + 1) * leftStepH;
      path.quadraticBezierTo(-r, (y1 + y2) / 2, 0, y2);
    }

    // Top-Left Corner
    path.quadraticBezierTo(-r, -r, cr, 0);
    path.close();

    // Soft Shadow
    final shadowPaint = Paint()
      ..color = const Color(0x22000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawPath(path.shift(const Offset(0, 3)), shadowPaint);

    // Lush Cloud Gradient Fill
    final fillPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFFFFFFF),
          Color(0xFFF4F8FC),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(path, fillPaint);

    // Soft Blue-Gray Border Line
    final borderPaint = Paint()
      ..color = const Color(0xFFD4DFE8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

