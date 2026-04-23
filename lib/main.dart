import 'package:flutter/material.dart';
import 'package:syntic_calculator/routes/go_routes.dart';
import 'package:syntic_calculator/settings/app_settings_controller.dart';
import 'package:syntic_calculator/storage/calculation_history_storage.dart';

/// Flutter app yahan se start hoti hai.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppSettingsController.instance.load();
  await CalculationHistoryStorage.restoreFromCloudArchiveIfEnabled();
  runApp(const MyApp());
}

/// Root widget jo router aur global theme ko setup karta hai.
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AppSettingsController _settings = AppSettingsController.instance;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _settings,
      builder: (context, child) {
        // Theme aur router ko yahin rakha gaya hai taake screens sirf UI par focus karein.
        return MaterialApp.router(
          routerConfig: appRouter,
          debugShowCheckedModeBanner: false,
          title: 'Syntic Calculator',
          theme: _settings.buildTheme(),
        );
      },
    );
  }
}
