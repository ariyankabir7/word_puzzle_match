import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/providers/app_providers.dart';
import '../../core/router/app_router.dart';
import '../../shared/widgets/owl_mascot.dart';
import '../achievements/achievements_screen.dart';
import '../daily_rewards/daily_rewards_dialog.dart';
import '../settings/settings_dialog.dart';
import '../shop/shop_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(playerProgressProvider);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF87CEEB),
              Color(0xFF5CB8E4),
              Color(0xFF3D9EC9),
              Color(0xFF2A7EA8),
            ],
            stops: [0, 0.35, 0.7, 1],
          ),
        ),
        child: Stack(
          children: [
            // Background scene
            ..._buildBackground(size),

            // Main content
            SafeArea(
              child: Column(
                children: [
                  // Top icons row
                  _buildTopBar(context, ref),

                  const Spacer(),

                  // Logo
                  _buildLogo()
                      .animate()
                      .fadeIn(duration: 500.ms)
                      .slideY(begin: -0.2, end: 0),

                  const SizedBox(height: 8),

                  // Tagline
                  Text(
                    'Fun Words, Big Smiles!',
                    style: AppTextStyles.tagline,
                  )
                      .animate()
                      .fadeIn(delay: 200.ms, duration: 400.ms),

                  const SizedBox(height: 24),

                  // Owl mascot
                  const OwlMascot(size: 160, mood: OwlMood.idle)
                      .animate()
                      .fadeIn(delay: 100.ms, duration: 500.ms)
                      .scale(
                        begin: const Offset(0.8, 0.8),
                        duration: 600.ms,
                        curve: Curves.elasticOut,
                      ),

                  const SizedBox(height: 28),

                  // PLAY button
                  _buildPlayButton(context)
                      .animate()
                      .fadeIn(delay: 300.ms, duration: 400.ms)
                      .scale(
                        begin: const Offset(0.8, 0.8),
                        duration: 500.ms,
                        curve: Curves.elasticOut,
                      ),

                  const SizedBox(height: 20),

                  // Level progress badge
                  _buildLevelBadge(progress.currentLevel)
                      .animate()
                      .fadeIn(delay: 400.ms, duration: 400.ms),

                  const Spacer(),

                  // Bottom navigation
                  _buildBottomNav(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(playerProgressProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Settings icon
          _IconButton(
            icon: Icons.settings_rounded,
            onTap: () => SettingsDialog.show(context),
          ),
          // Currency display
          GestureDetector(
            onTap: () => ShopScreen.show(context),
            child: Row(
              children: [
                _CurrencyPill(icon: '❤️', value: progress.lives),
                const SizedBox(width: 6),
                _CurrencyPill(icon: '🪙', value: progress.coins),
                const SizedBox(width: 6),
                _CurrencyPill(icon: '💎', value: progress.gems),
                const SizedBox(width: 6),
                const _CurrencyPill(icon: '➕', value: 0, showPlus: true),
              ],
            ),
          ),
          // Sound icon
          _IconButton(
            icon: Icons.volume_up_rounded,
            onTap: () => SettingsDialog.show(context),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Word\n',
                style: AppTextStyles.logoTitle.copyWith(
                  fontSize: 50,
                  color: AppColors.sunshineYellow,
                ),
              ),
              TextSpan(
                text: 'Puzzle\n',
                style: AppTextStyles.logoTitle.copyWith(
                  fontSize: 44,
                  color: Colors.white,
                ),
              ),
              TextSpan(
                text: 'Match',
                style: AppTextStyles.logoTitle.copyWith(
                  fontSize: 44,
                  color: AppColors.lushGreen,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlayButton(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.worldMap),
      child: AnimatedContainer(
        duration: 150.ms,
        padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 18),
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
              offset: Offset(0, 6),
              blurRadius: 0,
            ),
            BoxShadow(
              color: Color(0x44000000),
              offset: Offset(0, 8),
              blurRadius: 12,
            ),
          ],
        ),
        child: Text('PLAY', style: AppTextStyles.playButton),
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scale(
          begin: const Offset(1, 1),
          end: const Offset(1.03, 1.03),
          duration: 1200.ms,
          curve: Curves.easeInOut,
        );
  }

  Widget _buildLevelBadge(int currentLevel) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        'Level $currentLevel of 500',
        style: AppTextStyles.bodyLarge.copyWith(
          color: AppColors.textDark,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 0),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Color(0x22000000), blurRadius: 12, offset: Offset(0, -3)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.emoji_events_rounded,
                label: 'Achievements',
                onTap: () => AchievementsScreen.show(context),
              ),
              _NavItem(
                icon: Icons.card_giftcard_rounded,
                label: 'Daily Reward',
                onTap: () => DailyRewardsDialog.show(context),
              ),
              _NavItem(
                icon: Icons.storefront_rounded,
                label: 'Shop',
                onTap: () => ShopScreen.show(context),
              ),
              _NavItem(
                icon: Icons.local_offer_rounded,
                label: 'Offers',
                onTap: () => ShopScreen.show(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildBackground(Size size) {
    return [
      // Ground / grass strip at bottom
      Positioned(
        left: 0,
        right: 0,
        bottom: 0,
        child: Container(
          height: size.height * 0.22,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF6BCB77), Color(0xFF4CAF59)],
            ),
          ),
        ),
      ),

      // Castle silhouette
      Positioned(
        bottom: size.height * 0.18,
        left: 20,
        child: _buildCastle(),
      ),

      // Tree right
      Positioned(
        bottom: size.height * 0.2,
        right: 20,
        child: _buildTree(),
      ),

      // Clouds
      Positioned(
        top: 80,
        left: -10,
        child: CustomPaint(
          size: const Size(110, 50),
          painter: const _CloudPainter(opacity: 0.5),
        ).animate(onPlay: (c) => c.repeat(reverse: true)).moveX(begin: 0, end: 12, duration: 5000.ms),
      ),
      Positioned(
        top: 140,
        right: 20,
        child: CustomPaint(
          size: const Size(90, 42),
          painter: const _CloudPainter(opacity: 0.4),
        ).animate(onPlay: (c) => c.repeat(reverse: true)).moveX(begin: 0, end: -10, duration: 6000.ms),
      ),
    ];
  }

  Widget _buildCastle() {
    return CustomPaint(
      size: const Size(80, 80),
      painter: _CastlePainter(),
    );
  }

  Widget _buildTree() {
    return CustomPaint(
      size: const Size(50, 70),
      painter: _TreePainter(),
    );
  }
}

// ── Supporting Widgets ────────────────────────────────────────────────────────

class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.25),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1.5),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

