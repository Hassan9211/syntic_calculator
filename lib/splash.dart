import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:syntic_calculator/app_colors.dart';
import 'package:syntic_calculator/routes/route_paths.dart';
import 'package:syntic_calculator/widgets/header.dart';

/// Shuruati splash screen jo chhoti loading animation ke baad calculator kholti hai.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    // Ek hi animation timeline loading bar aur screen transition dono ko chalati hai.
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _startSplash();
  }

  /// Progress poori hone ke baad calculator screen par le jata hai.
  Future<void> _startSplash() async {
    await _progressController.forward();

    if (!mounted) {
      return;
    }

    context.go(AppRoutes.calculator);
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.splashGradient,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              // Centered max width wide screens par splash ko balanced rakhti hai.
              constraints: const BoxConstraints(maxWidth: 320),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: AppColors.surface.withValues(alpha: 0.28),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: AppColors.textPrimary.withValues(alpha: 0.08),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.18),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.calculate_rounded,
                      size: 50,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const AppHeader(
                    title: 'SYNTIC',
                    useTopInset: false,
                    topPadding: 0,
                    horizontalPadding: 0,
                    bottomPadding: 0,
                    alignment: Alignment.center,
                    titleColor: AppColors.textPrimary,
                    fontSize: 30,
                    letterSpacing: 6,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'CALCULATOR',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Smart Calculation Experience',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 28),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: AnimatedBuilder(
                      animation: _progressController,
                      builder: (context, child) {
                        return LinearProgressIndicator(
                          minHeight: 4,
                          value: _progressController.value,
                          backgroundColor: AppColors.progressTrack,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primary,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
