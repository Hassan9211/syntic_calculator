import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:syntic_calculator/app_colors.dart';
import 'package:syntic_calculator/enums/calculator_key_tone.dart';
import 'package:syntic_calculator/routes/route_paths.dart';
import 'package:syntic_calculator/storage/calculation_history_storage.dart';
import 'package:syntic_calculator/utils/calculator_display_formatter.dart';
import 'package:syntic_calculator/widgets/bottom_buttons.dart';
import 'package:syntic_calculator/widgets/lab_button.dart';

/// Lab tab ke liye working scientific calculator screen dikhata hai.
class LabScreen extends StatefulWidget {
  const LabScreen({super.key});

  @override
  State<LabScreen> createState() => _LabScreenState();
}

class _LabScreenState extends State<LabScreen> {
  String _inputExpression = '';
  String _expressionLine = 'Enter expression';
  String _displayValue = '0';
  bool _didEvaluate = false;
  bool _showingError = false;

  /// Har scientific key ki tap handling ko ek jagah rakhta hai.
  void _onButtonPressed(LabButtonData button) {
    switch (button.id) {
      case '0':
      case '1':
      case '2':
      case '3':
      case '4':
      case '5':
      case '6':
      case '7':
      case '8':
      case '9':
        _appendDigit(button.label);
        return;
      case 'dot':
        _appendDecimal();
        return;
      case 'plus':
        _appendOperator('+');
        return;
      case 'minus':
        _appendOperator('-');
        return;
      case 'multiply':
        _appendOperator('*');
        return;
      case 'divide':
        _appendOperator('/');
        return;
      case 'pow':
        _appendOperator('^');
        return;
      case 'fact':
        _appendFactorial();
        return;
      case 'sin':
      case 'cos':
      case 'tan':
      case 'log':
      case 'ln':
      case 'int':
        _appendFunction(button.id);
        return;
      case 'pi':
        _appendConstant('pi');
        return;
      case 'e':
        _appendConstant('e');
        return;
      case 'brackets':
        _appendBrackets();
        return;
      case 'delete':
        _deleteLastToken();
        return;
      case 'equals':
        _evaluateExpression();
        return;
    }
  }

  /// Naye value buttons ke liye error ya last result state ko reset karta hai.
  void _prepareForFreshValue() {
    if (_showingError || _didEvaluate) {
      _inputExpression = '';
      _expressionLine = 'Enter expression';
      _displayValue = '0';
      _showingError = false;
      _didEvaluate = false;
    }
  }

  /// Number current expression me append karta hai aur zarurat par implicit multiply bhi lagata hai.
  void _appendDigit(String digit) {
    setState(() {
      _prepareForFreshValue();
      if (_needsMultiplyBeforeNumber(_inputExpression)) {
        _inputExpression += '*';
      }
      _inputExpression += digit;
      _syncDraftDisplay();
    });
  }

  /// Decimal sirf current number me ek hi dafa allow karta hai.
  void _appendDecimal() {
    setState(() {
      _prepareForFreshValue();
      if (_needsMultiplyBeforeNumber(_inputExpression)) {
        _inputExpression += '*0.';
        _syncDraftDisplay();
        return;
      }
      if (_currentNumberHasDecimal(_inputExpression)) {
        return;
      }
      if (_inputExpression.isEmpty ||
          _endsWithOperator(_inputExpression) ||
          _inputExpression.endsWith('(')) {
        _inputExpression += '0.';
      } else {
        _inputExpression += '.';
      }
      _syncDraftDisplay();
    });
  }

  /// Binary operators ko expression me add ya replace karta hai.
  void _appendOperator(String operator) {
    if (_showingError) {
      return;
    }

    setState(() {
      if (_inputExpression.isEmpty) {
        if (operator == '-') {
          _inputExpression = '-';
          _syncDraftDisplay();
        }
        return;
      }

      if (_inputExpression.endsWith('.')) {
        _inputExpression += '0';
      }

      if (_inputExpression.endsWith('(')) {
        if (operator == '-') {
          _inputExpression += '-';
          _syncDraftDisplay();
        }
        return;
      }

      if (_endsWithOperator(_inputExpression)) {
        _inputExpression =
            '${_inputExpression.substring(0, _inputExpression.length - 1)}$operator';
      } else {
        _inputExpression += operator;
      }

      _didEvaluate = false;
      _syncDraftDisplay();
    });
  }

