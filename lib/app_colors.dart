import 'package:flutter/material.dart';

/// App ke tamam common colors aur gradients ko ek jagah rakhta hai.
class AppColors {
  const AppColors._();

  // Bunyadi backgrounds aur surfaces.
  static const Color background = Color(0xFF1E1D20);
  static const Color backgroundSoft = Color(0xFF252326);
  static const Color surface = Color(0xFF123845);
  static const Color panel = Color(0xFF111822);
  static const Color glow = Color(0xFF0E4A55);
  static const Color highlight = Color(0xFF6B5A89);

  // Brand aur accent colors.
  static const Color primary = Color(0xFF08D8FF);
  static const Color primaryDark = Color(0xFF09B9E3);
  static const Color accentPurple = Color(0xFFC85BFF);
  static const Color accentPurpleDark = Color(0xFFA93EF5);

  // Card, button aur text colors.
  static const Color card = Color(0xFF14131C);
  static const Color cardTop = Color(0xFF1A1826);
  static const Color cardBottom = Color(0xFF11101A);
  static const Color buttonDark = Color(0xFF27262F);
  static const Color buttonSecondary = Color(0xFF211F29);
  static const Color navInactive = Color(0xFF666273);
  static const Color borderSubtle = Color(0x14FFFFFF);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0x8EF1EFFA);
  static const Color progressTrack = Color(0xFF221F2D);

  // Splash screen ke background glow ke liye.
  static const List<Color> splashGradient = [glow, panel, highlight];

  // Progress bar aur loading accents ke liye.
  static const List<Color> progressGradient = [primary, primaryDark];

  // Calculator aur history screens ke neeche common page background.
  static const List<Color> calculatorPanelGradient = [cardTop, cardBottom];

  // Yeh bright gradient sirf operator buttons ke liye rakha gaya hai.
  static const List<Color> operatorGradient = [accentPurple, accentPurpleDark];
}
