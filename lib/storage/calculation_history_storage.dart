import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Ek single save hui history row ka model.
class CalculationHistoryItem {
  const CalculationHistoryItem({
    required this.expression,
    required this.result,
    required this.createdAt,
  });

  /// SharedPreferences se aayi JSON string ko object me convert karta hai.
  factory CalculationHistoryItem.fromJson(String source) {
    final map = jsonDecode(source) as Map<String, dynamic>;

    return CalculationHistoryItem(
      expression: map['expression'] as String? ?? '0',
      result: map['result'] as String? ?? '0',
      createdAt:
          DateTime.tryParse(map['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  final String expression;
  final String result;
  final DateTime createdAt;

  /// Do rows ko compare karke exactly wahi saved record identify karta hai.
  bool matches(CalculationHistoryItem other) {
    return expression == other.expression &&
        result == other.result &&
        createdAt.microsecondsSinceEpoch ==
            other.createdAt.microsecondsSinceEpoch;
  }

  /// Object ko compact JSON string me badal deta hai.
  String toJson() {
    return jsonEncode({
      'expression': expression,
      'result': result,
      'createdAt': createdAt.toIso8601String(),
    });
  }
}

/// Calculator history ko local storage me save, load aur clear karta hai.
class CalculationHistoryStorage {
  const CalculationHistoryStorage._();

  static const String _historyKey = 'calculation_history';
  static const int _maxItems = 40;

  // History ko halka rakhnay ke liye prefs me compact JSON rows save ki jati hain.
  static Future<List<CalculationHistoryItem>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final rawItems = prefs.getStringList(_historyKey) ?? const [];
    final items = <CalculationHistoryItem>[];

    for (final rawItem in rawItems) {
      try {
        items.add(CalculationHistoryItem.fromJson(rawItem));
      } catch (_) {
        // Agar koi row ghalat ho to usay ignore kar do taake poori history break na ho.
      }
    }

    items.sort((left, right) => right.createdAt.compareTo(left.createdAt));
    return items;
  }

  /// Nayi completed calculation ko list ke bilkul upar save karta hai.
  static Future<void> save({
    required String expression,
    required String result,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final existingItems = prefs.getStringList(_historyKey) ?? const [];
    final updatedItems = [
      CalculationHistoryItem(
        expression: expression,
        result: result,
        createdAt: DateTime.now(),
      ).toJson(),
      ...existingItems,
    ];

    if (updatedItems.length > _maxItems) {
      updatedItems.removeRange(_maxItems, updatedItems.length);
    }

    await prefs.setStringList(_historyKey, updatedItems);
  }

  /// Puri saved history ko remove kar deta hai.
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }

  /// Ek single saved history item ko list me se remove kar deta hai.
  static Future<void> delete(CalculationHistoryItem target) async {
    final prefs = await SharedPreferences.getInstance();
    final existingItems = prefs.getStringList(_historyKey) ?? const [];
    final updatedItems = <String>[];
    var removed = false;

    for (final rawItem in existingItems) {
      if (!removed) {
        try {
          final item = CalculationHistoryItem.fromJson(rawItem);
          if (item.matches(target)) {
            removed = true;
            continue;
          }
        } catch (_) {
          // Agar koi row parse na ho to usay jaisa hai waisa hi preserve rakho.
        }
      }

      updatedItems.add(rawItem);
    }

    if (updatedItems.isEmpty) {
      await prefs.remove(_historyKey);
      return;
    }

    await prefs.setStringList(_historyKey, updatedItems);
  }
}
