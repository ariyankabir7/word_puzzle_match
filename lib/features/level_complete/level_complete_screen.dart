import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/providers/app_providers.dart';
import '../../core/router/app_router.dart';
import '../../shared/widgets/owl_mascot.dart';
import '../../shared/widgets/star_rating_widget.dart';

class LevelCompleteScreen extends ConsumerStatefulWidget {
  final int levelId;
  final int starsEarned;
  final int coinsEarned;
  final int gemsEarned;

  const LevelCompleteScreen({
    super.key,
    required this.levelId,
    required this.starsEarned,
    required this.coinsEarned,
    required this.gemsEarned,
  });

  @override
  ConsumerState<LevelCompleteScreen> createState() => _LevelCompleteScreenState();
}

class _LevelCompleteScreenState extends ConsumerState<LevelCompleteScreen> {
  bool _adRewardClaimed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(playerProgressProvider.notifier).recordLevelComplete(
        levelId: widget.levelId,
        stars: widget.starsEarned,
        coinsEarned: widget.coinsEarned,
        gemsEarned: widget.gemsEarned,
      );
    });
  }

  String get _celebrationText {
    switch (widget.starsEarned) {
      case 3: return 'Wonderful!';
      case 2: return 'Great Job!';
      default: return 'Well Done!';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF7B52CF), Color(0xFF5A3AAA)],
          ),
        ),
        child: Stack(
          children: [
            ..._buildConfetti(),

            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  _buildBanner(),

                  const SizedBox(height: 24),

                  StarRatingWidget(
                    stars: widget.starsEarned,
                    starSize: 60,
                    animate: true,
                  ),

                  const SizedBox(height: 16),

                  Text(
                    _celebrationText,
                    style: AppTextStyles.headingXL.copyWith(color: Colors.white),
                  )
                      .animate()
                      .fadeIn(delay: 800.ms, duration: 400.ms)
                      .slideY(begin: 0.3, end: 0),

                  const SizedBox(height: 24),

                  _buildRewards(),

                  const SizedBox(height: 20),

                  const OwlMascot(size: 140, mood: OwlMood.celebrate)
                      .animate()
                      .fadeIn(delay: 400.ms, duration: 500.ms)
                      .scale(
                        begin: const Offset(0.6, 0.6),
                        duration: 700.ms,
                        curve: Curves.elasticOut,
                      ),

                  const Spacer(),

                  _buildWatchAdButton(context),

                  const SizedBox(height: 12),

                  _buildNextLevelButton(context),

                  const SizedBox(height: 12),

                  _buildBackToMapButton(context),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B9D), Color(0xFFFF9F1C)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        'Level Complete!',
        style: AppTextStyles.levelComplete,
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .scale(
          begin: const Offset(0.7, 0.7),
          duration: 600.ms,
          curve: Curves.elasticOut,
        );
  }

  Widget _buildRewards() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _RewardChip(
          icon: '🪙',
          value: '+${_adRewardClaimed ? widget.coinsEarned * 2 : widget.coinsEarned}',
          delay: 900,
        ),
        const SizedBox(width: 20),
        if (widget.gemsEarned > 0)
          _RewardChip(
            icon: '💎',
            value: '+${widget.gemsEarned}',
            delay: 1100,
          ),
      ],
    );
  }

  Widget _buildWatchAdButton(BuildContext context) {
    if (_adRewardClaimed) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.lushGreen.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          '🎉 Double Reward Claimed!',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        final adsService = ref.read(adsServiceProvider);
        adsService.showRewardedAd(
          onRewardEarned: () {
            ref.read(playerProgressProvider.notifier).addCoins(widget.coinsEarned);
            setState(() => _adRewardClaimed = true);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('🎉 Double Reward! Claimed +${widget.coinsEarned} extra coins!'),
                backgroundColor: AppColors.lushGreen,
              ),
            );
          },
          onFailed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Ad unavailable, try again.')),
            );
          },
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 32),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              'Watch Ad for 2× Coins (+${widget.coinsEarned} 🪙)',
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 1200.ms);
  }

  Widget _buildNextLevelButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: GestureDetector(
        onTap: () {
          context.pushReplacement(
            '${AppRoutes.gameplay}?level=${widget.levelId + 1}',
          );
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF7FDB8A), Color(0xFF5BBF68)],
            ),
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: const Color(0xFF3FA44E), width: 3),
            boxShadow: const [
              BoxShadow(
                color: Color(0xFF3FA44E),
                offset: Offset(0, 5),
                blurRadius: 0,
              ),
            ],
          ),
          child: Text(
            'Next Level',
            textAlign: TextAlign.center,
            style: AppTextStyles.playButton.copyWith(fontSize: 22),
          ),
        ),
      ),
    ).animate().fadeIn(delay: 1000.ms).slideY(begin: 0.3, end: 0);
  }

  Widget _buildBackToMapButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: GestureDetector(
        onTap: () => context.go(AppRoutes.worldMap),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF5CB8E4), Color(0xFF3A9EC9)],
            ),
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: const Color(0xFF2A7EA8), width: 2),
            boxShadow: const [
              BoxShadow(
                color: Color(0xFF2A7EA8),
                offset: Offset(0, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.home_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(
                'Back to Map',
                style: AppTextStyles.bodyLarge.copyWith(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: 1100.ms).slideY(begin: 0.3, end: 0);
  }

  List<Widget> _buildConfetti() {
    const colors = [
      Color(0xFFFF6B9D),
      Color(0xFFF9C74F),
      Color(0xFF6BCB77),
      Color(0xFF5CB8E4),
      Color(0xFF9B72CF),
      Color(0xFFFF9F1C),
    ];

    return List.generate(30, (i) {
      final color = colors[i % colors.length];
      final left = (i * 37 % 360).toDouble();
      final delay = (i * 80).toInt();

      return Positioned(
        left: left,
        top: -20,
        child: Container(
          width: 8 + (i % 3) * 4.0,
          height: 8 + (i % 3) * 4.0,
          decoration: BoxDecoration(
            color: color,
            shape: i % 2 == 0 ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: i % 2 == 0 ? null : BorderRadius.circular(2),
          ),
        )
            .animate(delay: Duration(milliseconds: delay))
            .moveY(
              begin: 0,
              end: 900,
              duration: Duration(milliseconds: 2000 + (i % 5) * 300),
              curve: Curves.easeIn,
            )
            .rotate(begin: 0, end: 2)
            .fadeOut(delay: Duration(milliseconds: 1500 + delay)),
      );
    });
  }
}

class _RewardChip extends StatelessWidget {
  final String icon;
  final String value;
  final int delay;

  const _RewardChip({required this.icon, required this.value, required this.delay});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 6),
          Text(value, style: AppTextStyles.rewardLabel),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: delay), duration: 400.ms)
        .scale(
          begin: const Offset(0.6, 0.6),
          duration: 500.ms,
          curve: Curves.elasticOut,
        );
  }
}
