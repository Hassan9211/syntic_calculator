import 'package:flutter/material.dart';

/// App ke runtime theme ke liye palette values ko ek object me rakhta hai.
class AppThemePalette {
  const AppThemePalette({
    required this.id,
    required this.background,
    required this.backgroundSoft,
    required this.surface,
    required this.panel,
    required this.glow,
    required this.highlight,
    required this.primary,
    required this.primaryDark,
    required this.accentPurple,
    required this.accentPurpleDark,
    required this.card,
    required this.cardTop,
    required this.cardBottom,
    required this.buttonDark,
    required this.buttonSecondary,
    required this.pageTop,
    required this.pageBottom,
    required this.headerBackground,
    required this.settingsCard,
    required this.settingsTile,
    required this.profileAvatarStart,
    required this.profileAvatarEnd,
    required this.actionStart,
    required this.actionEnd,
    required this.actionBorder,
    required this.actionGlow,
    required this.actionIcon,
    required this.actionText,
    required this.modeBackground,
    required this.deleteButtonStart,
    required this.deleteButtonEnd,
    required this.equalForeground,
  });

  final String id;
  final Color background;
  final Color backgroundSoft;
  final Color surface;
  final Color panel;
  final Color glow;
  final Color highlight;
  final Color primary;
  final Color primaryDark;
  final Color accentPurple;
  final Color accentPurpleDark;
  final Color card;
  final Color cardTop;
  final Color cardBottom;
  final Color buttonDark;
  final Color buttonSecondary;
  final Color pageTop;
  final Color pageBottom;
  final Color headerBackground;
  final Color settingsCard;
  final Color settingsTile;
  final Color profileAvatarStart;
  final Color profileAvatarEnd;
  final Color actionStart;
  final Color actionEnd;
  final Color actionBorder;
  final Color actionGlow;
  final Color actionIcon;
  final Color actionText;
  final Color modeBackground;
  final Color deleteButtonStart;
  final Color deleteButtonEnd;
  final Color equalForeground;

  List<Color> get splashGradient => [glow, panel, highlight];

  List<Color> get progressGradient => [primary, primaryDark];

  List<Color> get calculatorPanelGradient => [cardTop, cardBottom];

  List<Color> get operatorGradient => [accentPurple, accentPurpleDark];

  List<Color> get pageBackgroundGradient => [pageTop, pageBottom];
}

const String defaultAppThemeId = 'dark_glass';

