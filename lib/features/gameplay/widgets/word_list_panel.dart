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
      painter: const _SvgCloudBgPainter(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        child: Column(
          children: [
            Text(
              'FIND THESE WORDS',
              style: GoogleFonts.fredoka(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF8E24AA),
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 16,
              runSpacing: 6,
              alignment: WrapAlignment.center,
              children: List.generate(words.length, (index) {
                final word = words[index];
                final isFound = foundWords.contains(word);
                final textColor = _wordColors[index % _wordColors.length];

                return Text(
                  word,
                  style: GoogleFonts.fredoka(
                    fontSize: 16,
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

class _SvgCloudBgPainter extends CustomPainter {
  const _SvgCloudBgPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final path = Path();
    
    // Smooth SVG Cloud path contour
    path.moveTo(w * 0.10, h * 0.18);
    path.cubicTo(w * 0.15, -h * 0.10, w * 0.35, -h * 0.12, w * 0.48, h * 0.08);
    path.cubicTo(w * 0.58, -h * 0.12, w * 0.82, -h * 0.08, w * 0.90, h * 0.18);
    path.cubicTo(w * 1.05, h * 0.20, w * 1.06, h * 0.55, w * 0.95, h * 0.74);
    path.cubicTo(w * 1.04, h * 0.94, w * 0.82, h * 1.14, w * 0.72, h * 0.94);
    path.cubicTo(w * 0.52, h * 1.14, w * 0.32, h * 1.14, w * 0.22, h * 0.94);
    path.cubicTo(w * 0.08, h * 1.14, -w * 0.04, h * 0.90, w * 0.04, h * 0.70);
    path.cubicTo(-w * 0.05, h * 0.50, -w * 0.02, h * 0.20, w * 0.10, h * 0.18);
    path.close();

    // Drop Shadow
    final shadowPaint = Paint()
      ..color = const Color(0x22000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawPath(path.shift(const Offset(0, 3)), shadowPaint);

    // White/Cloud Gradient Fill
    final fillPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFFFFFFF),
          Color(0xFFF2F7FA),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(path, fillPaint);

    // Soft Inner Border Line
    final borderPaint = Paint()
      ..color = const Color(0xFFE0E7ED)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

