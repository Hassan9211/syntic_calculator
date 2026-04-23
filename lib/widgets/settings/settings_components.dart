import 'dart:async';

import 'package:flutter/material.dart';
import 'package:syntic_calculator/app_colors.dart';
import 'package:syntic_calculator/services/app_interaction_feedback.dart';
import 'package:syntic_calculator/settings/settings_models.dart';

/// User profile summary ko settings screen ke hero card me dikhata hai.
class SettingsProfileCard extends StatelessWidget {
  const SettingsProfileCard({
    super.key,
    required this.name,
    required this.status,
  });

  final String name;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 56,
            height: 56,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.65),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.20),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.profileAvatarStart,
                          AppColors.profileAvatarEnd,
                        ],
                      ),
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 2,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.card,
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.95),
                        width: 1.6,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.24),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      size: 11,
                      color: AppColors.primary.withValues(alpha: 0.98),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  status,
                  style: TextStyle(
                    color: AppColors.textSecondary.withValues(alpha: 0.75),
                    fontSize: 10,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Settings sections ke liye small uppercase heading dikhata hai.
class SettingsSectionLabel extends StatelessWidget {
  const SettingsSectionLabel({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        color: AppColors.primary.withValues(alpha: 0.92),
        fontSize: 10,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.8,
      ),
    );
  }
}

/// Display preset ko preview card ke taur par render karta hai.
class SettingsThemeCard extends StatelessWidget {
  const SettingsThemeCard({
    super.key,
    required this.preset,
    required this.isSelected,
    required this.onTap,
  });

  final SettingsThemePreset preset;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: AppColors.settingsCard,
        border: Border.all(
          color: isSelected
              ? preset.accentColor.withValues(alpha: 0.95)
              : Colors.white.withValues(alpha: 0.03),
        ),
        boxShadow: [
          if (isSelected)
            BoxShadow(
              color: preset.accentColor.withValues(alpha: 0.20),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            unawaited(AppInteractionFeedback.playTap());
            onTap();
          },
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 180),
                    opacity: isSelected ? 1 : 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: preset.accentColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          preset.previewStartColor,
                          preset.previewEndColor,
                        ],
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        preset.icon,
                        size: 24,
                        color: preset.accentColor.withValues(
                          alpha: isSelected ? 0.96 : 0.55,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  preset.title.toUpperCase(),
                  style: TextStyle(
                    color: isSelected
                        ? AppColors.textPrimary
                        : AppColors.textSecondary.withValues(alpha: 0.72),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.45,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Settings toggle row jo icon, copy aur switch ko ek compact surface me rakhta hai.
class SettingsResponseTile extends StatelessWidget {
  const SettingsResponseTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          unawaited(AppInteractionFeedback.playTap());
          onChanged(!value);
        },
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: AppColors.settingsTile.withValues(alpha: 0.98),
            border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accentColor.withValues(alpha: 0.14),
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: accentColor.withValues(alpha: 0.96),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: AppColors.textSecondary.withValues(alpha: 0.48),
                        fontSize: 8.8,
                        letterSpacing: 0.45,
                      ),
                    ),
                  ],
                ),
              ),
              Transform.scale(
                scale: 0.86,
                child: Switch(
                  value: value,
                  onChanged: (nextValue) {
                    unawaited(AppInteractionFeedback.playTap());
                    onChanged(nextValue);
                  },
                  activeThumbColor: Colors.white,
                  activeTrackColor: accentColor,
                  inactiveThumbColor: Colors.white.withValues(alpha: 0.80),
                  inactiveTrackColor: Colors.white.withValues(alpha: 0.16),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Destructive ya important action ko prominent pill button me dikhata hai.
class SettingsActionButton extends StatelessWidget {
  const SettingsActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.buttonKey,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final Key? buttonKey;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: buttonKey,
        onTap: () {
          unawaited(AppInteractionFeedback.playTap());
          onPressed();
        },
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                AppColors.actionStart.withValues(alpha: 0.72),
                AppColors.actionEnd.withValues(alpha: 0.88),
              ],
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: AppColors.actionIcon.withValues(alpha: 0.95),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: AppColors.actionText.withValues(alpha: 0.98),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
