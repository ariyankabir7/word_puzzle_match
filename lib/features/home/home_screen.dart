import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_images.dart';
import '../../core/providers/app_providers.dart';
import '../../core/router/app_router.dart';
import '../../shared/widgets/game_button.dart';
import '../achievements/achievements_screen.dart';
import '../daily_rewards/daily_rewards_dialog.dart';
import '../settings/settings_dialog.dart';
import '../shop/shop_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(playerProgressProvider);

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              AppImages.bgHome,
              fit: BoxFit.cover,
            ),
          ),

          // Main Content
          SafeArea(
            child: Column(
              children: [
                // Top Icons Row
                _buildTopBar(context, ref),

                const Spacer(flex: 1),

                // 3D Title Logo
                Image.asset(
                  AppImages.logoTitle,
                  width: 320,
                  height: 180,
                  fit: BoxFit.contain,
                )
                    .animate()
                    .fadeIn(duration: 500.ms)
                    .slideY(begin: -0.2, end: 0),

                const SizedBox(height: 4),

                // Ribbon Tagline Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8E24AA), Color(0xFFAB47BC)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x44000000),
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      )
                    ],
                  ),
                  child: Text(
                    'Fun Words, Big Smiles!',
                    style: GoogleFonts.fredoka(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.8,
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(delay: 200.ms, duration: 400.ms),

                const Spacer(flex: 2),

                // 3D PLAY Button
                GameButton(
                  text: 'PLAY',
                  onTap: () => context.push(AppRoutes.worldMap),
                  buttonColor: GameButtonColor.green,
                  width: 260,
                  height: 72,
                  fontSize: 32,
                )
                    .animate()
                    .fadeIn(delay: 300.ms, duration: 400.ms)
                    .scale(
                      begin: const Offset(0.85, 0.85),
                      duration: 500.ms,
                      curve: Curves.elasticOut,
                    ),

                const SizedBox(height: 14),

                // Level Progress Pill
                _buildLevelBadge(progress.currentLevel)
                    .animate()
                    .fadeIn(delay: 400.ms, duration: 400.ms),

                const Spacer(flex: 2),

                // Bottom Action Buttons
                _buildBottomNav(context),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Settings Gear Button
          _CircleIconButton(
            icon: Icons.settings_rounded,
            color: const Color(0xFFFF9800),
            onTap: () => SettingsDialog.show(context),
          ),
          // Sound Speaker Button
          _CircleIconButton(
            icon: Icons.volume_up_rounded,
            color: const Color(0xFF2196F3),
            onTap: () => SettingsDialog.show(context),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelBadge(int currentLevel) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEA),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFFFD54F), width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        'Level $currentLevel of 500',
        style: GoogleFonts.fredoka(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF424242),
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _BottomNavCard(
            icon: Icons.emoji_events_rounded,
            iconColor: const Color(0xFFFFB300),
            label: 'Achievements',
            onTap: () => AchievementsScreen.show(context),
          ),
          _BottomNavCard(
            icon: Icons.calendar_month_rounded,
            iconColor: const Color(0xFFE91E63),
            label: 'Daily Reward',
            onTap: () => DailyRewardsDialog.show(context),
          ),
          _BottomNavCard(
            icon: Icons.storefront_rounded,
            iconColor: const Color(0xFF0288D1),
            label: 'Shop',
            onTap: () => ShopScreen.show(context),
          ),
          _BottomNavCard(
            icon: Icons.card_giftcard_rounded,
            iconColor: const Color(0xFFFF5722),
            label: 'Offers',
            onTap: () => ShopScreen.show(context),
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CircleIconButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: const [
            BoxShadow(
              color: Color(0x44000000),
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 28),
      ),
    );
  }
}

class _BottomNavCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;

  const _BottomNavCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.white, Color(0xFFF0F0F0)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white, width: 2.5),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Icon(icon, color: iconColor, size: 30),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.fredoka(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: const [
                Shadow(color: Colors.black45, offset: Offset(0, 1), blurRadius: 3),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
