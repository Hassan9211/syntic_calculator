import 'package:flutter/material.dart';
import 'package:syntic_calculator/settings/app_settings_controller.dart';
import 'package:syntic_calculator/settings/app_theme_palette.dart';

/// App ke tamam common colors aur gradients ko ek jagah rakhta hai.
class AppColors {
  const AppColors._();

  static AppThemePalette get _palette =>
      AppSettingsController.instance.themePalette;

  // Bunyadi backgrounds aur surfaces.
  static Color get background => _palette.background;
  static Color get backgroundSoft => _palette.backgroundSoft;
  static Color get surface => _palette.surface;
  static Color get panel => _palette.panel;
  static Color get glow => _palette.glow;
  static Color get highlight => _palette.highlight;

  // Brand aur accent colors.
  static Color get primary => _palette.primary;
  static Color get primaryDark => _palette.primaryDark;
  static Color get accentPurple => _palette.accentPurple;
  static Color get accentPurpleDark => _palette.accentPurpleDark;

  // Card, button aur text colors.
  static Color get card => _palette.card;
  static Color get cardTop => _palette.cardTop;
  static Color get cardBottom => _palette.cardBottom;
  static Color get buttonDark => _palette.buttonDark;
  static Color get buttonSecondary => _palette.buttonSecondary;
  static const Color navInactive = Color(0xFF666273);
  static const Color borderSubtle = Color(0x14FFFFFF);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0x8EF1EFFA);
  static const Color progressTrack = Color(0xFF221F2D);
  static Color get pageTop => _palette.pageTop;
  static Color get pageBottom => _palette.pageBottom;
  static Color get headerBackground => _palette.headerBackground;
  static Color get settingsCard => _palette.settingsCard;
  static Color get settingsTile => _palette.settingsTile;
  static Color get profileAvatarStart => _palette.profileAvatarStart;
  static Color get profileAvatarEnd => _palette.profileAvatarEnd;
  static Color get actionStart => _palette.actionStart;
  static Color get actionEnd => _palette.actionEnd;
  static Color get actionBorder => _palette.actionBorder;
  static Color get actionGlow => _palette.actionGlow;
  static Color get actionIcon => _palette.actionIcon;
  static Color get actionText => _palette.actionText;
  static Color get modeBackground => _palette.modeBackground;
  static Color get deleteButtonStart => _palette.deleteButtonStart;
  static Color get deleteButtonEnd => _palette.deleteButtonEnd;
  static Color get equalForeground => _palette.equalForeground;
  static List<Color> get pageBackgroundGradient =>
      _palette.pageBackgroundGradient;

  // Splash screen ke background glow ke liye.
  static List<Color> get splashGradient => _palette.splashGradient;

  // Progress bar aur loading accents ke liye.
  static List<Color> get progressGradient => _palette.progressGradient;

  // Calculator aur history screens ke neeche common page background.
  static List<Color> get calculatorPanelGradient =>
      _palette.calculatorPanelGradient;

  // Yeh bright gradient sirf operator buttons ke liye rakha gaya hai.
  static List<Color> get operatorGradient => _palette.operatorGradient;
}
