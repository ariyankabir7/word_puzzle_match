import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/achievement_model.dart';
import '../../core/providers/app_providers.dart';
import '../../core/router/app_router.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AchievementsScreen(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(playerProgressProvider);
    final notifier = ref.read(playerProgressProvider.notifier);

    final claimedCount = progress.claimedAchievements.length;
    final totalCount = Achievement.allAchievements.length;
    final overallProgress = totalCount > 0 ? (claimedCount / totalCount) : 0.0;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 20,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Drag Handle
          const SizedBox(height: 12),
          Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 14),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.sunshineYellow.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Text('🏆', style: TextStyle(fontSize: 20)),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Achievements',
                      style: GoogleFonts.fredoka(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.sunshineYellow.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.sunshineYellow.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Text(
                    '$claimedCount/$totalCount Unlocked',
                    style: GoogleFonts.fredoka(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: Colors.grey.shade200),

          // List of achievements & Cards
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                // Overall Progress Banner
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Text('⭐', style: TextStyle(fontSize: 16)),
                              const SizedBox(width: 6),
                              Text(
                                'TOTAL PROGRESS',
                                style: GoogleFonts.fredoka(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${(overallProgress * 100).toInt()}% COMPLETED',
                            style: GoogleFonts.fredoka(
                              color: const Color(0xFFF9C74F),
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Stack(
                          children: [
                            Container(
                              height: 10,
                              color: Colors.white12,
                            ),
                            FractionallySizedBox(
                              widthFactor: overallProgress,
                              child: Container(
                                height: 10,
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Color(0xFFF9C74F), Color(0xFF6BCB77)],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 30.ms).slideY(begin: 0.1, end: 0),

                const SizedBox(height: 14),

                // Cash Reward Claim Card
                InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                    context.push(AppRoutes.reward);
                  },
                  borderRadius: BorderRadius.circular(22),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF059669), Color(0xFF10B981)],
                      ),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF10B981).withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            color: Colors.white24,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.card_giftcard_rounded,
                              color: Colors.amberAccent,
                              size: 26,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Cash Reward Withdrawal',
                                    style: GoogleFonts.fredoka(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Claim via UPI ID or Google Play Voucher',
                                style: GoogleFonts.nunito(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 60.ms).slideY(begin: 0.1, end: 0),

                const SizedBox(height: 16),

                // Section Header
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 18,
                      decoration: BoxDecoration(
                        color: AppColors.sunshineYellow,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'ALL ACHIEVEMENTS',
                      style: GoogleFonts.fredoka(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark.withValues(alpha: 0.8),
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                ...List.generate(Achievement.allAchievements.length, (index) {
                  final achievement = Achievement.allAchievements[index];
                  final isClaimed = progress.claimedAchievements.contains(
                    achievement.id,
                  );
                  final currentProgress =
                      (progress.achievementProgress[achievement.id] ?? 0).clamp(
                        0,
                        achievement.targetValue,
                      );
                  final isCompleted =
                      currentProgress >= achievement.targetValue;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isClaimed
                          ? const Color(0xFFF8FAFC)
                          : isCompleted
                          ? const Color(0xFFECFDF5)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: isCompleted && !isClaimed
                            ? const Color(0xFF10B981)
                            : isClaimed
                            ? Colors.grey.shade200
                            : Colors.grey.shade200,
                        width: isCompleted && !isClaimed ? 2 : 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isCompleted && !isClaimed
                              ? const Color(0x2210B981)
                              : Colors.black.withValues(alpha: 0.04),
                          blurRadius: isCompleted && !isClaimed ? 8 : 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Emoji Avatar
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: isClaimed
                                ? Colors.grey.shade100
                                : isCompleted
                                ? const Color(0xFFD1FAE5)
                                : const Color(0xFFF1F5F9),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isCompleted && !isClaimed
                                  ? const Color(0xFF34D399)
                                  : Colors.white,
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              achievement.iconEmoji,
                              style: TextStyle(
                                fontSize: 24,
                                color: isClaimed ? Colors.grey : null,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Title & Progress Bar
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                achievement.title,
                                style: GoogleFonts.fredoka(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                achievement.description,
                                style: GoogleFonts.nunito(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textMedium,
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Dynamic Progress Bar
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Stack(
                                  children: [
                                    Container(
                                      height: 7,
                                      color: Colors.grey.shade200,
                                    ),
                                    FractionallySizedBox(
                                      widthFactor: (currentProgress / achievement.targetValue).clamp(0.0, 1.0),
                                      child: Container(
                                        height: 7,
                                        decoration: BoxDecoration(
                                          gradient: isCompleted
                                              ? const LinearGradient(
                                                  colors: [Color(0xFF34D399), Color(0xFF10B981)],
                                                )
                                              : const LinearGradient(
                                                  colors: [Color(0xFF38BDF8), Color(0xFF0284C7)],
                                                ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$currentProgress / ${achievement.targetValue}',
                                style: GoogleFonts.fredoka(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isCompleted
                                      ? const Color(0xFF059669)
                                      : Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Claim Button / Status Pill
                        if (isClaimed)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.check_circle_rounded, size: 14, color: Color(0xFF10B981)),
                                const SizedBox(width: 4),
                                Text(
                                  'CLAIMED',
                                  style: GoogleFonts.fredoka(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          _ThreeDClaimButton(
                            text: '+${achievement.rewardAmount} ${achievement.rewardType == AchievementRewardType.coins ? "🪙" : "💎"}',
                            isEnabled: isCompleted,
                            onPressed: () {
                              final success = notifier.claimAchievement(achievement);
                              if (success) {
                                HapticFeedback.mediumImpact();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        const Text('🎉', style: TextStyle(fontSize: 18)),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Claimed +${achievement.rewardAmount} ${achievement.rewardType.name}!',
                                          style: GoogleFonts.fredoka(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                    backgroundColor: const Color(0xFF10B981),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            },
                          ),
                      ],
                    ),
                  ).animate().fadeIn(delay: Duration(milliseconds: 80 + index * 40));
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ThreeDClaimButton extends StatefulWidget {
  final String text;
  final bool isEnabled;
  final VoidCallback onPressed;

  const _ThreeDClaimButton({
    required this.text,
    required this.isEnabled,
    required this.onPressed,
  });

  @override
  State<_ThreeDClaimButton> createState() => _ThreeDClaimButtonState();
}

class _ThreeDClaimButtonState extends State<_ThreeDClaimButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    if (!widget.isEnabled) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          widget.text,
          style: GoogleFonts.fredoka(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: Colors.grey.shade500,
          ),
        ),
      );
    }

    final topMargin = _isPressed ? 3.0 : 0.0;
    final shadowHeight = _isPressed ? 1.0 : 4.0;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 60),
        margin: EdgeInsets.only(top: topMargin),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Shadow layer
            Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF047857),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Opacity(
                opacity: 0,
                child: Text(
                  widget.text,
                  style: GoogleFonts.fredoka(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ),
            // Top layer
            Container(
              margin: EdgeInsets.only(bottom: shadowHeight),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF34D399), Color(0xFF10B981)],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1.5),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x3310B981),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                widget.text,
                style: GoogleFonts.fredoka(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.white,
                  shadows: const [
                    Shadow(color: Colors.black26, offset: Offset(0, 1), blurRadius: 2),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
