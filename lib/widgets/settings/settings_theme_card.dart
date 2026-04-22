import 'package:flutter/material.dart';
import 'package:syntic_calculator/app_colors.dart';
import 'package:syntic_calculator/settings/settings_models.dart';

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
        color: const Color(0xFF22212B),
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
          onTap: onTap,
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
