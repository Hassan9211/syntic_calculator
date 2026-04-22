import 'package:flutter/material.dart';
import 'package:syntic_calculator/app_colors.dart';

/// Settings screen ka compact branded top bar.
class SettingsHeader extends StatelessWidget {
  const SettingsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(14, topInset + 14, 14, 14),
      decoration: BoxDecoration(
        color: const Color(0xFF14131C).withValues(alpha: 0.76),
      ),
      child: Row(
        children: [
          const Text(
            'SYNTIC',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.6,
            ),
          ),
        ],
      ),
    );
  }
}
