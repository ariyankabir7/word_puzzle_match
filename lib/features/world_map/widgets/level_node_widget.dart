import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_images.dart';

enum NodeState { locked, unlocked, oneStar, twoStar, threeStar, current }

class LevelNodeWidget extends StatelessWidget {
  final int levelNumber;
  final NodeState state;
  final VoidCallback? onTap;

  const LevelNodeWidget({
    super.key,
    required this.levelNumber,
    required this.state,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isCurrent = state == NodeState.current;
    final isLocked = state == NodeState.locked;
    final double size = isCurrent ? 64 : 54;

    Color topColor;
    Color bottomColor;
    Color shadowColor;
    Color textColor = Colors.white;

    switch (state) {
      case NodeState.locked:
        topColor = const Color(0xFFB0BEC5);
        bottomColor = const Color(0xFF78909C);
        shadowColor = const Color(0xFF455A64);
        textColor = const Color(0xFFECEFF1);
        break;
      case NodeState.unlocked:
      case NodeState.oneStar:
      case NodeState.twoStar:
      case NodeState.threeStar:
        topColor = const Color(0xFF8CE62C);
        bottomColor = const Color(0xFF58B610);
        shadowColor = const Color(0xFF387A06);
        break;
      case NodeState.current:
        topColor = const Color(0xFF29B6F6);
        bottomColor = const Color(0xFF0288D1);
        shadowColor = const Color(0xFF01579B);
        break;
    }

    Widget node = GestureDetector(
      onTap: isLocked ? null : onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: shadowColor,
                  offset: const Offset(0, 4),
                  blurRadius: 0,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  offset: const Offset(0, 5),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [topColor, bottomColor],
                ),
                border: Border.all(
                  color: Colors.white,
                  width: isCurrent ? 3.5 : 2.5,
                ),
              ),
              child: Center(
                child: isLocked
                    ? const Icon(Icons.lock_rounded, color: Colors.white, size: 22)
                    : Text(
                        levelNumber.toString(),
                        style: GoogleFonts.fredoka(
                          fontSize: isCurrent ? 22 : 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                          shadows: const [
                            Shadow(
                              color: Colors.black38,
                              offset: Offset(0, 2),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ),
          if (_stars() > 0) ...[
            const SizedBox(height: 2),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                3,
                (index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1),
                  child: Image.asset(
                    AppImages.iconStar,
                    width: 14,
                    height: 14,
                    color: index < _stars() ? null : Colors.black38,
                    colorBlendMode: index < _stars() ? null : BlendMode.srcATop,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );

    if (isCurrent) {
      node = node
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scale(
            begin: const Offset(1, 1),
            end: const Offset(1.1, 1.1),
            duration: 700.ms,
            curve: Curves.easeInOut,
          );
    }

    return node;
  }

  int _stars() {
    switch (state) {
      case NodeState.oneStar:
        return 1;
      case NodeState.twoStar:
        return 2;
      case NodeState.threeStar:
        return 3;
      default:
        return 0;
    }
  }
}
