import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers/app_providers.dart';

class ShopScreen extends ConsumerWidget {
  const ShopScreen({super.key});

  static Future<T?> show<T>(BuildContext context) {
    return showModalBottomSheet<T>(
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
          // Drag handle
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
                      child: const Text('🛍️', style: TextStyle(fontSize: 20)),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Power-Up Shop',
                      style: GoogleFonts.fredoka(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    _CurrencyChip(
                      icon: '🪙',
                      value: progress.coins,
                      borderColor: Colors.amber.shade300,
                      bgColor: const Color(0xFFFFF8E1),
                    ),
                    const SizedBox(width: 8),
                    _CurrencyChip(
                      icon: '💎',
                      value: progress.gems,
                      borderColor: Colors.cyan.shade300,
                      bgColor: const Color(0xFFE0F7FA),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: Colors.grey.shade200),

          // Shop Items List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                // Section 1: Power-ups
                _buildSectionHeader('POWER-UP BUNDLES', AppColors.skyBlue),
                const SizedBox(height: 14),

                _ShopCard(
                  title: 'Hint Pack',
                  description: '+3 Bulb Hints for finding letters',
                  icon: '💡',
                  costText: '100 🪙',
                  buttonColor: const Color(0xFFFFB74D),
                  glowColor: const Color(0xFFFFF59D),
                  onBuy: () {
                    final success = notifier.buyHint();
                    _showFeedback(context, success, '3 Hints purchased!');
                  },
                ).animate().fadeIn(delay: 50.ms).slideY(begin: 0.1, end: 0),

                const SizedBox(height: 14),

                _ShopCard(
                  title: 'Shuffle Pack',
                  description: '+3 Shuffles to rearrange letters',
                  icon: '🔄',
                  costText: '100 🪙',
                  buttonColor: const Color(0xFF4FC3F7),
                  glowColor: const Color(0xFFE1F5FE),
                  onBuy: () {
                    final success = notifier.buyShuffle();
                    _showFeedback(context, success, '3 Shuffles purchased!');
                  },
                ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0),

                const SizedBox(height: 14),

                _ShopCard(
                  title: 'Freeze Pack',
                  description: '+2 Freeze spells (15s timer pause)',
                  icon: '❄️',
                  costText: '150 🪙',
                  buttonColor: const Color(0xFFBA68C8),
                  glowColor: const Color(0xFFF3E5F5),
                  onBuy: () {
                    final success = notifier.buyFreeze();
                    _showFeedback(context, success, '2 Freezes purchased!');
                  },
                ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.1, end: 0),

                const SizedBox(height: 14),

                _ShopCard(
                  title: 'Super Bundle',
                  description: '+3 Hints, +3 Shuffles, +2 Freezes',
                  icon: '🎁',
                  costText: '300 🪙',
                  isFeatured: true,
                  buttonColor: const Color(0xFF66BB6A),
                  glowColor: const Color(0xFFFFF8E1),
                  onBuy: () {
                    final success = notifier.buyPowerUpPack();
                    _showFeedback(context, success, 'Super Bundle claimed!');
                  },
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),

                const SizedBox(height: 24),

                // Section 2: Lives & Currency
                _buildSectionHeader('LIVES & EXCHANGE', AppColors.softPurple),
                const SizedBox(height: 14),

                _ShopCard(
                  title: 'Refill Full Lives',
                  description: 'Instantly restore all 5 ❤️ hearts',
                  icon: '❤️',
                  costText: '100 🪙',
                  buttonColor: const Color(0xFFEF5350),
                  glowColor: const Color(0xFFFFEBEE),
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
                ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.1, end: 0),

                const SizedBox(height: 14),

                _ShopCard(
                  title: 'Gem to Coins',
                  description: 'Exchange 10 Gems 💎 for 300 Coins 🪙',
                  icon: '💎',
                  costText: '10 💎',
                  buttonColor: const Color(0xFF7E57C2),
                  glowColor: const Color(0xFFEDE7F6),
                  onBuy: () {
                    final success = notifier.spendGems(10);
                    if (success) {
                      notifier.addCoins(300);
                      _showFeedback(context, true, '+300 Coins added!');
                    } else {
                      _showFeedback(context, false, 'Not enough gems!');
                    }
                  },
                ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color accentColor) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: accentColor,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.fredoka(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark.withValues(alpha: 0.8),
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }

  void _showFeedback(BuildContext context, bool success, String message) {
    if (!context.mounted) return;

    if (success) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.vibrate();
    }

    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (ctx) => Positioned(
        top: MediaQuery.of(ctx).padding.top + 16,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: success ? const Color(0xFF10B981) : const Color(0xFFEF4444),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: (success ? const Color(0xFF10B981) : const Color(0xFFEF4444)).withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white24,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    success ? Icons.check_rounded : Icons.priority_high_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    success ? 'SUCCESS! $message' : message,
                    style: GoogleFonts.fredoka(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ).animate().slideY(begin: -0.5, end: 0, duration: 250.ms, curve: Curves.easeOutBack).fadeIn(),
      ),
    );

    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 2), () {
      if (entry.mounted) {
        entry.remove();
      }
    });
  }
}

