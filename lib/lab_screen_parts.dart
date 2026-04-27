part of 'lab_screen.dart';

/// Display area live expression aur result ko dynamic tor par dikhata hai.
class _DisplayPanel extends StatelessWidget {
  const _DisplayPanel({
    required this.editor,
    required this.expressionLine,
    required this.editingExpression,
    required this.displayValue,
  });

  final InlineExpressionEditorController editor;
  final String expressionLine;
  final String editingExpression;
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
          EditableExpressionLine(
            controller: editor,
            text: expressionLine,
            editingBaseText: editingExpression,
            padding: EdgeInsets.zero,
            maxLines: 2,
            style: TextStyle(
              color: AppColors.textSecondary.withValues(alpha: 0.60),
              fontSize: 16,
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
    final callback = onTap;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: callback == null
            ? null
            : () {
                unawaited(AppInteractionFeedback.playTap());
                callback();
              },
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
    LabButtonData(id: 'ac', label: 'AC', tone: CalculatorKeyTone.delete),
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
      label: '( )',
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
