import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum GameButtonColor { green, blue, orange, purple }

class GameButton extends StatefulWidget {
  final String text;
  final IconData? icon;
  final VoidCallback onTap;
  final GameButtonColor buttonColor;
  final double width;
  final double height;
  final double fontSize;

  const GameButton({
    super.key,
    required this.text,
    required this.onTap,
    this.icon,
    this.buttonColor = GameButtonColor.green,
    this.width = 240,
    this.height = 64,
    this.fontSize = 26,
  });

  @override
  State<GameButton> createState() => _GameButtonState();
}

class _GameButtonState extends State<GameButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    Color topColor;
    Color bottomColor;
    Color shadowColor;

    switch (widget.buttonColor) {
      case GameButtonColor.green:
        topColor = const Color(0xFF8CE62C);
        bottomColor = const Color(0xFF58B610);
        shadowColor = const Color(0xFF387A06);
        break;
      case GameButtonColor.blue:
        topColor = const Color(0xFF4AC4FA);
        bottomColor = const Color(0xFF1E88E5);
        shadowColor = const Color(0xFF0D47A1);
        break;
      case GameButtonColor.orange:
        topColor = const Color(0xFFFFB74D);
        bottomColor = const Color(0xFFF57C00);
        shadowColor = const Color(0xFFE65100);
        break;
      case GameButtonColor.purple:
        topColor = const Color(0xFFAB47BC);
        bottomColor = const Color(0xFF7B1FA2);
        shadowColor = const Color(0xFF4A148C);
        break;
    }

    final double topMargin = _isPressed ? 4.0 : 0.0;
    final double shadowHeight = _isPressed ? 2.0 : 6.0;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 60),
        margin: EdgeInsets.only(top: topMargin),
        width: widget.width,
        height: widget.height,
        child: Stack(
          children: [
            // 3D Bottom Shadow / Bevel
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: widget.height - 4,
              child: Container(
                decoration: BoxDecoration(
                  color: shadowColor,
                  borderRadius: BorderRadius.circular(widget.height / 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 6,
                      offset: Offset(0, 4),
                    )
                  ],
                ),
              ),
            ),
            // Top Glossy Button Face
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              bottom: shadowHeight,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [topColor, bottomColor],
                  ),
                  borderRadius: BorderRadius.circular(widget.height / 2),
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon, color: Colors.white, size: widget.fontSize + 2),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        widget.text,
                        style: GoogleFonts.fredoka(
                          fontSize: widget.fontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                          shadows: [
                            const Shadow(
                              color: Color(0x55000000),
                              offset: Offset(0, 2),
                              blurRadius: 3,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
