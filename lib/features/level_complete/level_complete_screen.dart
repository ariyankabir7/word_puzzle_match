import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_images.dart';
import '../../core/providers/app_providers.dart';
import '../../core/router/app_router.dart';
import '../../core/services/api_service.dart';
import '../../core/services/track_my_event_service.dart';
import '../../shared/widgets/game_button.dart';

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

      // Sync level completion with server & track event milestones
      ApiService().logLevelCompletion(widget.levelId, widget.coinsEarned);
      TrackMyEventService().checkAndTrackLevelMilestones(widget.levelId);
    });
  }

  String get _celebrationText {
    switch (widget.starsEarned) {
      case 3:
        return 'Wonderful!';
      case 2:
        return 'Great Job!';
      default:
        return 'Well Done!';
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.go(AppRoutes.worldMap);
        }
      },
      child: Scaffold(
        body: SizedBox.expand(
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background Image
              Positioned.fill(
                child: Image.asset(
                  AppImages.bgVictory,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  alignment: Alignment.center,
                ),
              ),

              SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 16),

                // Red Ribbon Title Banner
                _buildBanner(),

                const SizedBox(height: 16),

                // 3D Arc Stars Row
                _buildStarsRow(),

                const SizedBox(height: 14),

                // Celebration Badge ("Wonderful!")
                _buildCelebrationBadge(),

                const SizedBox(height: 20),

                // Rewards Card (+50 Coins, +5 Gems side by side)
                _buildRewardsCard(),

                const Spacer(),

                // Centered Hero Watch Ad 2x Chest Button
                _buildWatchAdHero(context),

                const Spacer(),

                // Next Level Button
                GameButton(
                  text: 'Next Level',
                  onTap: () {
                    context.pushReplacement(
                      '${AppRoutes.gameplay}?level=${widget.levelId + 1}',
                    );
                  },
                  buttonColor: GameButtonColor.green,
                  width: 270,
                  height: 64,
                  fontSize: 26,
                )
                    .animate()
                    .fadeIn(delay: 800.ms)
                    .slideY(begin: 0.3, end: 0),

                const SizedBox(height: 12),

                // Back to Map Button
                GameButton(
                  text: 'Back to Map',
                  icon: Icons.home_rounded,
                  onTap: () => context.go(AppRoutes.worldMap),
                  buttonColor: GameButtonColor.blue,
                  width: 270,
                  height: 56,
                  fontSize: 22,
                )
                    .animate()
                    .fadeIn(delay: 900.ms)
                    .slideY(begin: 0.3, end: 0),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    ),
  ),
);
}

  Widget _buildBanner() {
    return Image.asset(
      AppImages.levelComplete,
      width: 320,
      height: 95,
      fit: BoxFit.contain,
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .scale(
          begin: const Offset(0.7, 0.7),
          duration: 600.ms,
          curve: Curves.elasticOut,
        );
  }

  Widget _buildStarsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Left Star
        _buildStarItem(
          index: 0,
          size: 92.0,
          angle: -0.12,
          yOffset: 8.0,
        ),
        const SizedBox(width: 4),
        // Center Star (Elevated and larger)
        _buildStarItem(
          index: 1,
          size: 114.0,
          angle: 0.0,
          yOffset: -10.0,
        ),
        const SizedBox(width: 4),
        // Right Star
        _buildStarItem(
          index: 2,
          size: 92.0,
          angle: 0.12,
          yOffset: 8.0,
        ),
      ],
    );
  }

  Widget _buildStarItem({
    required int index,
    required double size,
    required double angle,
    required double yOffset,
  }) {
    final isFilled = index < widget.starsEarned;

    return Transform.translate(
      offset: Offset(0, yOffset),
      child: Transform.rotate(
        angle: angle,
        child: Image.asset(
          AppImages.iconStar,
          width: size,
          height: size,
          color: isFilled ? null : Colors.black45,
          colorBlendMode: isFilled ? null : BlendMode.srcATop,
        )
            .animate(delay: Duration(milliseconds: 300 + index * 200))
            .scale(
              begin: const Offset(0, 0),
              duration: 600.ms,
              curve: Curves.elasticOut,
            ),
      ),
    );
  }

  Widget _buildCelebrationBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8E24AA), Color(0xFFAB47BC)],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white, width: 2.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x44000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        _celebrationText,
        style: GoogleFonts.fredoka(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
    )
        .animate()
        .fadeIn(delay: 500.ms, duration: 400.ms)
        .slideY(begin: 0.3, end: 0);
  }

  Widget _buildRewardsCard() {
    final coins = _adRewardClaimed ? widget.coinsEarned * 2 : widget.coinsEarned;
    final gems = widget.gemsEarned > 0 ? widget.gemsEarned : 5;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6E1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF5DFB5), width: 3),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Coins Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0C4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFFE082), width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(AppImages.iconCoin, width: 38, height: 38),
                const SizedBox(width: 8),
                Text(
                  '+$coins',
                  style: GoogleFonts.fredoka(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF5D4037),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Gems Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFE5F3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF8BBD0), width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(AppImages.iconGem, width: 38, height: 38),
                const SizedBox(width: 8),
                Text(
                  '+$gems',
                  style: GoogleFonts.fredoka(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF5D4037),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms);
  }

  Widget _buildWatchAdHero(BuildContext context) {
    if (_adRewardClaimed) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF8CE62C),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white, width: 2.5),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 28),
            const SizedBox(width: 8),
            Text(
              '2× Rewards Claimed!',
              style: GoogleFonts.fredoka(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
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
          },
          onFailed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Ad unavailable, try again.')),
            );
          },
        );
      },
      child: Image.asset(
        AppImages.watchAndWin2x,
        width: 210,
        height: 120,
        fit: BoxFit.contain,
      )
          .animate(onPlay: (controller) => controller.repeat(reverse: true))
          .scale(
            begin: const Offset(1.0, 1.0),
            end: const Offset(1.04, 1.04),
            duration: 1000.ms,
            curve: Curves.easeInOut,
          ),
    );
  }
}

