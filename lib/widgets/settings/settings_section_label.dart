import 'package:flutter/material.dart';
import 'package:syntic_calculator/app_colors.dart';

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
