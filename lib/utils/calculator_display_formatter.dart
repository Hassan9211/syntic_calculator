/// Shared number formatting helpers jo basic aur scientific dono calculators use karte hain.
class CalculatorDisplayFormatter {
  const CalculatorDisplayFormatter._();

  /// Floating point result se extra trailing zeros hata deta hai.
  static String normalizeNumber(
    double value, {
    int fractionDigits = 10,
  }) {
    final normalized = value
        .toStringAsFixed(fractionDigits)
        .replaceFirst(RegExp(r'\.?0+$'), '');
    return normalized == '-0' || normalized.isEmpty ? '0' : normalized;
  }

  /// Raw double ko display ke liye tayar format me convert karta hai.
  static String formatNumber(
    double value, {
    int fractionDigits = 10,
  }) {
    return formatDisplay(
      normalizeNumber(value, fractionDigits: fractionDigits),
    );
  }

  /// Number string ko commas aur decimals ke sath readable banata hai.
  static String formatDisplay(String value) {
    final isNegative = value.startsWith('-');
    final safeValue = isNegative ? value.substring(1) : value;
    final parts = safeValue.split('.');
    final wholePart = parts.first.isEmpty ? '0' : parts.first;
    final formattedWhole = _addCommas(wholePart);
    final decimalPart = parts.length > 1 ? '.${parts[1]}' : '';
    return '${isNegative ? '-' : ''}$formattedWhole$decimalPart';
  }

  /// Scientific mode ke liye bohat choti ya bohat bari values ko compact format me dikhata hai.
  static String formatAdaptiveResult(
    double value, {
    int fractionDigits = 10,
    double scientificUpperBound = 10000000000,
    double scientificLowerBound = 0.000001,
    int exponentialDigits = 6,
  }) {
    final absValue = value.abs();
    if (absValue >= scientificUpperBound ||
        (absValue > 0 && absValue < scientificLowerBound)) {
      return value.toStringAsExponential(exponentialDigits).toUpperCase();
    }
    return formatDisplay(
      normalizeNumber(value, fractionDigits: fractionDigits),
    );
  }

  /// Whole number part me thousands separators add karta hai.
  static String _addCommas(String digits) {
    final buffer = StringBuffer();

    for (var index = 0; index < digits.length; index++) {
      buffer.write(digits[index]);
      final remaining = digits.length - index - 1;
      if (remaining > 0 && remaining % 3 == 0) {
        buffer.write(',');
      }
    }

    return buffer.toString();
  }
}
