import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../gameplay_provider.dart';

class TimerWidget extends StatelessWidget {
  final int timeRemaining;
  final GameStatus status;

  const TimerWidget({
    super.key,
    required this.timeRemaining,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final isWarning = timeRemaining < 30;
    final isFrozen = status == GameStatus.frozen;
    final minutes = (timeRemaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (timeRemaining % 60).toString().padLeft(2, '0');

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isFrozen ? Icons.ac_unit_rounded : Icons.timer_rounded,
          size: 18,
          color: isFrozen
              ? AppColors.skyBlue
              : (isWarning ? AppColors.timerWarning : AppColors.timerNormal),
        ),
        const SizedBox(width: 4),
        Text(
          '$minutes:$seconds',
          style: (isWarning && !isFrozen)
              ? AppTextStyles.timerWarning
              : AppTextStyles.timerNormal.copyWith(
                  color: isFrozen ? AppColors.skyBlue : null,
                ),
        ),
      ],
    );
  }
}
