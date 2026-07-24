import 'package:flutter/material.dart';

/// CustomPainter that draws the winding path between level nodes with high visual contrast.
class PathPainter extends CustomPainter {
  final List<Offset> nodePositions;
  final int unlockedUpTo; // index of last unlocked node
  final Color? pathColor;
  final Color? pathDashColor;

  const PathPainter({
    required this.nodePositions,
    required this.unlockedUpTo,
    this.pathColor,
    this.pathDashColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (nodePositions.length < 2) return;

    // Outer border for locked path
    final outerLockedPaint = Paint()
      ..color = const Color(0xFF3E2723).withValues(alpha: 0.7)
      ..strokeWidth = 20
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Locked path fill
    final lockedPaint = Paint()
      ..color = const Color(0xFF8D6E63).withValues(alpha: 0.85)
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Outer border for unlocked path
    final outerUnlockedPaint = Paint()
      ..color = const Color(0xFF4E270A)
      ..strokeWidth = 20
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Unlocked path fill (vibrant golden yellow)
    final unlockedPaint = Paint()
      ..color = pathColor ?? const Color(0xFFFFB300)
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Dashes for unlocked path
    final dashPaint = Paint()
      ..color = pathDashColor ?? const Color(0xFFFFFBEA)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Build full path
    final fullPath = _buildPath();

    // Draw base locked path with outer border
    canvas.drawPath(fullPath, outerLockedPaint);
    canvas.drawPath(fullPath, lockedPaint);

    // Draw unlocked portion (first N segments)
    if (unlockedUpTo > 0) {
      final unlockedPath = _buildPath(maxIndex: unlockedUpTo.clamp(0, nodePositions.length - 1));
      canvas.drawPath(unlockedPath, outerUnlockedPaint);
      canvas.drawPath(unlockedPath, unlockedPaint);

      // Dashes on unlocked path
      _drawDashedPath(canvas, unlockedPath, dashPaint);
    }
  }

  Path _buildPath({int? maxIndex}) {
    final max = maxIndex ?? nodePositions.length - 1;
    final path = Path();
    if (nodePositions.isEmpty) return path;

    path.moveTo(nodePositions[0].dx, nodePositions[0].dy);
    for (int i = 1; i <= max; i++) {
      final prev = nodePositions[i - 1];
      final curr = nodePositions[i];
      final midY = (prev.dy + curr.dy) / 2;
      path.cubicTo(prev.dx, midY, curr.dx, midY, curr.dx, curr.dy);
    }
    return path;
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double dist = 0;
      while (dist < metric.length) {
        final segment = metric.extractPath(dist, (dist + 8).clamp(0, metric.length));
        canvas.drawPath(segment, paint);
        dist += 18;
      }
    }
  }

  @override
  bool shouldRepaint(PathPainter old) =>
      old.nodePositions != nodePositions ||
      old.unlockedUpTo != unlockedUpTo ||
      old.pathColor != pathColor ||
      old.pathDashColor != pathDashColor;
}

