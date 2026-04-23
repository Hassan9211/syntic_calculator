import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syntic_calculator/settings/app_theme_palette.dart';
import 'package:syntic_calculator/storage/calculation_history_storage.dart';

/// Global app settings ko memory aur local prefs ke darmiyan sync rakhta hai.
class AppSettingsController extends ChangeNotifier {
  AppSettingsController._();

  static final AppSettingsController instance = AppSettingsController._();

  static const String _themeKey = 'app_theme_id';
  static const String _hapticsKey = 'settings_haptics_enabled';
  static const String _interfaceAudioKey = 'settings_interface_audio_enabled';
  static const String _cloudHistoryKey = 'settings_cloud_history_enabled';

  SharedPreferences? _prefs;
  String _selectedThemeId = defaultAppThemeId;
  bool _hapticsEnabled = true;
  bool _interfaceAudioEnabled = true;
  bool _cloudHistoryEnabled = true;

  AppThemePalette get themePalette => appThemePaletteFor(_selectedThemeId);

  String get selectedThemeId => _selectedThemeId;

  bool get hapticsEnabled => _hapticsEnabled;

  bool get interfaceAudioEnabled => _interfaceAudioEnabled;

  bool get cloudHistoryEnabled => _cloudHistoryEnabled;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _prefs = prefs;
    _selectedThemeId = prefs.getString(_themeKey) ?? defaultAppThemeId;
    _hapticsEnabled = prefs.getBool(_hapticsKey) ?? true;
    _interfaceAudioEnabled = prefs.getBool(_interfaceAudioKey) ?? true;
    _cloudHistoryEnabled = prefs.getBool(_cloudHistoryKey) ?? true;
  }

  ThemeData buildTheme() {
    final palette = themePalette;

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: palette.background,
      colorScheme: ColorScheme.dark(
        primary: palette.primary,
        secondary: palette.accentPurple,
        surface: palette.surface,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: palette.card.withValues(alpha: 0.98),
        contentTextStyle: const TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> selectTheme(String themeId) async {
    if (_selectedThemeId == themeId) {
      return;
    }

    _selectedThemeId = appThemePaletteFor(themeId).id;
    notifyListeners();
    await _persistString(_themeKey, _selectedThemeId);
  }

  Future<void> setHapticsEnabled(bool value) async {
    if (_hapticsEnabled == value) {
      return;
    }

    _hapticsEnabled = value;
    notifyListeners();
    await _persistBool(_hapticsKey, value);
  }

  Future<void> setInterfaceAudioEnabled(bool value) async {
    if (_interfaceAudioEnabled == value) {
      return;
    }

    _interfaceAudioEnabled = value;
    notifyListeners();
    await _persistBool(_interfaceAudioKey, value);
  }

  Future<void> setCloudHistoryEnabled(bool value) async {
    if (_cloudHistoryEnabled == value) {
      return;
    }

    _cloudHistoryEnabled = value;
    notifyListeners();
    await _persistBool(_cloudHistoryKey, value);

    if (value) {
      await CalculationHistoryStorage.syncCloudArchiveFromLocal();
    }
  }

  Future<void> _persistBool(String key, bool value) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    _prefs ??= prefs;
    await prefs.setBool(key, value);
  }

  Future<void> _persistString(String key, String value) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    _prefs ??= prefs;
    await prefs.setString(key, value);
  }
}
