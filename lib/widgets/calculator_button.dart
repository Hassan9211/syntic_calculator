import 'package:flutter/material.dart';
import 'package:syntic_calculator/app_colors.dart';
import 'package:syntic_calculator/enums/calculator_key_tone.dart';
import 'package:syntic_calculator/widgets/calculator_key_surface.dart';

/// Ek calculator key ki display aur config values ko rakhta hai.
class CalculatorButtonData {
  const CalculatorButtonData({
    required this.id,
    required this.label,
    this.tone = CalculatorKeyTone.number,
    this.flex = 1,
  });

  final String id;
  final String label;
  final CalculatorKeyTone tone;
  final int flex;
}

/// Yeh reusable calculator button widget har key ke liye use hota hai.
class CalculatorButton extends StatelessWidget {
  const CalculatorButton({
    super.key,
    required this.data,
    required this.onPressed,
  });

  final CalculatorButtonData data;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final isOperator = data.tone == CalculatorKeyTone.operator;
    // Operators ko bright gradient milta hai jab ke numbers simple dark style me rehte hain.
    final backgroundColor = data.tone == CalculatorKeyTone.secondary
        ? AppColors.buttonSecondary
        : AppColors.buttonDark;
    final textColor = isOperator ? AppColors.card : AppColors.textPrimary;

    return CalculatorKeySurface(
      buttonKey: Key('calculator_key_${data.id}'),
      onPressed: onPressed,
      backgroundColor: isOperator ? null : backgroundColor,
      gradient: isOperator
          ? const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: AppColors.operatorGradient,
            )
          : null,
      boxShadow: isOperator
          ? [
              BoxShadow(
                color: AppColors.accentPurple.withValues(alpha: 0.30),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ]
          : null,
      child: Text(
        data.label,
        style: TextStyle(
          color: textColor,
          fontSize: data.label.length > 2 ? 22 : 28,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
