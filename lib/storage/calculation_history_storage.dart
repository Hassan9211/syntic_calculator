import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:syntic_calculator/settings/app_settings_controller.dart';

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
  static const String _cloudArchiveKey = 'calculation_history_cloud_archive';
  static const int _maxItems = 40;

  // History ko halka rakhnay ke liye prefs me compact JSON rows save ki jati hain.
  static Future<List<CalculationHistoryItem>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final rawItems = prefs.getStringList(_historyKey) ?? const [];
    return _decodeItems(rawItems);
  }

  /// Agar cloud archive on ho aur local history empty ho to usay restore kar deta hai.
  static Future<void> restoreFromCloudArchiveIfEnabled() async {
    if (!AppSettingsController.instance.cloudHistoryEnabled) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final localItems = prefs.getStringList(_historyKey) ?? const [];
    if (localItems.isNotEmpty) {
      return;
    }

    final cloudItems = prefs.getStringList(_cloudArchiveKey) ?? const [];
    if (cloudItems.isEmpty) {
      return;
    }

    await prefs.setStringList(_historyKey, cloudItems);
  }

  /// Current local history ko cloud archive key me mirror kar deta hai.
  static Future<void> syncCloudArchiveFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final localItems = prefs.getStringList(_historyKey) ?? const [];

    if (localItems.isEmpty) {
      return;
    }

    await prefs.setStringList(_cloudArchiveKey, localItems);
  }

  static List<CalculationHistoryItem> _decodeItems(List<String> rawItems) {
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
    final nextItem = CalculationHistoryItem(
      expression: expression,
      result: result,
      createdAt: DateTime.now(),
    ).toJson();
    final updatedItems = _trimmedItems([
      nextItem,
      ...existingItems,
    ]);

    await prefs.setStringList(_historyKey, updatedItems);

    if (AppSettingsController.instance.cloudHistoryEnabled) {
      final cloudItems = prefs.getStringList(_cloudArchiveKey) ?? const [];
      final updatedCloudItems = _trimmedItems([nextItem, ...cloudItems]);
      await prefs.setStringList(_cloudArchiveKey, updatedCloudItems);
    }
  }

  /// Sirf device par rakhi hui local history ko remove karta hai.
  static Future<void> clearLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }

  /// Local aur archived dono history layers ko clear kar deta hai.
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
    await prefs.remove(_cloudArchiveKey);
  }

  /// Backward compatibility ke liye local clear ko preserve rakhta hai.
  static Future<void> clear() => clearLocal();

  /// Ek single saved history item ko list me se remove kar deta hai.
  static Future<void> delete(CalculationHistoryItem target) async {
    final prefs = await SharedPreferences.getInstance();
    await _deleteFromKey(prefs, _historyKey, target);
    await _deleteFromKey(prefs, _cloudArchiveKey, target);
  }

  static List<String> _trimmedItems(List<String> items) {
    final updatedItems = List<String>.from(items);
    if (updatedItems.length > _maxItems) {
      updatedItems.removeRange(_maxItems, updatedItems.length);
    }
    return updatedItems;
  }

  static Future<void> _deleteFromKey(
    SharedPreferences prefs,
    String key,
    CalculationHistoryItem target,
  ) async {
    final existingItems = prefs.getStringList(key) ?? const [];
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
      await prefs.remove(key);
      return;
    }

    await prefs.setStringList(key, updatedItems);
  }
}
