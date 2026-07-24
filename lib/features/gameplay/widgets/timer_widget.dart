import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_images.dart';
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

    final textColor = isFrozen
        ? const Color(0xFF00E5FF)
        : (isWarning ? AppColors.timerWarning : Colors.white);

    return Container(
      width: 104,
      height: 44,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(AppImages.timerBg),
          fit: BoxFit.fill,
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(left: 32, right: 6),
          child: Text(
            '$minutes:$seconds',
            style: GoogleFonts.fredoka(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
              shadows: const [
                Shadow(color: Colors.black45, blurRadius: 2, offset: Offset(0, 1)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

