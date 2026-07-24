import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_images.dart';
import '../../core/providers/app_providers.dart';
import '../../core/router/app_router.dart';
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
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              AppImages.bgVictory,
              fit: BoxFit.cover,
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 24),

                // Red Ribbon Title Banner
                _buildBanner(),

                const SizedBox(height: 20),

                // 3D Stars Row
                _buildStarsRow(),

                const SizedBox(height: 14),

                // Celebration Badge ("Wonderful!")
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8E24AA), Color(0xFFAB47BC)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: const [
                      BoxShadow(color: Color(0x44000000), blurRadius: 6, offset: Offset(0, 3)),
                    ],
                  ),
                  child: Text(
                    _celebrationText,
                    style: GoogleFonts.fredoka(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(delay: 500.ms, duration: 400.ms)
                    .slideY(begin: 0.3, end: 0),

                const SizedBox(height: 20),

                // Rewards Card (+50 Coins, +5 Gems)
                _buildRewardsCard(),

                const SizedBox(height: 20),

                // Treasure Chest & Watch Ad x2
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(AppImages.iconChest, width: 100, height: 100)
                        .animate()
                        .fadeIn(delay: 400.ms)
                        .scale(begin: const Offset(0.7, 0.7), curve: Curves.elasticOut),
                    const SizedBox(width: 14),
                    _buildWatchAdButton(context),
                  ],
                ),

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
                  width: 260,
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
                  width: 260,
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
    );
  }

  Widget _buildBanner() {
    return Image.asset(
      AppImages.levelComplete,
      width: 300,
      height: 90,
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
      children: List.generate(3, (index) {
        final isFilled = index < widget.starsEarned;
        final size = index == 1 ? 84.0 : 64.0;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
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
        );
      }),
    );
  }

  Widget _buildRewardsCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEA),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFFD54F), width: 3),
        boxShadow: const [
          BoxShadow(
            color: Color(0x44000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(AppImages.iconCoin, width: 36, height: 36),
          const SizedBox(width: 8),
          Text(
            '+${_adRewardClaimed ? widget.coinsEarned * 2 : widget.coinsEarned}',
            style: GoogleFonts.fredoka(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFE65100),
            ),
          ),
          if (widget.gemsEarned > 0) ...[
            const SizedBox(width: 24),
            Image.asset(AppImages.iconGem, width: 36, height: 36),
            const SizedBox(width: 8),
            Text(
              '+${widget.gemsEarned}',
              style: GoogleFonts.fredoka(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF8E24AA),
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(delay: 600.ms);
  }

  Widget _buildWatchAdButton(BuildContext context) {
    if (_adRewardClaimed) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF8CE62C),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          '2× Claimed!',
          style: GoogleFonts.fredoka(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
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
        width: 150,
        height: 60,
        fit: BoxFit.contain,
      )
          .animate()
          .fadeIn(delay: 500.ms)
          .scale(begin: const Offset(0.8, 0.8), curve: Curves.elasticOut),
    );
  }
}
