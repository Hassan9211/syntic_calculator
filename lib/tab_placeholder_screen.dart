import 'package:flutter/material.dart';
import 'package:syntic_calculator/app_colors.dart';
import 'package:syntic_calculator/widgets/bottom_buttons.dart';
import 'package:syntic_calculator/widgets/header.dart';

class TabPlaceholderScreen extends StatelessWidget {
  const TabPlaceholderScreen({
    super.key,
    required this.currentRoute,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String currentRoute;
  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    // Jo tabs abhi poori tarah design nahi hui un ke liye yahi shared shell reuse hota hai.
    return AppTabScaffold(
      currentRoute: currentRoute,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        child: Column(
          children: [
            AppHeader(
              title: 'SYNTIC',
              useTopInset: false,
              topPadding: 0,
              horizontalPadding: 0,
              bottomPadding: 0,
              titleColor: AppColors.textPrimary.withValues(alpha: 0.95),
              fontSize: 24,
              letterSpacing: 3,
            ),
            const Spacer(),
            Container(
              // Shared card placeholder tabs ko visual tor par ek jaisa rakhta hai.
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.buttonDark,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: AppColors.borderSubtle),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 44, color: AppColors.primary),
                  const SizedBox(height: 18),
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