const Map<String, AppThemePalette> appThemePalettes = {
  'dark_glass': AppThemePalette(
    id: 'dark_glass',
    background: Color(0xFF1E1D20),
    backgroundSoft: Color(0xFF252326),
    surface: Color(0xFF123845),
    panel: Color(0xFF111822),
    glow: Color(0xFF0E4A55),
    highlight: Color(0xFF6B5A89),
    primary: Color(0xFF08D8FF),
    primaryDark: Color(0xFF09B9E3),
    accentPurple: Color(0xFFC85BFF),
    accentPurpleDark: Color(0xFFA93EF5),
    card: Color(0xFF14131C),
    cardTop: Color(0xFF1A1826),
    cardBottom: Color(0xFF11101A),
    buttonDark: Color(0xFF27262F),
    buttonSecondary: Color(0xFF211F29),
    pageTop: Color(0xFF17161F),
    pageBottom: Color(0xFF13131A),
    headerBackground: Color(0xFF14131C),
    settingsCard: Color(0xFF22212B),
    settingsTile: Color(0xFF25232F),
    profileAvatarStart: Color(0xFF0F2F46),
    profileAvatarEnd: Color(0xFFB94C83),
    actionStart: Color(0xFF1C444B),
    actionEnd: Color(0xFF332935),
    actionBorder: Color(0xFFCE847D),
    actionGlow: Color(0xFF20E6FF),
    actionIcon: Color(0xFFF6B2A8),
    actionText: Color(0xFFF6C6BE),
    modeBackground: Color(0xFF171824),
    deleteButtonStart: Color(0xFFD15FFF),
    deleteButtonEnd: Color(0xFFA73EF6),
    equalForeground: Color(0xFF042A31),
  ),
  'light_minimal': AppThemePalette(
    id: 'light_minimal',
    background: Color(0xFF242328),
    backgroundSoft: Color(0xFF2D2B31),
    surface: Color(0xFF35414C),
    panel: Color(0xFF1B1E24),
    glow: Color(0xFF606E80),
    highlight: Color(0xFF8E7E98),
    primary: Color(0xFFC7D2E0),
    primaryDark: Color(0xFFA5B3C4),
    accentPurple: Color(0xFFD7C8EE),
    accentPurpleDark: Color(0xFFB5A4CB),
    card: Color(0xFF1D1B20),
    cardTop: Color(0xFF36313A),
    cardBottom: Color(0xFF211E25),
    buttonDark: Color(0xFF3A353E),
    buttonSecondary: Color(0xFF29252D),
    pageTop: Color(0xFF3E3844),
    pageBottom: Color(0xFF2B2730),
    headerBackground: Color(0xFF211F25),
    settingsCard: Color(0xFF3B3640),
    settingsTile: Color(0xFF34303A),
    profileAvatarStart: Color(0xFF596675),
    profileAvatarEnd: Color(0xFFA28FAA),
    actionStart: Color(0xFF57616E),
    actionEnd: Color(0xFF4B3E4A),
    actionBorder: Color(0xFFD8C9C1),
    actionGlow: Color(0xFFC7D2E0),
    actionIcon: Color(0xFFF6E6DD),
    actionText: Color(0xFFF7EEE8),
    modeBackground: Color(0xFF26242B),
    deleteButtonStart: Color(0xFFC9ABD9),
    deleteButtonEnd: Color(0xFFA68EB5),
    equalForeground: Color(0xFF23242A),
  ),
  'neon_blue': AppThemePalette(
    id: 'neon_blue',
    background: Color(0xFF102029),
    backgroundSoft: Color(0xFF162B34),
    surface: Color(0xFF0F485C),
    panel: Color(0xFF081920),
    glow: Color(0xFF0A7895),
    highlight: Color(0xFF175F7A),
    primary: Color(0xFF22F0FF),
    primaryDark: Color(0xFF0AC5D6),
    accentPurple: Color(0xFF5CD9FF),
    accentPurpleDark: Color(0xFF1FA7E0),
    card: Color(0xFF0E151C),
    cardTop: Color(0xFF0F2430),
    cardBottom: Color(0xFF09141C),
    buttonDark: Color(0xFF15303A),
    buttonSecondary: Color(0xFF10262F),
    pageTop: Color(0xFF0F2430),
    pageBottom: Color(0xFF08151D),
    headerBackground: Color(0xFF0E1B24),
    settingsCard: Color(0xFF132833),
    settingsTile: Color(0xFF17303C),
    profileAvatarStart: Color(0xFF0F3C57),
    profileAvatarEnd: Color(0xFF0E7FA1),
    actionStart: Color(0xFF0C6370),
    actionEnd: Color(0xFF153D4B),
    actionBorder: Color(0xFF74F7FF),
    actionGlow: Color(0xFF22F0FF),
    actionIcon: Color(0xFFD9FEFF),
    actionText: Color(0xFFE8FEFF),
    modeBackground: Color(0xFF0F1E28),
    deleteButtonStart: Color(0xFF0E6C8B),
    deleteButtonEnd: Color(0xFF0A4861),
    equalForeground: Color(0xFF072830),
  ),
  'purple_glow': AppThemePalette(
    id: 'purple_glow',
    background: Color(0xFF211626),
    backgroundSoft: Color(0xFF2B1C31),
    surface: Color(0xFF46235B),
    panel: Color(0xFF1D1223),
    glow: Color(0xFF6A2F79),
    highlight: Color(0xFF8E4BA8),
    primary: Color(0xFFD9A0FF),
    primaryDark: Color(0xFFB979EF),
    accentPurple: Color(0xFFFF7CF8),
    accentPurpleDark: Color(0xFFD554D1),
    card: Color(0xFF1B1220),
    cardTop: Color(0xFF2D1834),
    cardBottom: Color(0xFF170D1B),
    buttonDark: Color(0xFF35213A),
    buttonSecondary: Color(0xFF28162D),
    pageTop: Color(0xFF2A1630),
    pageBottom: Color(0xFF190F1D),
    headerBackground: Color(0xFF201228),
    settingsCard: Color(0xFF34203A),
    settingsTile: Color(0xFF392741),
    profileAvatarStart: Color(0xFF4C1F63),
    profileAvatarEnd: Color(0xFFA33E8F),
    actionStart: Color(0xFF6B2D74),
    actionEnd: Color(0xFF40213F),
    actionBorder: Color(0xFFE8B4FF),
    actionGlow: Color(0xFFD9A0FF),
    actionIcon: Color(0xFFFFE2FB),
    actionText: Color(0xFFFFF0FD),
    modeBackground: Color(0xFF27142D),
    deleteButtonStart: Color(0xFFA34ECB),
    deleteButtonEnd: Color(0xFF7E2DAD),
    equalForeground: Color(0xFF2F103A),
  ),
};

AppThemePalette appThemePaletteFor(String id) {
  return appThemePalettes[id] ?? appThemePalettes[defaultAppThemeId]!;
}