class _CurrencyPill extends StatelessWidget {
  final String icon;
  final int value;
  final bool showPlus;

  const _CurrencyPill({required this.icon, required this.value, this.showPlus = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 13)),
          if (!showPlus) ...[
            const SizedBox(width: 3),
            Text(
              value > 999 ? '${(value / 1000).toStringAsFixed(1)}K' : value.toString(),
              style: AppTextStyles.coinCount.copyWith(fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _NavItem({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.navInactive, size: 26),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.navLabel, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// ── Painters ──────────────────────────────────────────────────────────────────

class _CloudPainter extends CustomPainter {
  final double opacity;
  const _CloudPainter({this.opacity = 0.5});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: opacity);
    canvas.drawCircle(Offset(size.width * 0.3, size.height * 0.6), size.height * 0.42, paint);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.42), size.height * 0.5, paint);
    canvas.drawCircle(Offset(size.width * 0.72, size.height * 0.6), size.height * 0.36, paint);
    canvas.drawRect(
        Rect.fromLTRB(size.width * 0.1, size.height * 0.6, size.width * 0.9, size.height), paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _CastlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFFB0C4DE).withValues(alpha: 0.6);
    canvas.drawRect(Rect.fromLTWH(size.width * 0.3, size.height * 0.3, size.width * 0.4, size.height * 0.7), paint);
    for (int i = 0; i < 3; i++) {
      canvas.drawRect(Rect.fromLTWH(size.width * (0.32 + i * 0.13), size.height * 0.18, size.width * 0.09, size.height * 0.14), paint);
    }
    canvas.drawRect(Rect.fromLTWH(0, size.height * 0.45, size.width * 0.28, size.height * 0.55), paint);
    canvas.drawRect(Rect.fromLTWH(size.width * 0.72, size.height * 0.45, size.width * 0.28, size.height * 0.55), paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _TreePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final trunkPaint = Paint()..color = const Color(0xFF8B5E3C).withValues(alpha: 0.7);
    final leafPaint = Paint()..color = const Color(0xFF4CAF59).withValues(alpha: 0.75);
    canvas.drawRect(Rect.fromLTWH(size.width * 0.38, size.height * 0.6, size.width * 0.24, size.height * 0.4), trunkPaint);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.35), size.width * 0.45, leafPaint);
    canvas.drawCircle(Offset(size.width * 0.3, size.height * 0.5), size.width * 0.3, leafPaint);
    canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.5), size.width * 0.3, leafPaint);
  }

  @override
  bool shouldRepaint(_) => false;
}
