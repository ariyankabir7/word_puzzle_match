import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';

class StarRatingWidget extends StatelessWidget {
  final int stars; // 0–3
  final double starSize;
  final bool animate;

  const StarRatingWidget({
    super.key,
    required this.stars,
    this.starSize = 40,
    this.animate = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        final isActive = index < stars;
        Widget star = Icon(
          Icons.star_rounded,
          size: starSize,
          color: isActive ? AppColors.starActive : AppColors.starInactive,
          shadows: isActive
              ? [
                  Shadow(
                    color: AppColors.sunshineYellow.withValues(alpha: 0.5),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        );

        if (animate && isActive) {
          star = star
              .animate(delay: Duration(milliseconds: 300 + index * 200))
              .scale(
                begin: const Offset(0, 0),
                end: const Offset(1, 1),
                duration: 400.ms,
                curve: Curves.elasticOut,
              );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: star,
        );
      }),
    );
  }
}
