import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class PowerUpBar extends StatelessWidget {
  final int hintsRemaining;
  final int shufflesRemaining;
  final int freezesRemaining;
  final bool isFrozen;
  final VoidCallback onHint;
  final VoidCallback onShuffle;
  final VoidCallback onFreeze;

  const PowerUpBar({
    super.key,
    required this.hintsRemaining,
    required this.shufflesRemaining,
    required this.freezesRemaining,
    required this.isFrozen,
    required this.onHint,
    required this.onShuffle,
    required this.onFreeze,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _PowerUpButton(
          icon: '💡',
          label: 'Hint',
          count: hintsRemaining,
          isDisabled: hintsRemaining <= 0,
          onTap: hintsRemaining > 0 ? onHint : null,
        ),
        _PowerUpButton(
          icon: '🔄',
          label: 'Shuffle',
          count: shufflesRemaining,
          isDisabled: shufflesRemaining <= 0,
          onTap: shufflesRemaining > 0 ? onShuffle : null,
        ),
        _PowerUpButton(
          icon: '❄️',
          label: 'Freeze',
          count: freezesRemaining,
          isDisabled: freezesRemaining <= 0 || isFrozen,
          onTap: (freezesRemaining > 0 && !isFrozen) ? onFreeze : null,
          isActive: isFrozen,
        ),
      ],
    );
  }
}

class _PowerUpButton extends StatelessWidget {
  final String icon;
  final String label;
  final int count;
  final bool isDisabled;
  final bool isActive;
  final VoidCallback? onTap;

  const _PowerUpButton({
    required this.icon,
    required this.label,
    required this.count,
    this.isDisabled = false,
    this.isActive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final opacity = isDisabled ? 0.45 : 1.0;

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: opacity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: isActive
                          ? [AppColors.skyBlue, AppColors.skyBlueDark]
                          : [Colors.white, const Color(0xFFF0F4FF)],
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isActive ? AppColors.skyBlue : const Color(0xFFDDE0EE),
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isActive ? AppColors.skyBlue : AppColors.textLight)
                            .withValues(alpha: 0.3),
                        offset: const Offset(0, 4),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      icon,
                      style: const TextStyle(fontSize: 26),
                    ),
                  ),
                ),
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: AppColors.softPurple,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        'x$count',
                        style: AppTextStyles.powerUpCount.copyWith(fontSize: 10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(fontSize: 12),
            ),
          ],
        ),
      ),
    )
        .animate(target: isActive ? 1 : 0)
        .scale(
          begin: const Offset(1, 1),
          end: const Offset(1.05, 1.05),
          duration: 600.ms,
          curve: Curves.easeInOut,
        );
  }
}
