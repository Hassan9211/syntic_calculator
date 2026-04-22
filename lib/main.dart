import 'package:flutter/material.dart';
import 'package:syntic_calculator/app_colors.dart';
import 'package:syntic_calculator/routes/go_routes.dart';

/// Flutter app yahan se start hoti hai.
void main() {
  runApp(const MyApp());
}

/// Root widget jo router aur global theme ko setup karta hai.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Theme aur router ko yahin rakha gaya hai taake screens sirf UI par focus karein.
    return MaterialApp.router(
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      title: 'Syntic Calculator',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          surface: AppColors.surface,
        ),
      ),
    );
  }
}
