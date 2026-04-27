import 'package:flutter/material.dart';
import 'package:syntic_calculator/app_colors.dart';
import 'package:syntic_calculator/enums/calculator_key_tone.dart';
import 'package:syntic_calculator/widgets/calculator_key_surface.dart';

/// Scientific keypad ki ek key ki display aur config values ko rakhta hai.
class LabButtonData {
  const LabButtonData({
    required this.id,
    required this.label,
    this.tone = CalculatorKeyTone.number,
    this.flex = 1,
    this.icon,
  });

  final String id;
  final String label;
  final CalculatorKeyTone tone;
  final int flex;
  final IconData? icon;
}

/// Yeh reusable widget Lab screen ki har scientific key ke liye use hota hai.
class LabButton extends StatelessWidget {
  const LabButton({super.key, required this.data, required this.onPressed});

  final LabButtonData data;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final isOperator = data.tone == CalculatorKeyTone.operator;
    final isEqual = data.tone == CalculatorKeyTone.equal;
    final isDelete = data.tone == CalculatorKeyTone.delete;

    // Surface ko same structure me rakha gaya hai, but special colors wapas restore kiye gaye hain.
    final borderColor = AppColors.borderSubtle;

    final backgroundGradient = isEqual
        ? LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primary, AppColors.primaryDark],
          )
        : isDelete
        ? LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.deleteButtonStart, AppColors.deleteButtonEnd],
          )
        : LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.buttonDark.withValues(alpha: 0.98),
              AppColors.buttonSecondary.withValues(alpha: 0.98),
            ],
          );

    final textColor = isEqual
        ? AppColors.equalForeground
        : isDelete
        ? AppColors.textPrimary.withValues(alpha: 0.95)
        : AppColors.textPrimary.withValues(alpha: 0.82);

    final child = data.icon == null
        ? Text(
            data.label,
            style: TextStyle(
              color: isOperator
                  ? AppColors.textPrimary.withValues(alpha: 0.90)
                  : textColor,
              fontSize: data.tone == CalculatorKeyTone.function ? 11 : 23,
              fontWeight: FontWeight.w600,
              letterSpacing: data.tone == CalculatorKeyTone.function ? 0.3 : 0,
            ),
          )
        : Icon(data.icon, color: textColor, size: 18);

    return CalculatorKeySurface(
      key: Key('lab_key_${data.id}'),
      onPressed: onPressed,
      borderRadius: 24,
      gradient: backgroundGradient,
      borderColor: borderColor,
      boxShadow: null,
      child: child,
    );
  }
}
