import 'dart:async';

import 'package:flutter/material.dart';
import 'package:syntic_calculator/app_colors.dart';
import 'package:syntic_calculator/enums/calculator_key_tone.dart';
import 'package:syntic_calculator/routes/route_paths.dart';
import 'package:syntic_calculator/storage/calculation_history_storage.dart';
import 'package:syntic_calculator/utils/calculator_display_formatter.dart';
import 'package:syntic_calculator/widgets/bottom_buttons.dart';
import 'package:syntic_calculator/widgets/calculator_button.dart';

/// Yeh main calculator screen hai.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const int _maxInputLength = 12;

  // Bari display par jo value nazar aati hai.
  String _currentInput = '0';
  // Pehla operand jo operator select hone ke baad temporary tor par store hota hai.
  double? _storedValue;
  // Filhal selected operator.
  String? _operator;
  // Agar yeh true ho to next digit naya input start karti hai.
  bool _shouldResetInput = false;
  // Upar wali expression line.
  String _expression = '0';
  // Aakhri completed answer jo hint ke tor par dikhaya jata hai.
  String _lastResult = '0';

  // Button handling ko ek jagah rakha gaya hai taake button widget simple rahe.
  void _onButtonPressed(String value) {
    switch (value) {
      case 'AC':
        _resetCalculator();
        return;
      case '+/-':
        _toggleSign();
        return;
      case '%':
        _applyPercent();
        return;
      case '/':
      case 'x':
      case '-':
      case '+':
        _setOperator(value);
        return;
      case '=':
        _calculate();
        return;
      case '.':
        _appendDecimal();
        return;
      default:
        _appendDigit(value);
        return;
    }
  }

  /// Calculator ko bilkul starting state par wapas le jata hai.
  void _resetCalculator() {
    setState(() {
      _currentInput = '0';
      _storedValue = null;
      _operator = null;
      _shouldResetInput = false;
      _expression = '0';
      _lastResult = '0';
    });
  }

  /// Naya digit current input me add karta hai aur max length ka khayal bhi rakhta hai.
  void _appendDigit(String digit) {
    setState(() {
      if (_shouldResetInput) {
        _currentInput = digit;
        _shouldResetInput = false;
        if (_operator == null) {
          _expression = '0';
        }
      } else if (_currentInput == '0') {
        _currentInput = digit;
      } else {
        final sanitized = _currentInput.replaceAll('-', '').replaceAll('.', '');
        if (sanitized.length >= _maxInputLength) {
          return;
        }
        _currentInput += digit;
      }
      _syncExpression();
    });
  }

  /// Decimal sirf ek dafa add hota hai aur reset state ko bhi sambhalta hai.
  void _appendDecimal() {
    setState(() {
      if (_shouldResetInput) {
        _currentInput = '0.';
        _shouldResetInput = false;
        if (_operator == null) {
          _expression = '0';
        }
      } else if (!_currentInput.contains('.')) {
        _currentInput += '.';
      }
      _syncExpression();
    });
  }

  /// Current input ka sign positive aur negative me toggle karta hai.
  void _toggleSign() {
    setState(() {
      if (_currentInput == '0') {
        return;
      }

      if (_currentInput.startsWith('-')) {
        _currentInput = _currentInput.substring(1);
      } else {
        _currentInput = '-$_currentInput';
      }
      _syncExpression();
    });
  }

  /// Current number ko percent value me convert karta hai.
  void _applyPercent() {
    setState(() {
      final value = _parseInput(_currentInput) / 100;
      _currentInput = _normalizeNumber(value);
      _syncExpression();
    });
  }

  /// Operator select karta hai aur zarurat par chained calculation bhi chala leta hai.
  void _setOperator(String nextOperator) {
    setState(() {
      final currentValue = _parseInput(_currentInput);

      if (_storedValue != null && _operator != null && !_shouldResetInput) {
        final result = _performOperation(
          _storedValue!,
          currentValue,
          _operator!,
        );
        if (result == null) {
          return;
        }
        _storedValue = result;
        _currentInput = _normalizeNumber(result);
        _lastResult = _formatDisplay(_currentInput);
      } else {
        _storedValue = currentValue;
      }

      _operator = nextOperator;
      _shouldResetInput = true;
      _expression = '${_formatNumber(_storedValue!)} $_operator';
    });
  }

  /// Pending operation ko complete karke display aur history dono update karta hai.
  void _calculate() {
    if (_storedValue == null || _operator == null || _shouldResetInput) {
      return;
    }

    final currentValue = _parseInput(_currentInput);
    final leftSide = _formatNumber(_storedValue!);
    final currentOperator = _operator!;
    final rightSide = _formatDisplay(_currentInput);
    final result = _performOperation(
      _storedValue!,
      currentValue,
      currentOperator,
    );
    if (result == null) {
      return;
    }

    final nextInput = _normalizeNumber(result);
    final historyExpression = '$leftSide $currentOperator $rightSide';
    final historyResult = _formatDisplay(nextInput);

    setState(() {
      _expression = historyExpression;
      _currentInput = nextInput;
      _lastResult = historyResult;
      _storedValue = null;
      _operator = null;
      _shouldResetInput = true;
    });

    // Sirf completed calculations save hoti hain taake history screen meaningful rahe.
    unawaited(
      CalculationHistoryStorage.save(
        expression: historyExpression,
        result: historyResult,
      ),
    );
  }

  /// Do numbers par selected operator apply karta hai.
  double? _performOperation(double left, double right, String operator) {
    switch (operator) {
      case '+':
        return left + right;
      case '-':
        return left - right;
      case 'x':
        return left * right;
      case '/':
        if (right == 0) {
          _showError();
          return null;
        }
        return left / right;
      default:
        return right;
    }
  }

  /// Divide-by-zero jaisi invalid situation me UI ko safe error state me rakhta hai.
  void _showError() {
    _currentInput = '0';
    _storedValue = null;
    _operator = null;
    _shouldResetInput = false;
    _expression = 'Cannot divide by zero';
  }

  /// Chhoti expression line ko current calculator state ke sath sync rakhta hai.
  void _syncExpression() {
    if (_storedValue != null && _operator != null) {
      final rightSide = _shouldResetInput
          ? ''
          : ' ${_formatDisplay(_currentInput)}';
      _expression = '${_formatNumber(_storedValue!)} $_operator$rightSide';
    } else if (!_shouldResetInput) {
      _expression = '0';
    }
  }

  /// Input string ko double me convert karta hai.
  double _parseInput(String input) => double.tryParse(input) ?? 0;

  /// Result me extra trailing zeros hata kar saaf numeric string banata hai.
  String _normalizeNumber(double value) {
    return CalculatorDisplayFormatter.normalizeNumber(value, fractionDigits: 8);
  }

  /// Raw double ko display ke liye tayar format me convert karta hai.
  String _formatNumber(double value) {
    return CalculatorDisplayFormatter.formatNumber(value, fractionDigits: 8);
  }

  /// Number string ko commas aur decimals ke sath asan padhne layak banata hai.
  String _formatDisplay(String value) =>
      CalculatorDisplayFormatter.formatDisplay(value);

  @override
  Widget build(BuildContext context) {
    final displayValue = _formatDisplay(_currentInput);

    return AppTabScaffold(
      currentRoute: AppRoutes.calculator,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'SYNTIC',
                style: TextStyle(
                  color: AppColors.textPrimary.withValues(alpha: 0.95),
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 3,
                ),
              ),
            ),
          ),
          Container(
            // Yeh display area current expression aur latest answer dono dikhata hai.
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0.85, -0.55),
                radius: 1.15,
                colors: [
                  AppColors.accentPurple.withValues(alpha: 0.20),
                  Colors.transparent,
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'EXPRESSION',
                  style: TextStyle(
                    color: AppColors.textSecondary.withValues(alpha: 0.85),
                    fontSize: 12,
                    letterSpacing: 1.4,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _expression,
                  key: const Key('calculator_expression'),
                  style: TextStyle(
                    color: AppColors.textSecondary.withValues(alpha: 0.85),
                    fontSize: 28,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    displayValue,
                    key: const Key('calculator_display'),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 64,
                      fontWeight: FontWeight.w700,
                      height: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(
                      Icons.history_toggle_off_rounded,
                      size: 14,
                      color: AppColors.textSecondary.withValues(alpha: 0.75),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'LAST RESULT, $_lastResult',
                      style: TextStyle(
                        color: AppColors.textSecondary.withValues(alpha: 0.75),
                        fontSize: 11,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Column(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        // Rows data se render hoti hain taake spacing aur styling ek jaisi rahe.
                        for (var index = 0; index < _buttonRows.length; index++)
                          _buildButtonRow(
                            _buttonRows[index],
                            isLast: index == _buttonRows.length - 1,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Button row ko common spacing aur equal sizing ke sath render karta hai.
  Widget _buildButtonRow(
    List<CalculatorButtonData> row, {
    bool isLast = false,
  }) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
        child: Row(
          children: row.map((button) {
            return Expanded(
              flex: button.flex,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: SizedBox.expand(
                  child: CalculatorButton(
                    data: button,
                    onPressed: () => _onButtonPressed(button.label),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// Calculator keypad ka layout data driven rakha gaya hai taake UI asani se change ho sake.
const List<List<CalculatorButtonData>> _buttonRows = [
  [
    CalculatorButtonData(
      id: 'ac',
      label: 'AC',
      tone: CalculatorKeyTone.secondary,
    ),
    CalculatorButtonData(
      id: 'sign',
      label: '+/-',
      tone: CalculatorKeyTone.secondary,
    ),
    CalculatorButtonData(
      id: 'percent',
      label: '%',
      tone: CalculatorKeyTone.secondary,
    ),
    CalculatorButtonData(
      id: 'divide',
      label: '/',
      tone: CalculatorKeyTone.operator,
    ),
  ],
  [
    CalculatorButtonData(id: '7', label: '7'),
    CalculatorButtonData(id: '8', label: '8'),
    CalculatorButtonData(id: '9', label: '9'),
    CalculatorButtonData(
      id: 'multiply',
      label: 'x',
      tone: CalculatorKeyTone.operator,
    ),
  ],
  [
    CalculatorButtonData(id: '4', label: '4'),
    CalculatorButtonData(id: '5', label: '5'),
    CalculatorButtonData(id: '6', label: '6'),
    CalculatorButtonData(
      id: 'subtract',
      label: '-',
      tone: CalculatorKeyTone.operator,
    ),
  ],
  [
    CalculatorButtonData(id: '1', label: '1'),
    CalculatorButtonData(id: '2', label: '2'),
    CalculatorButtonData(id: '3', label: '3'),
    CalculatorButtonData(
      id: 'add',
      label: '+',
      tone: CalculatorKeyTone.operator,
    ),
  ],
  [
    CalculatorButtonData(id: '0', label: '0', flex: 2),
    CalculatorButtonData(id: 'decimal', label: '.'),
    CalculatorButtonData(
      id: 'equals',
      label: '=',
      tone: CalculatorKeyTone.operator,
    ),
  ],
];
