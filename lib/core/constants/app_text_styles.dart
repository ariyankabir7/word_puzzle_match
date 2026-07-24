import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Title / Logo — Fredoka One
  static TextStyle get logoTitle => GoogleFonts.fredoka(
    fontSize: 48,
    color: AppColors.white,
    letterSpacing: 1.2,
    shadows: [
      const Shadow(
        color: Color(0x66000000),
        offset: Offset(2, 3),
        blurRadius: 6,
      ),
    ],
  );

  static TextStyle get headingXL => GoogleFonts.fredoka(
    fontSize: 32,
    color: AppColors.textDark,
    letterSpacing: 0.5,
  );

  static TextStyle get headingLarge => GoogleFonts.fredoka(
    fontSize: 24,
    color: AppColors.textDark,
  );

  static TextStyle get headingMedium => GoogleFonts.fredoka(
    fontSize: 20,
    color: AppColors.textDark,
  );

  static TextStyle get headingSmall => GoogleFonts.fredoka(
    fontSize: 16,
    color: AppColors.textDark,
  );

  // Body — Nunito
  static TextStyle get bodyLarge => GoogleFonts.nunito(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
  );

  static TextStyle get bodyMedium => GoogleFonts.nunito(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textMedium,
  );

  static TextStyle get bodySmall => GoogleFonts.nunito(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textLight,
  );

  // Game-specific
  static TextStyle get gridLetter => GoogleFonts.fredoka(
    fontSize: 22,
    color: AppColors.textDark,
    letterSpacing: 0,
  );

  static TextStyle get gridLetterFound => GoogleFonts.fredoka(
    fontSize: 22,
    color: AppColors.white,
    letterSpacing: 0,
  );

  static TextStyle get wordListItem => GoogleFonts.nunito(
    fontSize: 14,
    fontWeight: FontWeight.w800,
    color: AppColors.textDark,
    letterSpacing: 1.0,
  );

  static TextStyle get wordListItemFound => GoogleFonts.nunito(
    fontSize: 14,
    fontWeight: FontWeight.w800,
    color: AppColors.textLight,
    decoration: TextDecoration.lineThrough,
    letterSpacing: 1.0,
  );

  static TextStyle get timerNormal => GoogleFonts.fredoka(
    fontSize: 22,
    color: AppColors.timerNormal,
    letterSpacing: 1.5,
  );

  static TextStyle get timerWarning => GoogleFonts.fredoka(
    fontSize: 22,
    color: AppColors.timerWarning,
    letterSpacing: 1.5,
  );

  static TextStyle get moveCounter => GoogleFonts.nunito(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.textMedium,
  );

  static TextStyle get coinCount => GoogleFonts.fredoka(
    fontSize: 16,
    color: AppColors.textDark,
  );

  static TextStyle get levelLabel => GoogleFonts.fredoka(
    fontSize: 14,
    color: AppColors.textDark,
  );

  static TextStyle get playButton => GoogleFonts.fredoka(
    fontSize: 28,
    color: AppColors.white,
    letterSpacing: 3,
    shadows: [
      const Shadow(
        color: Color(0x66000000),
        offset: Offset(0, 2),
        blurRadius: 4,
      ),
    ],
  );

  static TextStyle get tagline => GoogleFonts.nunito(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.white,
    letterSpacing: 0.5,
  );

  static TextStyle get levelComplete => GoogleFonts.fredoka(
    fontSize: 28,
    color: AppColors.white,
    letterSpacing: 1,
    shadows: [
      const Shadow(
        color: Color(0x55000000),
        offset: Offset(1, 2),
        blurRadius: 5,
      ),
    ],
  );

  static TextStyle get rewardLabel => GoogleFonts.nunito(
    fontSize: 20,
    fontWeight: FontWeight.w800,
    color: AppColors.sunshineYellow,
  );

  static TextStyle get powerUpCount => GoogleFonts.fredoka(
    fontSize: 13,
    color: AppColors.white,
  );

  static TextStyle get navLabel => GoogleFonts.nunito(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    color: AppColors.navInactive,
  );

  static TextStyle get navLabelActive => GoogleFonts.nunito(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    color: AppColors.navActive,
  );
}
