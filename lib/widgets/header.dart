import 'package:flutter/material.dart';
import 'package:syntic_calculator/app_colors.dart';

/// Shared branded header for app screens.
class AppHeader extends StatelessWidget {
  const AppHeader({
    super.key,
    required this.title,
    this.useTopInset = false,
    this.topPadding = 14,
    this.horizontalPadding = 14,
    this.bottomPadding = 14,
    this.backgroundColor,
    this.titleColor,
    this.fontSize = 18,
    this.fontWeight = FontWeight.w700,
    this.letterSpacing = 2.6,
    this.alignment = Alignment.centerLeft,
  });

  final String title;
  final bool useTopInset;
  final double topPadding;
  final double horizontalPadding;
  final double bottomPadding;
  final Color? backgroundColor;
  final Color? titleColor;
  final double fontSize;
  final FontWeight fontWeight;
  final double letterSpacing;
  final AlignmentGeometry alignment;

  EdgeInsetsGeometry _resolvedPadding(BuildContext context) {
    final topInset = useTopInset ? MediaQuery.paddingOf(context).top : 0.0;
    return EdgeInsets.fromLTRB(
      horizontalPadding,
      topInset + topPadding,
      horizontalPadding,
      bottomPadding,
    );
  }

  @override
  Widget build(BuildContext context) {
    final padding = _resolvedPadding(context);
    final titleWidget = Text(
      title,
      style: TextStyle(
        color: titleColor ?? AppColors.textPrimary,
        fontSize: fontSize,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
      ),
    );
    final content = Align(alignment: alignment, child: titleWidget);

    if (backgroundColor == null) {
      return Padding(padding: padding, child: content);
    }

    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(color: backgroundColor),
      child: content,
    );
  }
}
