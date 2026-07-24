import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

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
    final double size = isCurrent ? 62 : 54;

    Widget node = GestureDetector(
      onTap: isLocked ? null : onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _backgroundColor(),
          border: Border.all(
            color: _borderColor(),
            width: isCurrent ? 3.5 : 2.5,
          ),
          boxShadow: [
            BoxShadow(
              color: _shadowColor(),
              offset: const Offset(0, 4),
              blurRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              offset: const Offset(0, 5),
              blurRadius: 8,
            ),
          ],
        ),
        child: _buildContent(size),
      ),
    );

    if (isCurrent) {
      node = node
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scale(
            begin: const Offset(1, 1),
            end: const Offset(1.08, 1.08),
            duration: 800.ms,
            curve: Curves.easeInOut,
          );
    }

    return node;
  }

  Widget _buildContent(double size) {
    if (state == NodeState.locked) {
      return const Icon(Icons.lock_rounded, color: Colors.white70, size: 22);
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          levelNumber.toString(),
          style: AppTextStyles.levelLabel.copyWith(
            color: _textColor(),
            fontSize: state == NodeState.current ? 16 : 14,
          ),
        ),
        if (_stars() > 0) ...[
          const SizedBox(height: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _stars(),
              (_) => const Icon(Icons.star_rounded, size: 10, color: AppColors.sunshineYellowDark),
            ),
          ),
        ],
      ],
    );
  }

  Color _backgroundColor() {
    switch (state) {
      case NodeState.locked:
        return AppColors.nodeLocked;
      case NodeState.unlocked:
        return Colors.white;
      case NodeState.oneStar:
      case NodeState.twoStar:
        return AppColors.sunshineYellow;
      case NodeState.threeStar:
        return const Color(0xFFFFD700);
      case NodeState.current:
        return AppColors.skyBlue;
    }
  }

  Color _borderColor() {
    switch (state) {
      case NodeState.locked:
        return const Color(0xFF8FA0AA);
      case NodeState.unlocked:
        return const Color(0xFFCCDDEE);
      case NodeState.oneStar:
      case NodeState.twoStar:
        return AppColors.sunshineYellowDark;
      case NodeState.threeStar:
        return const Color(0xFFE6B800);
      case NodeState.current:
        return Colors.white;
    }
  }

  Color _shadowColor() {
    switch (state) {
      case NodeState.locked:
        return const Color(0xFF8FA0AA);
      case NodeState.unlocked:
        return const Color(0xFFAABBCC);
      case NodeState.oneStar:
      case NodeState.twoStar:
        return AppColors.sunshineYellowDark;
      case NodeState.threeStar:
        return const Color(0xFFCC9900);
      case NodeState.current:
        return AppColors.skyBlueDark;
    }
  }

  Color _textColor() {
    switch (state) {
      case NodeState.locked:
        return Colors.white70;
      case NodeState.unlocked:
      case NodeState.oneStar:
      case NodeState.twoStar:
      case NodeState.threeStar:
        return AppColors.textDark;
      case NodeState.current:
        return Colors.white;
    }
  }

  int _stars() {
    switch (state) {
      case NodeState.oneStar: return 1;
      case NodeState.twoStar: return 2;
      case NodeState.threeStar: return 3;
      default: return 0;
    }
  }
}
