import 'package:flutter/material.dart';
import 'package:syntic_calculator/app_colors.dart';
import 'package:syntic_calculator/routes/route_paths.dart';
import 'package:syntic_calculator/settings/settings_models.dart';
import 'package:syntic_calculator/storage/calculation_history_storage.dart';
import 'package:syntic_calculator/widgets/bottom_buttons.dart';
import 'package:syntic_calculator/widgets/settings/settings_action_button.dart';
import 'package:syntic_calculator/widgets/settings/settings_header.dart';
import 'package:syntic_calculator/widgets/settings/settings_profile_card.dart';
import 'package:syntic_calculator/widgets/settings/settings_response_tile.dart';
import 'package:syntic_calculator/widgets/settings/settings_section_label.dart';
import 'package:syntic_calculator/widgets/settings/settings_theme_card.dart';

/// Settings tab jo app ke appearance aur feedback controls dikhata hai.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedPresetId = _themePresets.first.id;
  late final Map<String, bool> _responseStates = {
    for (final option in _responseOptions) option.id: option.initialValue,
  };

  void _selectPreset(String presetId) {
    setState(() {
      _selectedPresetId = presetId;
    });
  }

  void _toggleResponse(String optionId, bool value) {
    setState(() {
      _responseStates[optionId] = value;
    });
  }

  Future<void> _wipeLocalDatabase() async {
    await CalculationHistoryStorage.clear();

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Local calculation history wiped.'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
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
                  colors: [
                    const Color(0xFF17161F),
                    const Color(0xFF13131A),
                  ],
                ),
              ),
            ),
          ),
          Column(
            children: [
              const SettingsHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SettingsProfileCard(
                        name: 'Hassan Raza',
                        status: 'PRO MEMBER • SYNC ACTIVE',
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
                            isSelected: preset.id == _selectedPresetId,
                            onTap: () => _selectPreset(preset.id),
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
                          value:
                              _responseStates[option.id] ?? option.initialValue,
                          onChanged: (value) =>
                              _toggleResponse(option.id, value),
                        ),
                        if (option != _responseOptions.last)
                          const SizedBox(height: 12),
                      ],
                      const SizedBox(height: 24),
                      SettingsActionButton(
                        buttonKey: const Key('settings_wipe_button'),
                        label: 'Wipe Local Database',
                        icon: Icons.delete_outline_rounded,
                        onPressed: _wipeLocalDatabase,
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
  }
}

const List<SettingsThemePreset> _themePresets = [
  SettingsThemePreset(
    id: 'dark_glass',
    title: 'Dark Glass',
    icon: Icons.nightlight_round,
    accentColor: AppColors.primary,
    previewStartColor: Color(0xFF10161F),
    previewEndColor: Color(0xFF16262A),
  ),
  SettingsThemePreset(
    id: 'light_minimal',
    title: 'Light Minimal',
    icon: Icons.light_mode_outlined,
    accentColor: Color(0xFF8E919B),
    previewStartColor: Color(0xFF4D4857),
    previewEndColor: Color(0xFF3E3A49),
  ),
  SettingsThemePreset(
    id: 'neon_blue',
    title: 'Neon Blue',
    icon: Icons.bolt_rounded,
    accentColor: Color(0xFF22F0FF),
    previewStartColor: Color(0xFF164B59),
    previewEndColor: Color(0xFF1B7181),
  ),
  SettingsThemePreset(
    id: 'purple_glow',
    title: 'Purple Glow',
    icon: Icons.auto_awesome_rounded,
    accentColor: Color(0xFFD9A0FF),
    previewStartColor: Color(0xFF4D2B69),
    previewEndColor: Color(0xFF6D3C91),
  ),
];

const List<SettingsResponseOption> _responseOptions = [
  SettingsResponseOption(
    id: 'tactile_haptics',
    title: 'Tactile Haptics',
    subtitle: 'ENABLE VIBRATION ON INPUT',
    icon: Icons.volume_up_rounded,
    accentColor: AppColors.primary,
  ),
  SettingsResponseOption(
    id: 'interface_audio',
    title: 'Interface Audio',
    subtitle: 'ATMOSPHERIC UI SOUNDS',
    icon: Icons.graphic_eq_rounded,
    accentColor: Color(0xFFE49BFF),
  ),
  SettingsResponseOption(
    id: 'cloud_history',
    title: 'Cloud History',
    subtitle: 'SECURE RESULT ARCHIVING',
    icon: Icons.history_toggle_off_rounded,
    accentColor: Color(0xFFD0B7FF),
  ),
];
