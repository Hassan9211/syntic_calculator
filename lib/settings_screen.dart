import 'package:flutter/material.dart';
import 'package:syntic_calculator/app_colors.dart';
import 'package:syntic_calculator/routes/route_paths.dart';
import 'package:syntic_calculator/settings/app_settings_controller.dart';
import 'package:syntic_calculator/settings/settings_models.dart';
import 'package:syntic_calculator/storage/calculation_history_storage.dart';
import 'package:syntic_calculator/widgets/bottom_buttons.dart';
import 'package:syntic_calculator/widgets/header.dart';
import 'package:syntic_calculator/widgets/settings/settings_components.dart';

/// Settings tab jo app ke appearance aur feedback controls dikhata hai.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _setTheme(String presetId) async {
    await AppSettingsController.instance.selectTheme(presetId);
  }

  Future<void> _setResponseOption(
    BuildContext context,
    String optionId,
    bool value,
  ) async {
    final settings = AppSettingsController.instance;

    switch (optionId) {
      case 'tactile_haptics':
        await settings.setHapticsEnabled(value);
        return;
      case 'interface_audio':
        await settings.setInterfaceAudioEnabled(value);
        return;
      case 'cloud_history':
        await settings.setCloudHistoryEnabled(value);

        if (!context.mounted) {
          return;
        }

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                value
                    ? 'Cloud archive enabled. Local history will be mirrored for restore.'
                    : 'Cloud archive paused. Local history will stay on this device.',
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        return;
    }
  }

  Future<void> _confirmWipeLocalDatabase(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Wipe Local Database?',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
          ),
        ),
        content: Text(
          'All local calculation history will be permanently deleted. This cannot be undone.',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'No',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'Yes',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (!context.mounted) return;
      await _wipeLocalDatabase(context);
    }
  }

  Future<void> _wipeLocalDatabase(BuildContext context) async {
    await CalculationHistoryStorage.clearLocal();

    if (!context.mounted) {
      return;
    }

    final cloudHistoryEnabled =
        AppSettingsController.instance.cloudHistoryEnabled;

    final message = cloudHistoryEnabled
        ? 'Local calculation history wiped. Cloud archive can restore it on relaunch.'
        : 'Local calculation history wiped.';

    debugPrint('DEBUG: showing snackbar message: $message');
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
      );
  }

  @override
  Widget build(BuildContext context) {
    final settings = AppSettingsController.instance;

    return AnimatedBuilder(
      animation: settings,
      builder: (context, child) {
        return AppTabScaffold(
          currentRoute: AppRoutes.settings,
          useTopSafeArea: false,
          child: Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: AppColors.pageBackgroundGradient,
                    ),
                  ),
                ),
              ),
              Column(
                children: [
                  AppHeader(
                    title: 'SYNTIC',
                    useTopInset: true,
                    topPadding: 14,
                    horizontalPadding: 14,
                    bottomPadding: 14,
                    backgroundColor: AppColors.headerBackground.withValues(
                      alpha: 0.76,
                    ),
                    titleColor: AppColors.textPrimary,
                    fontSize: 18,
                    letterSpacing: 2.6,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SettingsProfileCard(
                            name: 'Hassan Raza',
                            status: settings.cloudHistoryEnabled
                                ? 'PRO MEMBER • CLOUD SYNC READY'
                                : 'PRO MEMBER • LOCAL MODE',
                          ),
                          const SizedBox(height: 24),
                          const SettingsSectionLabel(
                            label: 'Display Aesthetics',
                          ),
                          const SizedBox(height: 14),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _themePresets.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 14,
                                  mainAxisSpacing: 14,
                                  childAspectRatio: 0.88,
                                ),
                            itemBuilder: (context, index) {
                              final preset = _themePresets[index];
                              return SettingsThemeCard(
                                preset: preset,
                                isSelected:
                                    preset.id == settings.selectedThemeId,
                                onTap: () => _setTheme(preset.id),
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          const SettingsSectionLabel(label: 'System Response'),
                          const SizedBox(height: 14),
                          for (final option in _responseOptions) ...[
                            SettingsResponseTile(
                              title: option.title,
                              subtitle: option.subtitle,
                              icon: option.icon,
                              accentColor: option.accentColor,
                              value: _optionValue(settings, option),
                              onChanged: (value) =>
                                  _setResponseOption(context, option.id, value),
                            ),
                            if (option != _responseOptions.last)
                              const SizedBox(height: 12),
                          ],
                          const SizedBox(height: 24),
                          SettingsActionButton(
                            buttonKey: const Key('settings_wipe_button'),
                            label: 'Wipe Local Database',
                            icon: Icons.delete_outline_rounded,
                            onPressed: () => _confirmWipeLocalDatabase(context),
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: Text(
                              'VERSION 1.0.0+1 • BUILT FOR PRECISION',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.textSecondary.withValues(
                                  alpha: 0.42,
                                ),
                                fontSize: 8.4,
                                letterSpacing: 1.1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  bool _optionValue(
    AppSettingsController settings,
    SettingsResponseOption option,
  ) {
    switch (option.id) {
      case 'tactile_haptics':
        return settings.hapticsEnabled;
      case 'interface_audio':
        return settings.interfaceAudioEnabled;
      case 'cloud_history':
        return settings.cloudHistoryEnabled;
      default:
        return option.initialValue;
    }
  }
}

final List<SettingsThemePreset> _themePresets = [
  const SettingsThemePreset(
    id: 'dark_glass',
    title: 'Dark Glass',
    icon: Icons.nightlight_round,
    accentColor: Color(0xFF08D8FF),
    previewStartColor: Color(0xFF10161F),
    previewEndColor: Color(0xFF16262A),
  ),
  const SettingsThemePreset(
    id: 'light_minimal',
    title: 'Light Minimal',
    icon: Icons.light_mode_outlined,
    accentColor: Color(0xFF8E919B),
    previewStartColor: Color(0xFF4D4857),
    previewEndColor: Color(0xFF3E3A49),
  ),
  const SettingsThemePreset(
    id: 'neon_blue',
    title: 'Neon Blue',
    icon: Icons.bolt_rounded,
    accentColor: Color(0xFF22F0FF),
    previewStartColor: Color(0xFF164B59),
    previewEndColor: Color(0xFF1B7181),
  ),
  const SettingsThemePreset(
    id: 'purple_glow',
    title: 'Purple Glow',
    icon: Icons.auto_awesome_rounded,
    accentColor: Color(0xFFD9A0FF),
    previewStartColor: Color(0xFF4D2B69),
    previewEndColor: Color(0xFF6D3C91),
  ),
];

final List<SettingsResponseOption> _responseOptions = [
  const SettingsResponseOption(
    id: 'tactile_haptics',
    title: 'Tactile Haptics',
    subtitle: 'ENABLE VIBRATION ON INPUT',
    icon: Icons.volume_up_rounded,
    accentColor: Color(0xFF08D8FF),
  ),
  const SettingsResponseOption(
    id: 'interface_audio',
    title: 'Interface Audio',
    subtitle: 'ATMOSPHERIC UI SOUNDS',
    icon: Icons.graphic_eq_rounded,
    accentColor: Color(0xFFE49BFF),
  ),
  const SettingsResponseOption(
    id: 'cloud_history',
    title: 'Cloud History',
    subtitle: 'SECURE RESULT ARCHIVING',
    icon: Icons.history_toggle_off_rounded,
    accentColor: Color(0xFFD0B7FF),
  ),
];
