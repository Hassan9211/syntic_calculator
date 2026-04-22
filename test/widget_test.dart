import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syntic_calculator/history_screen.dart';
import 'package:syntic_calculator/home_screen.dart';
import 'package:syntic_calculator/lab_screen.dart';
import 'package:syntic_calculator/main.dart';
import 'package:syntic_calculator/settings_screen.dart';
import 'package:syntic_calculator/storage/calculation_history_storage.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Syntic splash screen renders brand content', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('SYNTIC'), findsOneWidget);
    expect(find.text('CALCULATOR'), findsOneWidget);
    expect(find.text('Smart Calculation Experience'), findsOneWidget);
  });

  testWidgets('Splash screen navigates to home after 3 seconds', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('EXPRESSION'), findsOneWidget);
    expect(find.byKey(const Key('calculator_display')), findsOneWidget);
  });

  testWidgets('Bottom navigation opens the history screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.history_rounded));
    await tester.pumpAndSettle();

    expect(find.text('History'), findsOneWidget);
    expect(find.text('COMPUTE LOG'), findsOneWidget);
    expect(find.text('No calculations yet'), findsOneWidget);
  });

  testWidgets('Main calculator performs multiply calculations', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    await _tapKey(tester, '2');
    await _tapKey(tester, '4');
    await _tapKey(tester, '5');
    await _tapKey(tester, '0');
    await _tapKey(tester, 'multiply');
    await _tapKey(tester, '1');
    await _tapKey(tester, 'decimal');
    await _tapKey(tester, '1');
    await _tapKey(tester, '5');
    await _tapKey(tester, 'equals');

    expect(_displayText(tester), '2,817.5');
    expect(find.text('2,450 x 1.15'), findsOneWidget);
  });

  testWidgets('Completed calculations are saved to history', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    await _tapKey(tester, '2');
    await _tapKey(tester, '4');
    await _tapKey(tester, '5');
    await _tapKey(tester, '0');
    await _tapKey(tester, 'multiply');
    await _tapKey(tester, '1');
    await _tapKey(tester, 'decimal');
    await _tapKey(tester, '1');
    await _tapKey(tester, '5');
    await _tapKey(tester, 'equals');
    await tester.pumpAndSettle();

    await tester.pumpWidget(const MaterialApp(home: HistoryScreen()));
    await tester.pumpAndSettle();

    expect(find.text('2,450 x 1.15'), findsOneWidget);
    expect(find.text('2,817.5'), findsOneWidget);
  });

  testWidgets('Main calculator supports sign and percent actions', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    await _tapKey(tester, '9');
    await _tapKey(tester, 'sign');
    expect(_displayText(tester), '-9');

    await _tapKey(tester, 'percent');
    expect(_displayText(tester), '-0.09');

    await _tapKey(tester, 'ac');
    expect(_displayText(tester), '0');
  });

  testWidgets('Scientific calculator keeps consecutive digits in one number', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: LabScreen()));

    await _tapLabKey(tester, '2');
    await _tapLabKey(tester, '2');
    await _tapLabKey(tester, '3');
    await _tapLabKey(tester, '4');

    expect(find.text('2234'), findsOneWidget);
    expect(find.text('2 x 2 x 3 x 4'), findsNothing);
    expect(find.text('2,234'), findsOneWidget);
  });

  testWidgets(
    'Scientific calculator still applies implicit multiply after pi',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LabScreen()));

      await _tapLabKey(tester, 'pi');
      await _tapLabKey(tester, '2');
      await _tapLabKey(tester, 'equals');

      expect(find.text('pi x 2'), findsOneWidget);
      expect(find.text('6.2831853072'), findsOneWidget);
    },
  );

  testWidgets('Settings screen renders the new control sections', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SettingsScreen()));

    expect(find.text('DISPLAY AESTHETICS'), findsOneWidget);
    expect(find.text('SYSTEM RESPONSE'), findsOneWidget);
    expect(find.text('Tactile Haptics'), findsOneWidget);
    expect(find.text('Wipe Local Database'), findsOneWidget);
  });

  testWidgets('Settings screen wipe action clears saved history', (
    WidgetTester tester,
  ) async {
    await CalculationHistoryStorage.save(expression: '2 + 2', result: '4');
    expect(await CalculationHistoryStorage.load(), isNotEmpty);

    await tester.pumpWidget(const MaterialApp(home: SettingsScreen()));
    final wipeButton = find.byKey(const Key('settings_wipe_button'));
    await tester.ensureVisible(wipeButton);
    await tester.pumpAndSettle();
    await tester.tap(wipeButton);
    await tester.pumpAndSettle();

    expect(await CalculationHistoryStorage.load(), isEmpty);
    expect(find.text('Local calculation history wiped.'), findsOneWidget);
  });
}

Future<void> _tapKey(WidgetTester tester, String id) async {
  final finder = find.byKey(Key('calculator_key_$id'));
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pump();
}

Future<void> _tapLabKey(WidgetTester tester, String id) async {
  final finder = find.byKey(Key('lab_key_$id'));
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pump();
}

String? _displayText(WidgetTester tester) {
  final textWidget = tester.widget<Text>(
    find.byKey(const Key('calculator_display')),
  );
  return textWidget.data;
}
