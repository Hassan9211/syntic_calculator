import 'dart:async';

import 'package:flutter/material.dart';
import 'package:syntic_calculator/services/app_interaction_feedback.dart';

/// Shared tappable shell jo basic aur scientific dono calculator keys ka common structure deta hai.
class CalculatorKeySurface extends StatefulWidget {
  const CalculatorKeySurface({
    super.key,
    required this.child,
    required this.onPressed,
    this.buttonKey,
    this.borderRadius = 22,
    this.backgroundColor,
    this.gradient,
    this.borderColor,
    this.boxShadow,
  });

  final Widget child;
  final VoidCallback onPressed;
  final Key? buttonKey;
  final double borderRadius;
  final Color? backgroundColor;
  final Gradient? gradient;
  final Color? borderColor;
  final List<BoxShadow>? boxShadow;

  @override
  State<CalculatorKeySurface> createState() => _CalculatorKeySurfaceState();
}

class _CalculatorKeySurfaceState extends State<CalculatorKeySurface> {
  static const Duration _pressAnimationDuration = Duration(milliseconds: 110);
  bool _isPressed = false;

  void _setPressed(bool value) {
    if (_isPressed == value) {
      return;
    }

    setState(() {
      _isPressed = value;
    });
  }

  void _handleTap() {
    unawaited(AppInteractionFeedback.playTap());
    widget.onPressed();
  }

  List<BoxShadow>? _resolvedShadows() {
    final shadows = widget.boxShadow;
    if (!_isPressed || shadows == null) {
      return shadows;
    }

    return shadows
        .map(
          (shadow) => BoxShadow(
            color: shadow.color,
            blurRadius: shadow.blurRadius * 0.62,
            spreadRadius: shadow.spreadRadius * 0.4,
            offset: Offset(shadow.offset.dx * 0.35, shadow.offset.dy * 0.35),
            blurStyle: shadow.blurStyle,
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(widget.borderRadius);

    return AnimatedScale(
      scale: _isPressed ? 0.96 : 1,
      duration: _pressAnimationDuration,
      curve: Curves.easeOutCubic,
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            color: widget.gradient == null ? widget.backgroundColor : null,
            gradient: widget.gradient,
            border: widget.borderColor == null
                ? null
                : Border.all(color: widget.borderColor!),
            boxShadow: _resolvedShadows(),
          ),
          child: InkWell(
            key: widget.buttonKey,
            onTap: _handleTap,
            onTapDown: (_) => _setPressed(true),
            onTapUp: (_) => _setPressed(false),
            onTapCancel: () => _setPressed(false),
            borderRadius: borderRadius,
            splashColor: Colors.white.withValues(alpha: 0.08),
            highlightColor: Colors.white.withValues(alpha: 0.03),
            overlayColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.pressed)) {
                return Colors.white.withValues(alpha: 0.06);
              }
              if (states.contains(WidgetState.hovered)) {
                return Colors.white.withValues(alpha: 0.02);
              }
              return null;
            }),
            child: Center(child: widget.child),
          ),
        ),
      ),
    );
  }
}
