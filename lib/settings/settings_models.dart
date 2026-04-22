import 'package:flutter/material.dart';

/// Display aesthetics card ki visual config ko represent karta hai.
class SettingsThemePreset {
  const SettingsThemePreset({
    required this.id,
    required this.title,
    required this.icon,
    required this.accentColor,
    required this.previewStartColor,
    required this.previewEndColor,
  });

  final String id;
  final String title;
  final IconData icon;
  final Color accentColor;
  final Color previewStartColor;
  final Color previewEndColor;
}

/// Settings screen ke toggle row data ko ek jagah rakhta hai.
class SettingsResponseOption {
  const SettingsResponseOption({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    this.initialValue = true,
  });

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final bool initialValue;
}
