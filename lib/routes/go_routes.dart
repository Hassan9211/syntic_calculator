import 'package:go_router/go_router.dart';
import 'package:syntic_calculator/history_screen.dart';
import 'package:syntic_calculator/home_screen.dart';
import 'package:syntic_calculator/lab_screen.dart';
import 'package:syntic_calculator/routes/route_paths.dart';
import 'package:syntic_calculator/settings_screen.dart';
import 'package:syntic_calculator/splash.dart';

/// Yeh router har route ko uski related screen ke sath map karta hai.
final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.calculator,
      name: 'calculator',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.history,
      name: 'history',
      builder: (context, state) => const HistoryScreen(),
    ),
    GoRoute(
      path: AppRoutes.lab,
      name: 'lab',
      builder: (context, state) => const LabScreen(),
    ),
    GoRoute(
      path: AppRoutes.settings,
      name: 'settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);
