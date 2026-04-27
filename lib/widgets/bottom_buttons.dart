import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:syntic_calculator/app_colors.dart';
import 'package:syntic_calculator/routes/route_paths.dart';
import 'package:syntic_calculator/services/app_interaction_feedback.dart';

/// Har main screen ko shared background aur bottom navigation ke sath wrap karta hai.
class AppTabScaffold extends StatelessWidget {
  const AppTabScaffold({
    super.key,
    required this.currentRoute,
    required this.child,
    this.useTopSafeArea = true,
  });

  final String currentRoute;
  final Widget child;
  final bool useTopSafeArea;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.calculatorPanelGradient,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: useTopSafeArea
                  ? SafeArea(bottom: false, child: child)
                  : child,
            ),
            // Bottom bar ko safe area milti rahe, lekin top content full-bleed bhi ho sakta hai.
            SafeArea(
              top: false,
              child: BottomButtons(currentRoute: currentRoute),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom navigation bar jo app ki main tabs switch karta hai.
class BottomButtons extends StatelessWidget {
  const BottomButtons({super.key, required this.currentRoute});

  final String currentRoute;

  static const List<_BottomButtonData> _items = [
    // Bottom bar data se chal rahi hai taake naye tabs add karna asan rahe.
    _BottomButtonData(
      route: AppRoutes.calculator,
      icon: Icons.calculate_rounded,
      label: 'CALC',
    ),
    _BottomButtonData(
      route: AppRoutes.history,
      icon: Icons.history_rounded,
      label: 'HISTORY',
    ),
    _BottomButtonData(
      route: AppRoutes.lab,
      icon: Icons.science_outlined,
      label: 'LAB',
    ),
    _BottomButtonData(
      route: AppRoutes.settings,
      icon: Icons.settings_outlined,
      label: 'SETTINGS',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            AppColors.primary.withValues(alpha: 0.10),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        children: [
          for (final item in _items)
            _BottomNavItem(
              icon: item.icon,
              label: item.label,
              isActive: currentRoute == item.route,
              onTap: currentRoute == item.route
                  ? null
                  : () {
                      unawaited(AppInteractionFeedback.playTap());
                      context.go(item.route);
                    },
            ),
        ],
      ),
    );
  }
}

/// Ek single bottom nav item ka look aur tap behavior handle karta hai.
class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final itemColor = isActive ? AppColors.primary : AppColors.navInactive;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Ink(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            decoration: isActive
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.22),
                        Colors.transparent,
                      ],
                    ),
                  )
                : null,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18, color: itemColor),
                const SizedBox(height: 5),
                Text(
                  label,
                  style: TextStyle(
                    color: itemColor,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.6,
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

/// Data object jo ek bottom tab ki route, icon aur label values rakhta hai.
class _BottomButtonData {
  const _BottomButtonData({
    required this.route,
    required this.icon,
    required this.label,
  });

  final String route;
  final IconData icon;
  final String label;
}
