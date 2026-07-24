import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// CustomPainter that draws the winding path between level nodes.
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

    // Draw locked path (gray)
    final lockedPaint = Paint()
      ..color = AppColors.nodeLocked.withValues(alpha: 0.4)
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Draw unlocked path
    final unlockedPaint = Paint()
      ..color = pathColor ?? AppColors.sunshineYellow
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Dashes for path
    final dashPaint = Paint()
      ..color = pathDashColor ?? Colors.white70
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Build full path
    final fullPath = _buildPath();

    // Draw gray base path
    canvas.drawPath(fullPath, lockedPaint);

    // Draw unlocked portion (first N segments)
    if (unlockedUpTo > 0) {
      final unlockedPath = _buildPath(maxIndex: unlockedUpTo.clamp(0, nodePositions.length - 1));
      canvas.drawPath(unlockedPath, unlockedPaint);

      // Dashes on unlocked path
      _drawDashedPath(canvas, unlockedPath, dashPaint);
    }
  }

  Path _buildPath({int? maxIndex}) {
    final max = maxIndex ?? nodePositions.length - 1;
    final path = Path();
    path.moveTo(nodePositions[0].dx, nodePositions[0].dy);
    for (int i = 1; i <= max; i++) {
      final prev = nodePositions[i - 1];
      final curr = nodePositions[i];
      final cx = (prev.dx + curr.dx) / 2;
      path.quadraticBezierTo(cx, prev.dy, curr.dx, curr.dy);
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
        dist += 16;
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
