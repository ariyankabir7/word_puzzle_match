import 'package:flutter/material.dart';

class AppColors {
  // Primary Palette
  static const Color skyBlue = Color(0xFF5CB8E4);
  static const Color skyBlueDark = Color(0xFF3A9EC9);
  static const Color sunshineYellow = Color(0xFFF9C74F);
  static const Color sunshineYellowDark = Color(0xFFE6A800);

  // Accent
  static const Color lushGreen = Color(0xFF6BCB77);
  static const Color lushGreenDark = Color(0xFF4CAF59);
  static const Color softPurple = Color(0xFF9B72CF);
  static const Color softPurpleDark = Color(0xFF7B52AF);

  // Background Gradients
  static const Color bgTop = Color(0xFF87CEEB);
  static const Color bgBottom = Color(0xFF5CB8E4);
  static const Color bgGradientStart = Color(0xFF74C8E8);
  static const Color bgGradientEnd = Color(0xFF48A8D0);

  // UI
  static const Color white = Color(0xFFFFFFFF);
  static const Color cardWhite = Color(0xFFFAFAFA);
  static const Color textDark = Color(0xFF2D3142);
  static const Color textMedium = Color(0xFF4A4A6A);
  static const Color textLight = Color(0xFF8888AA);
  static const Color shadow = Color(0x33000000);

  // Game Grid
  static const Color gridBackground = Color(0xFFEEF5FF);
  static const Color cellDefault = Color(0xFFFFFFFF);
  static const Color cellSelected = Color(0xFFBBDEFB);
  static const Color cellSelecting = Color(0xFF90CAF9);
  static const Color wrongSelection = Color(0xFFFFCDD2);

  // Word Found Colors (each word gets a unique color)
  static const List<Color> wordFoundColors = [
    Color(0xFF6BCB77), // green
    Color(0xFFFF9F1C), // orange
    Color(0xFF9B72CF), // purple
    Color(0xFFE84855), // red-pink
    Color(0xFF3BCEAC), // teal
    Color(0xFFF9C74F), // yellow
    Color(0xFF5CB8E4), // blue
    Color(0xFFFF6B9D), // pink
  ];

  // Node States (World Map)
  static const Color nodeLocked = Color(0xFFB0BEC5);
  static const Color nodeUnlocked = Color(0xFFFFFFFF);
  static const Color nodeComplete = Color(0xFFF9C74F);
  static const Color nodeCurrent = Color(0xFF5CB8E4);

  // Timer
  static const Color timerNormal = Color(0xFF2D3142);
  static const Color timerWarning = Color(0xFFE84855);

  // Stars
  static const Color starActive = Color(0xFFF9C74F);
  static const Color starInactive = Color(0xFFDDE0E8);

  // Button Colors
  static const Color btnPlay = Color(0xFF6BCB77);
  static const Color btnPlayShadow = Color(0xFF4CAF59);
  static const Color btnNext = Color(0xFF6BCB77);
  static const Color btnMap = Color(0xFF5CB8E4);

  // Bottom Nav
  static const Color navBackground = Color(0xFFFFFFFF);
  static const Color navActive = Color(0xFF5CB8E4);
  static const Color navInactive = Color(0xFFB0BEC5);
}
