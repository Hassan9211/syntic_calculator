import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:syntic_calculator/app_colors.dart';
import 'package:syntic_calculator/enums/calculator_key_tone.dart';
import 'package:syntic_calculator/routes/route_paths.dart';
import 'package:syntic_calculator/services/app_interaction_feedback.dart';
import 'package:syntic_calculator/storage/calculation_history_storage.dart';
import 'package:syntic_calculator/utils/calculator_display_formatter.dart';
import 'package:syntic_calculator/widgets/bottom_buttons.dart';
import 'package:syntic_calculator/widgets/header.dart';
import 'package:syntic_calculator/widgets/inline_expression_editor.dart';
import 'package:syntic_calculator/widgets/lab_button.dart';

part 'lab_screen_parts.dart';

/// Lab tab ke liye working scientific calculator screen dikhata hai.
class LabScreen extends StatefulWidget {
  const LabScreen({super.key});

  @override
  State<LabScreen> createState() => _LabScreenState();
}

class _LabScreenState extends State<LabScreen> {
  static const Set<String> _functionButtons = {
    'sin',
    'cos',
    'tan',
    'log',
    'ln',
    'int',
  };
  final InlineExpressionEditorController _expressionEditor =
      InlineExpressionEditorController();
  String _inputExpression = '';
  String _expressionLine = 'Enter expression';
  String _displayValue = '0';
  bool _didEvaluate = false;
  bool _showingError = false;

  @override
  void dispose() {
    _expressionEditor.dispose();
    super.dispose();
  }

  /// Har scientific key ki tap handling ko ek jagah rakhta hai.
  void _onButtonPressed(LabButtonData button) {
    if (_expressionEditor.isEditing) {
      _handleInlineEditButton(button);
      return;
    }

    if (_isDigitButton(button.id)) {
      _appendDigit(button.label);
      return;
    }
    if (_functionButtons.contains(button.id)) {
      _appendFunction(button.id);
      return;
    }

    switch (button.id) {
      case 'ac':
        _resetLabCalculator();
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

  void _handleInlineEditButton(LabButtonData button) {
    if (_isDigitButton(button.id)) {
      _expressionEditor.insertText(button.label);
      return;
    }
    if (_functionButtons.contains(button.id)) {
      _expressionEditor.insertText('${button.id}(');
      return;
    }

    switch (button.id) {
      case 'ac':
        _expressionEditor.clear(resetText: '');
        return;
      case 'delete':
        _expressionEditor.deleteBackward(fallbackText: '');
        return;
      case 'equals':
        _finishInlineEditing(evaluateAfterApply: true);
        return;
      case 'dot':
        _expressionEditor.insertDecimal(
          segmentPattern: RegExp(r'[^+\-*/^()]*$'),
        );
        return;
      case 'plus':
        _expressionEditor.insertText('+');
        return;
      case 'minus':
        _expressionEditor.insertText('-');
        return;
      case 'multiply':
        _expressionEditor.insertText('*');
        return;
      case 'divide':
        _expressionEditor.insertText('/');
        return;
      case 'pow':
        _expressionEditor.insertText('^');
        return;
      case 'fact':
        _expressionEditor.insertText('!');
        return;
      case 'pi':
        _expressionEditor.insertText('pi');
        return;
      case 'e':
        _expressionEditor.insertText('e');
        return;
      case 'brackets':
        _expressionEditor.insertTextAndPlaceCursor(
          '(  )',
          cursorOffsetFromEnd: 2,
        );
        return;
      default:
        _expressionEditor.insertText(button.label);
        return;
    }
  }

  bool _isDigitButton(String id) => RegExp(r'^\d$').hasMatch(id);

  /// Naye value buttons ke liye error ya last result state ko reset karta hai.
  void _prepareForFreshValue() {
    if (_showingError || _didEvaluate) {
      _resetLabState();
    }
  }

  void _resetLabCalculator() {
    setState(_resetLabState);
  }

  void _resetLabState() {
    _inputExpression = '';
    _expressionLine = 'Enter expression';
    _displayValue = '0';
    _showingError = false;
    _didEvaluate = false;
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
          _inputExpression = _inputExpression.substring(
            0,
            _inputExpression.length - token.length,
          );
          _syncDraftDisplay();
          return;
        }
      }

      _inputExpression = _inputExpression.substring(
        0,
        _inputExpression.length - 1,
      );
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

    if (_inputExpression.isEmpty) {
      _displayValue = '0';
    } else if (RegExp(
      r'^-?(?:\d+|\d+\.\d*|\.\d+)\$',
    ).hasMatch(_inputExpression)) {
      _displayValue = CalculatorDisplayFormatter.formatDisplay(
        _inputExpression,
      );
    } else {
      _displayValue = '0';
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

  /// Expression line me sirf thoda readable formatting apply hoti hai.
  String _formatExpression(String expression) {
    return expression
        .replaceAll('*', ' x ')
        .replaceAll('/', ' / ')
        .replaceAll('+', ' + ')
        .replaceAll('-', ' - ')
        .replaceAll('^', ' ^ ');
  }

  void _finishInlineEditing({bool evaluateAfterApply = false}) {
    if (!_expressionEditor.isEditing) {
      return;
    }

    final editedValue = _expressionEditor.finishEditing();
    _applyEditedExpression(editedValue);

    if (evaluateAfterApply && _inputExpression.isNotEmpty && !_showingError) {
      _evaluateExpression();
    }
  }

  void _applyEditedExpression(String rawExpression) {
    final normalized = rawExpression.replaceAll(' ', '').trim();

    setState(() {
      _inputExpression = normalized;
      _didEvaluate = false;
      _showingError = false;
      _syncDraftDisplay();
    });
  }

  /// Raw double ko UI display ke liye compact aur readable string me badalta hai.
  String _formatResult(double value) =>
      CalculatorDisplayFormatter.formatAdaptiveResult(
        value,
        fractionDigits: 10,
      );

  /// Floating point result se extra trailing zeros hata deta hai.
  String _normalizeNumber(double value) {
    return CalculatorDisplayFormatter.normalizeNumber(
      value,
      fractionDigits: 10,
    );
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
              AppHeader(
                title: 'SYNTIC',
                useTopInset: true,
                topPadding: 14,
                horizontalPadding: 14,
                bottomPadding: 14,
                backgroundColor: const Color(
                  0xFF14131C,
                ).withValues(alpha: 0.76),
                titleColor: AppColors.textPrimary,
                fontSize: 18,
                letterSpacing: 2.6,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
                  child: Column(
                    children: [
                      _DisplayPanel(
                        editor: _expressionEditor,
                        expressionLine: _expressionLine,
                        editingExpression: _inputExpression,
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