class _ShopCard extends StatelessWidget {
  final String title;
  final String description;
  final String icon;
  final String costText;
  final Color buttonColor;
  final Color glowColor;
  final bool isFeatured;
  final VoidCallback onBuy;

  const _ShopCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.costText,
    required this.buttonColor,
    required this.glowColor,
    this.isFeatured = false,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isFeatured ? const Color(0xFFFFFDF5) : Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isFeatured ? const Color(0xFFFFC107) : Colors.grey.shade200,
              width: isFeatured ? 2.5 : 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: isFeatured ? const Color(0x22FFC107) : Colors.black.withValues(alpha: 0.04),
                blurRadius: isFeatured ? 10 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon with glowing avatar container
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: glowColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(icon, style: const TextStyle(fontSize: 26)),
                ),
              ),
              const SizedBox(width: 14),
              // Description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.fredoka(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMedium,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // 3D Gaming Action Button
              _ThreeDGameButton(
                text: costText,
                color: buttonColor,
                onPressed: onBuy,
              ),
            ],
          ),
        ),

        // Featured Badge
        if (isFeatured)
          Positioned(
            top: -10,
            right: 18,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF9800), Color(0xFFFF5722)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x40FF9800),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('⭐', style: TextStyle(fontSize: 10)),
                  const SizedBox(width: 3),
                  Text(
                    'BEST VALUE',
                    style: GoogleFonts.fredoka(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _ThreeDGameButton extends StatefulWidget {
  final String text;
  final Color color;
  final VoidCallback onPressed;

  const _ThreeDGameButton({
    required this.text,
    required this.color,
    required this.onPressed,
  });

  @override
  State<_ThreeDGameButton> createState() => _ThreeDGameButtonState();
}

class _ThreeDGameButtonState extends State<_ThreeDGameButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.color;
    final HSLColor hsl = HSLColor.fromColor(baseColor);
    final shadowColor = hsl.withLightness((hsl.lightness - 0.18).clamp(0.0, 1.0)).toColor();

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
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: shadowColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Opacity(
                opacity: 0,
                child: Text(
                  widget.text,
                  style: GoogleFonts.fredoka(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ),
            // Top layer
            Container(
              margin: EdgeInsets.only(bottom: shadowHeight),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                widget.text,
                style: GoogleFonts.fredoka(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
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

class _CurrencyChip extends StatelessWidget {
  final String icon;
  final int value;
  final Color borderColor;
  final Color bgColor;

  const _CurrencyChip({
    required this.icon,
    required this.value,
    required this.borderColor,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 5),
          Text(
            value.toString(),
            style: GoogleFonts.fredoka(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}
