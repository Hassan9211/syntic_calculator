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
  const LabButton({
    super.key,
    required this.data,
    required this.onPressed,
  });

  final LabButtonData data;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final isOperator = data.tone == CalculatorKeyTone.operator;
    final isEqual = data.tone == CalculatorKeyTone.equal;
    final isDelete = data.tone == CalculatorKeyTone.delete;

    // Equal aur delete keys ko baqi buttons se zyada visual emphasis milti hai.
    final borderColor = isEqual
        ? AppColors.primary.withValues(alpha: 0.35)
        : isDelete
            ? AppColors.accentPurple.withValues(alpha: 0.24)
            : AppColors.borderSubtle;

    final backgroundGradient = isEqual
        ? const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primary, AppColors.primaryDark],
          )
        : isDelete
            ? const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFD15FFF), Color(0xFFA73EF6)],
              )
            : LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF2B2833).withValues(alpha: 0.98),
                  const Color(0xFF1C1A24).withValues(alpha: 0.98),
                ],
              );

    final textColor = isEqual
        ? const Color(0xFF042A31)
        : AppColors.textPrimary.withValues(alpha: isDelete ? 0.95 : 0.82);

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
        : Icon(
            data.icon,
            color: textColor,
            size: 18,
          );

    return CalculatorKeySurface(
      buttonKey: Key('lab_key_${data.id}'),
      onPressed: onPressed,
      borderRadius: 24,
      gradient: backgroundGradient,
      borderColor: borderColor,
      boxShadow: isEqual
          ? [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.32),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ]
          : isDelete
              ? [
                  BoxShadow(
                    color: AppColors.accentPurple.withValues(alpha: 0.24),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
      child: child,
    );
  }
}