  /// Unary scientific function ko expression me opening bracket ke sath insert karta hai.
  void _appendFunction(String functionName) {
    setState(() {
      _prepareForFreshValue();
      if (_needsMultiplyBeforeValue(_inputExpression)) {
        _inputExpression += '*';
      }
      _inputExpression += '$functionName(';
      _syncDraftDisplay();
    });
  }

  /// Constants jese pi aur e ko expression me add karta hai.
  void _appendConstant(String constant) {
    setState(() {
      _prepareForFreshValue();
      if (_needsMultiplyBeforeValue(_inputExpression)) {
        _inputExpression += '*';
      }
      _inputExpression += constant;
      _syncDraftDisplay();
    });
  }

  /// Smart bracket button context ke hisab se opening ya closing bracket add karta hai.
  void _appendBrackets() {
    setState(() {
      _prepareForFreshValue();
      final openBrackets = _openBracketCount(_inputExpression);
      final shouldClose =
          openBrackets > 0 &&
          _inputExpression.isNotEmpty &&
          !_endsWithOperator(_inputExpression) &&
          !_inputExpression.endsWith('(');

      if (shouldClose) {
        _inputExpression += ')';
      } else {
        if (_needsMultiplyBeforeValue(_inputExpression)) {
          _inputExpression += '*';
        }
        _inputExpression += '(';
      }
      _syncDraftDisplay();
    });
  }

  /// Factorial sirf valid completed value ke baad lagaya jata hai.
  void _appendFactorial() {
    if (_showingError || _inputExpression.isEmpty) {
      return;
    }

    setState(() {
      if (_canAppendFactorial(_inputExpression)) {
        _inputExpression += '!';
        _didEvaluate = false;
        _syncDraftDisplay();
      }
    });
  }

  /// Delete button last token ya last character ko remove karta hai.
  void _deleteLastToken() {
    setState(() {
      if (_showingError) {
        _inputExpression = '';
        _expressionLine = 'Enter expression';
        _displayValue = '0';
        _showingError = false;
        _didEvaluate = false;
        return;
      }

      if (_inputExpression.isEmpty) {
        return;
      }

      for (final token in _removableTokens) {
        if (_inputExpression.endsWith(token)) {
          _inputExpression =
              _inputExpression.substring(0, _inputExpression.length - token.length);
          _syncDraftDisplay();
          return;
        }
      }

      _inputExpression =
          _inputExpression.substring(0, _inputExpression.length - 1);
      _syncDraftDisplay();
    });
  }

  /// Equals dabane par full expression evaluate karke result save bhi kar deta hai.
  void _evaluateExpression() {
    if (_showingError || _inputExpression.isEmpty) {
      return;
    }

    final visibleExpression = _formatExpression(_inputExpression);

    try {
      final result = _ScientificExpressionParser(_inputExpression).parse();
      if (!result.isFinite) {
        throw StateError('Result is not finite.');
      }

      final normalizedResult = _normalizeNumber(result);
      final formattedResult = _formatResult(result);

      setState(() {
        _expressionLine = visibleExpression;
        _displayValue = formattedResult;
        _inputExpression = normalizedResult;
        _didEvaluate = true;
        _showingError = false;
      });

      // Completed scientific calculations ko bhi history me save kar diya jata hai.
      unawaited(
        CalculationHistoryStorage.save(
          expression: visibleExpression,
          result: formattedResult,
        ),
      );
    } catch (error) {
      _showError(_friendlyErrorMessage(error));
    }
  }

