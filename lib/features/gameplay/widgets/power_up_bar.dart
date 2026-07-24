import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PowerUpBar extends StatelessWidget {
  final int hintsRemaining;
  final int shufflesRemaining;
  final int freezesRemaining;
  final bool isFrozen;
  final VoidCallback onHint;
  final VoidCallback onShuffle;
  final VoidCallback onFreeze;

  const PowerUpBar({
    super.key,
    required this.hintsRemaining,
    required this.shufflesRemaining,
    required this.freezesRemaining,
    required this.isFrozen,
    required this.onHint,
    required this.onShuffle,
    required this.onFreeze,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _PowerUpButton(
          icon: Icons.lightbulb_rounded,
          label: 'Hint',
          count: hintsRemaining,
          isDisabled: hintsRemaining <= 0,
          onTap: hintsRemaining > 0 ? onHint : null,
        ),
        _PowerUpButton(
          icon: Icons.shuffle_rounded,
          label: 'Shuffle',
          count: shufflesRemaining,
          isDisabled: shufflesRemaining <= 0,
          onTap: shufflesRemaining > 0 ? onShuffle : null,
        ),
        _PowerUpButton(
          icon: Icons.ac_unit_rounded,
          label: 'Freeze',
          count: freezesRemaining,
          isDisabled: freezesRemaining <= 0 || isFrozen,
          onTap: (freezesRemaining > 0 && !isFrozen) ? onFreeze : null,
          isActive: isFrozen,
        ),
      ],
    );
  }
}

class _PowerUpButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final bool isDisabled;
  final bool isActive;
  final VoidCallback? onTap;

  const _PowerUpButton({
    required this.icon,
    required this.label,
    required this.count,
    this.isDisabled = false,
    this.isActive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final opacity = isDisabled ? 0.5 : 1.0;

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: opacity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xFF0D47A1),
                        offset: Offset(0, 4),
                        blurRadius: 0,
                      ),
                      BoxShadow(
                        color: Color(0x33000000),
                        offset: Offset(0, 5),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF4FC3F7), Color(0xFF0288D1)],
                      ),
                      border: Border.all(color: Colors.white, width: 2.5),
                    ),
                    child: Center(
                      child: Icon(
                        icon,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                ),
                // Badge Pill
                Positioned(
                  right: -4,
                  bottom: -2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF7043),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white, width: 1.5),
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 2, offset: Offset(0, 1)),
                      ],
                    ),
                    child: Text(
                      'x$count',
                      style: GoogleFonts.fredoka(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.fredoka(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: const [
                  Shadow(color: Colors.black38, offset: Offset(0, 1), blurRadius: 2),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
