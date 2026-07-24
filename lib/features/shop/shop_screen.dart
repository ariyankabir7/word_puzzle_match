import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/providers/app_providers.dart';

class ShopScreen extends ConsumerWidget {
  const ShopScreen({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ShopScreen(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(playerProgressProvider);
    final notifier = ref.read(playerProgressProvider.notifier);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          // Drag handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 12),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Power-Up Shop 🛍️',
                  style: AppTextStyles.headingLarge.copyWith(color: AppColors.textDark),
                ),
                Row(
                  children: [
                    _CurrencyChip(icon: '🪙', value: progress.coins),
                    const SizedBox(width: 8),
                    _CurrencyChip(icon: '💎', value: progress.gems),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 24),

          // Shop Items List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              children: [
                // Section 1: Power-ups
                Text('Power-Up Bundles', style: AppTextStyles.headingSmall),
                const SizedBox(height: 12),

                _ShopCard(
                  title: 'Hint Pack',
                  description: '+3 Bulb Hints for finding letters',
                  icon: '💡',
                  costText: '100 🪙',
                  buttonColor: AppColors.sunshineYellow,
                  onBuy: () {
                    final success = notifier.buyHint();
                    _showFeedback(context, success, '3 Hints purchased!');
                  },
                ).animate().fadeIn(delay: 50.ms),

                const SizedBox(height: 12),

                _ShopCard(
                  title: 'Shuffle Pack',
                  description: '+3 Shuffles to rearrange non-found letters',
                  icon: '🔄',
                  costText: '100 🪙',
                  buttonColor: AppColors.skyBlue,
                  onBuy: () {
                    final success = notifier.buyShuffle();
                    _showFeedback(context, success, '3 Shuffles purchased!');
                  },
                ).animate().fadeIn(delay: 100.ms),

                const SizedBox(height: 12),

                _ShopCard(
                  title: 'Freeze Pack',
                  description: '+2 Freeze spells (15s timer pause)',
                  icon: '❄️',
                  costText: '150 🪙',
                  buttonColor: AppColors.softPurple,
                  onBuy: () {
                    final success = notifier.buyFreeze();
                    _showFeedback(context, success, '2 Freezes purchased!');
                  },
                ).animate().fadeIn(delay: 150.ms),

                const SizedBox(height: 12),

                _ShopCard(
                  title: 'Super Bundle (Best Value!)',
                  description: '+3 Hints, +3 Shuffles, +2 Freezes',
                  icon: '🎁',
                  costText: '300 🪙',
                  isFeatured: true,
                  buttonColor: AppColors.lushGreen,
                  onBuy: () {
                    final success = notifier.buyPowerUpPack();
                    _showFeedback(context, success, 'Super Bundle claimed!');
                  },
                ).animate().fadeIn(delay: 200.ms),

                const SizedBox(height: 24),

                // Section 2: Lives & Currency
                Text('Lives & Exchange', style: AppTextStyles.headingSmall),
                const SizedBox(height: 12),

                _ShopCard(
                  title: 'Refill Full Lives',
                  description: 'Instantly restore all 5 ❤️ hearts',
                  icon: '❤️',
                  costText: '100 🪙',
                  buttonColor: Colors.redAccent,
                  onBuy: () {
                    if (progress.lives >= 5) {
                      _showFeedback(context, false, 'Lives already full!');
                      return;
                    }
                    final success = notifier.spendCoins(100);
                    if (success) {
                      notifier.refillLives();
                      _showFeedback(context, true, 'Lives refilled to 5!');
                    } else {
                      _showFeedback(context, false, 'Not enough coins!');
                    }
                  },
                ).animate().fadeIn(delay: 250.ms),

                const SizedBox(height: 12),

                _ShopCard(
                  title: 'Gem to Coins',
                  description: 'Exchange 10 Gems 💎 for 300 Coins 🪙',
                  icon: '💎',
                  costText: '10 💎',
                  buttonColor: Colors.deepPurple,
                  onBuy: () {
                    final success = notifier.spendGems(10);
                    if (success) {
                      notifier.addCoins(300);
                      _showFeedback(context, true, '+300 Coins added!');
                    } else {
                      _showFeedback(context, false, 'Not enough gems!');
                    }
                  },
                ).animate().fadeIn(delay: 300.ms),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showFeedback(BuildContext context, bool success, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? '✅ $message' : '❌ Not enough coins/gems!',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: success ? AppColors.lushGreen : Colors.redAccent,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class _ShopCard extends StatelessWidget {
  final String title;
  final String description;
  final String icon;
  final String costText;
  final Color buttonColor;
  final bool isFeatured;
  final VoidCallback onBuy;

  const _ShopCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.costText,
    required this.buttonColor,
    this.isFeatured = false,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isFeatured ? const Color(0xFFFFF9E6) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isFeatured ? AppColors.sunshineYellow : Colors.grey.shade200,
          width: isFeatured ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 4),
              ],
            ),
            child: Center(
              child: Text(icon, style: const TextStyle(fontSize: 26)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: AppTextStyles.bodySmall.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: onBuy,
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              elevation: 2,
            ),
            child: Text(
              costText,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrencyChip extends StatelessWidget {
  final String icon;
  final int value;

  const _CurrencyChip({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Text(
            value.toString(),
            style: AppTextStyles.coinCount.copyWith(fontSize: 13),
          ),
        ],
      ),
    );
  }
}