  /// Current draft ko line aur preview result ke sath sync rakhta hai.
  void _syncDraftDisplay() {
    _expressionLine = _inputExpression.isEmpty
        ? 'Enter expression'
        : _formatExpression(_inputExpression);
    _showingError = false;

    final preview = _tryEvaluateDraft(_inputExpression);
    if (preview != null) {
      _displayValue = _formatResult(preview);
      return;
    }

    if (_inputExpression.isEmpty) {
      _displayValue = '0';
      return;
    }

    final trailingPreview = _lastValuePreview(_inputExpression);
    if (trailingPreview != null) {
      _displayValue = trailingPreview;
    }
  }

  /// Invalid expression par screen ko readable error state me rakhta hai.
  void _showError(String message) {
    setState(() {
      _expressionLine = message;
      _displayValue = 'Error';
      _showingError = true;
      _didEvaluate = false;
    });

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  /// Draft expression sirf complete aur balanced ho to preview result nikalta hai.
  double? _tryEvaluateDraft(String expression) {
    if (expression.isEmpty ||
        _endsWithOperator(expression) ||
        expression.endsWith('(') ||
        expression.endsWith('.')) {
      return null;
    }
    if (_openBracketCount(expression) != 0) {
      return null;
    }

    try {
      final result = _ScientificExpressionParser(expression).parse();
      return result.isFinite ? result : null;
    } catch (_) {
      return null;
    }
  }

  /// Jab full result available na ho to current trailing number ya constant ka preview dikhata hai.
  String? _lastValuePreview(String expression) {
    if (expression.endsWith('pi')) {
      return _formatResult(math.pi);
    }
    if (_endsWithConstantE(expression)) {
      return _formatResult(math.e);
    }

    final numberMatch = RegExp(r'(\d+(\.\d*)?|\.\d+)$').firstMatch(expression);
    if (numberMatch == null) {
      return null;
    }

    final token = numberMatch.group(0);
    if (token == null || token.isEmpty) {
      return null;
    }

    return _formatDisplay(token);
  }

  /// Expression line me sirf thoda readable formatting apply hoti hai.
  String _formatExpression(String expression) {
    return expression
        .replaceAll('*', ' x ')
        .replaceAll('/', ' / ')
        .replaceAll('+', ' + ')
        .replaceAll('-', ' - ')
        .replaceAll('^', ' ^ ');
  }

  /// Numeric string me commas add karke large values readable banata hai.
  String _formatDisplay(String value) =>
      CalculatorDisplayFormatter.formatDisplay(value);

  /// Raw double ko UI display ke liye compact aur readable string me badalta hai.
  String _formatResult(double value) => CalculatorDisplayFormatter
      .formatAdaptiveResult(value, fractionDigits: 10);

  /// Floating point result se extra trailing zeros hata deta hai.
  String _normalizeNumber(double value) {
    return CalculatorDisplayFormatter.normalizeNumber(value, fractionDigits: 10);
  }

  bool _currentNumberHasDecimal(String expression) {
    final match = RegExp(r'(\d+(\.\d*)?|\.\d+)$').firstMatch(expression);
    return match?.group(0)?.contains('.') ?? false;
  }

  bool _needsMultiplyBeforeNumber(String expression) {
    if (expression.isEmpty) {
      return false;
    }

    final lastCharacter = expression[expression.length - 1];
    return lastCharacter == ')' ||
        lastCharacter == '!' ||
        expression.endsWith('pi') ||
        _endsWithConstantE(expression);
  }

  bool _needsMultiplyBeforeValue(String expression) {
    if (expression.isEmpty) {
      return false;
    }

    final lastCharacter = expression[expression.length - 1];
    if (RegExp(r'[0-9)]').hasMatch(lastCharacter) || lastCharacter == '!') {
      return true;
    }

    return expression.endsWith('pi') || _endsWithConstantE(expression);
  }

  bool _endsWithOperator(String expression) {
    if (expression.isEmpty) {
      return false;
    }
    return '+-*/^'.contains(expression[expression.length - 1]);
  }

  bool _endsWithConstantE(String expression) {
    if (!expression.endsWith('e')) {
      return false;
    }
    if (expression.length == 1) {
      return true;
    }

    final previousCharacter = expression[expression.length - 2];
    return !RegExp(r'[A-Za-z]').hasMatch(previousCharacter);
  }

  bool _canAppendFactorial(String expression) {
    if (expression.isEmpty) {
      return false;
    }

    final lastCharacter = expression[expression.length - 1];
    return RegExp(r'[0-9)]').hasMatch(lastCharacter) ||
        lastCharacter == '!' ||
        expression.endsWith('pi') ||
        _endsWithConstantE(expression);
  }

  int _openBracketCount(String expression) {
    var count = 0;
    for (final character in expression.split('')) {
      if (character == '(') {
        count++;
      } else if (character == ')') {
        count--;
      }
    }
    return count;
  }

  String _friendlyErrorMessage(Object error) {
    if (error is StateError) {
      return error.message.toString();
    }
    return 'Invalid expression.';
  }

  @override
  Widget build(BuildContext context) {
    return AppTabScaffold(
      currentRoute: AppRoutes.lab,
      useTopSafeArea: false,
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.95),
                  radius: 1.35,
                  colors: [
                    AppColors.accentPurple.withValues(alpha: 0.10),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Column(
            children: [
              const _LabHeader(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
                  child: Column(
                    children: [
                      _DisplayPanel(
                        expressionLine: _expressionLine,
                        displayValue: _displayValue,
                      ),
                      const SizedBox(height: 18),
                      _ModeToggle(
                        onBasicTap: () => context.go(AppRoutes.calculator),
                      ),
                      const SizedBox(height: 18),
                      Expanded(
                        child: _ScientificKeypad(onPressed: _onButtonPressed),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Top header app branding aur current mode badge dikhata hai.
class _LabHeader extends StatelessWidget {
  const _LabHeader();

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(14, topInset + 14, 14, 14),
      decoration: BoxDecoration(
        color: const Color(0xFF14131C).withValues(alpha: 0.76),
      ),
      child: Row(
        children: [
          const Text(
            'SYNTIC',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.6,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.30),
                  AppColors.primaryDark.withValues(alpha: 0.16),
                ],
              ),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.18),
              ),
            ),
            child: Text(
              'SCIENTIFIC MODE',
              style: TextStyle(
                color: AppColors.primary.withValues(alpha: 0.90),
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.9,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Display area live expression aur result ko dynamic tor par dikhata hai.
class _DisplayPanel extends StatelessWidget {
  const _DisplayPanel({
    required this.expressionLine,
    required this.displayValue,
  });

  final String expressionLine;
  final String displayValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: RadialGradient(
          center: const Alignment(0.9, -0.9),
          radius: 1.3,
          colors: [
            AppColors.accentPurple.withValues(alpha: 0.12),
            Colors.transparent,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            expressionLine,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: AppColors.textSecondary.withValues(alpha: 0.60),
              fontSize: 12,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              displayValue,
              style: TextStyle(
                color: _displayColor(displayValue),
                fontSize: 42,
                fontWeight: FontWeight.w700,
                height: 0.95,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _displayColor(String value) {
    return value == 'Error'
        ? AppColors.accentPurple.withValues(alpha: 0.96)
        : AppColors.textPrimary.withValues(alpha: 0.98);
  }
}

/// Yeh segmented control basic aur scientific mode ka look mimic karta hai.
class _ModeToggle extends StatelessWidget {
  const _ModeToggle({required this.onBasicTap});

  final VoidCallback onBasicTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: const Color(0xFF171824),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ModeChip(label: 'BASIC', onTap: onBasicTap),
          const SizedBox(width: 8),
          const _ModeChip(label: 'SCIENTIFIC', isActive: true),
        ],
      ),
    );
  }
}

/// Single mode chip active aur inactive visual state ko handle karta hai.
class _ModeChip extends StatelessWidget {
  const _ModeChip({
    required this.label,
    this.isActive = false,
    this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: isActive
                ? LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.30),
                      AppColors.primaryDark.withValues(alpha: 0.16),
                    ],
                  )
                : null,
            color: isActive ? null : Colors.transparent,
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isActive
                  ? AppColors.primary.withValues(alpha: 0.98)
                  : AppColors.textSecondary.withValues(alpha: 0.58),
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
        ),
      ),
    );
  }
}

/// Scientific buttons ko row data se render karta hai taake layout maintainable rahe.
class _ScientificKeypad extends StatelessWidget {
  const _ScientificKeypad({required this.onPressed});

  final ValueChanged<LabButtonData> onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < _labRows.length; index++)
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: index == _labRows.length - 1 ? 0 : 10,
              ),
              child: Row(
                children: [
                  for (final button in _labRows[index])
                    Expanded(
                      flex: button.flex,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: LabButton(
                          data: button,
                          onPressed: () => onPressed(button),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Yeh parser scientific expression string ko evaluate karta hai.
class _ScientificExpressionParser {
  _ScientificExpressionParser(this.source);

  final String source;
  int _index = 0;

  double parse() {
    final value = _parseExpression();
    _skipWhitespace();
    if (_index != source.length) {
      throw const FormatException('Unexpected trailing token.');
    }
    return value;
  }

  double _parseExpression() {
    var value = _parseTerm();

    while (true) {
      _skipWhitespace();
      if (_match('+')) {
        value += _parseTerm();
      } else if (_match('-')) {
        value -= _parseTerm();
      } else {
        return value;
      }
    }
  }

  double _parseTerm() {
    var value = _parsePower();

    while (true) {
      _skipWhitespace();
      if (_match('*')) {
        value *= _parsePower();
      } else if (_match('/')) {
        final divisor = _parsePower();
        if (divisor == 0) {
          throw StateError('Cannot divide by zero.');
        }
        value /= divisor;
      } else {
        return value;
      }
    }
  }

  double _parsePower() {
    var value = _parseUnary();
    _skipWhitespace();

    if (_match('^')) {
      final exponent = _parsePower();
      value = math.pow(value, exponent).toDouble();
    }

    return value;
  }

  double _parseUnary() {
    _skipWhitespace();

    if (_match('+')) {
      return _parseUnary();
    }
    if (_match('-')) {
      return -_parseUnary();
    }

    return _parsePostfix();
  }

  double _parsePostfix() {
    var value = _parsePrimary();

    while (true) {
      _skipWhitespace();
      if (_match('!')) {
        value = _factorial(value);
      } else {
        return value;
      }
    }
  }

  double _parsePrimary() {
    _skipWhitespace();

    if (_match('(')) {
      final value = _parseExpression();
      _expect(')');
      return value;
    }

    if (_isLetter(_peek())) {
      final identifier = _readIdentifier();
      if (identifier == 'pi') {
        return math.pi;
      }
      if (identifier == 'e') {
        return math.e;
      }

      _expect('(');
      final argument = _parseExpression();
      _expect(')');
      return _applyFunction(identifier, argument);
    }

    return _readNumber();
  }

  double _applyFunction(String identifier, double value) {
    switch (identifier) {
      case 'sin':
        return math.sin(value);
      case 'cos':
        return math.cos(value);
      case 'tan':
        return math.tan(value);
      case 'log':
        if (value <= 0) {
          throw StateError('LOG only works for values greater than zero.');
        }
        return math.log(value) / math.ln10;
      case 'ln':
        if (value <= 0) {
          throw StateError('LN only works for values greater than zero.');
        }
        return math.log(value);
      case 'int':
        return value.truncateToDouble();
      default:
        throw StateError('Unsupported function $identifier.');
    }
  }

  double _factorial(double value) {
    if (value < 0 || value % 1 != 0) {
      throw StateError('Factorial only works for whole positive numbers.');
    }

    var result = 1.0;
    for (var index = 2; index <= value; index++) {
      result *= index;
    }
    return result;
  }

  double _readNumber() {
    _skipWhitespace();
    final start = _index;

    while (_index < source.length &&
        RegExp(r'[0-9.]').hasMatch(source[_index])) {
      _index++;
    }

    if (start == _index) {
      throw const FormatException('Expected a number.');
    }

    final token = source.substring(start, _index);
    final value = double.tryParse(token);
    if (value == null) {
      throw const FormatException('Invalid number.');
    }
    return value;
  }

  String _readIdentifier() {
    final start = _index;
    while (_index < source.length && _isLetter(source[_index])) {
      _index++;
    }
    return source.substring(start, _index);
  }

  void _expect(String character) {
    _skipWhitespace();
    if (!_match(character)) {
      throw FormatException('Expected $character.');
    }
  }

  bool _match(String character) {
    if (_peek() == character) {
      _index++;
      return true;
    }
    return false;
  }

  String? _peek() {
    if (_index >= source.length) {
      return null;
    }
    return source[_index];
  }

  void _skipWhitespace() {
    while (_index < source.length && source[_index].trim().isEmpty) {
      _index++;
    }
  }

  bool _isLetter(String? value) {
    return value != null && RegExp(r'[A-Za-z]').hasMatch(value);
  }
}

// Scientific keypad ka layout data-driven rakha gaya hai taake buttons asani se reuse ho saken.
const List<List<LabButtonData>> _labRows = [
  [
    LabButtonData(id: 'sin', label: 'SIN', tone: CalculatorKeyTone.function),
    LabButtonData(id: 'cos', label: 'COS', tone: CalculatorKeyTone.function),
    LabButtonData(id: 'tan', label: 'TAN', tone: CalculatorKeyTone.function),
    LabButtonData(id: 'log', label: 'LOG', tone: CalculatorKeyTone.function),
    LabButtonData(
      id: 'delete',
      label: 'DEL',
      tone: CalculatorKeyTone.delete,
      icon: Icons.backspace_outlined,
    ),
  ],
  [
    LabButtonData(id: 'ln', label: 'LN', tone: CalculatorKeyTone.function),
    LabButtonData(id: 'int', label: 'INT', tone: CalculatorKeyTone.function),
    LabButtonData(id: 'pow', label: 'x^y', tone: CalculatorKeyTone.function),
    LabButtonData(id: 'fact', label: 'x!', tone: CalculatorKeyTone.function),
    LabButtonData(id: 'divide', label: '/', tone: CalculatorKeyTone.operator),
  ],
  [
    LabButtonData(id: '7', label: '7'),
    LabButtonData(id: '8', label: '8'),
    LabButtonData(id: '9', label: '9'),
    LabButtonData(id: 'pi', label: 'PI', tone: CalculatorKeyTone.function),
    LabButtonData(id: 'multiply', label: 'x', tone: CalculatorKeyTone.operator),
  ],
  [
    LabButtonData(id: '4', label: '4'),
    LabButtonData(id: '5', label: '5'),
    LabButtonData(id: '6', label: '6'),
    LabButtonData(id: 'e', label: 'E', tone: CalculatorKeyTone.function),
    LabButtonData(id: 'minus', label: '-', tone: CalculatorKeyTone.operator),
  ],
  [
    LabButtonData(id: '1', label: '1'),
    LabButtonData(id: '2', label: '2'),
    LabButtonData(id: '3', label: '3'),
    LabButtonData(id: 'dot', label: '.', tone: CalculatorKeyTone.function),
    LabButtonData(id: 'plus', label: '+', tone: CalculatorKeyTone.operator),
  ],
  [
    LabButtonData(id: '0', label: '0', flex: 2),
    LabButtonData(
      id: 'brackets',
      label: '()',
      tone: CalculatorKeyTone.function,
    ),
    LabButtonData(
      id: 'equals',
      label: '=',
      tone: CalculatorKeyTone.equal,
      flex: 2,
    ),
  ],
];

const List<String> _removableTokens = [
  'sin(',
  'cos(',
  'tan(',
  'log(',
  'ln(',
  'int(',
  'pi',
];
