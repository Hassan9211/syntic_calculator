import 'dart:async';

import 'package:flutter/material.dart';

/// Shared inline expression editor jo tap-to-cursor aur blinking caret handle karta hai.
class InlineExpressionEditorController extends ChangeNotifier {
  static const Duration _cursorBlinkInterval = Duration(milliseconds: 530);

  bool _isEditing = false;
  String _buffer = '';
  int _cursorIndex = 0;
  bool _showBlinkCursor = true;
  Timer? _cursorBlinkTimer;

  bool get isEditing => _isEditing;

  String textForDisplay(String fallbackText) {
    return _isEditing ? _previewText() : fallbackText;
  }

  void beginOrMoveCursor({
    required String baseText,
    required Offset localPosition,
    required double maxWidth,
    required TextStyle style,
    int maxLines = 1,
  }) {
    final activeText = _isEditing ? _buffer : baseText;
    final cursorIndex = _calculateCursorIndex(
      text: activeText,
      localPosition: localPosition,
      maxWidth: maxWidth,
      style: style,
      maxLines: maxLines,
    );

    _isEditing = true;
    _buffer = activeText;
    _cursorIndex = cursorIndex;
    _showBlinkCursor = true;
    _startCursorBlink();
    notifyListeners();
  }

  String finishEditing() {
    _cursorBlinkTimer?.cancel();
    final editedValue = _buffer;
    _isEditing = false;
    _buffer = '';
    _cursorIndex = 0;
    _showBlinkCursor = true;
    notifyListeners();
    return editedValue;
  }

  void clear({String resetText = '0'}) {
    _buffer = resetText;
    _cursorIndex = _buffer.length;
    _showBlinkCursor = true;
    _restartCursorBlink();
    notifyListeners();
  }

  void insertText(String value) {
    insertTextAndPlaceCursor(value, cursorOffsetFromEnd: 0);
  }

  void insertTextAndPlaceCursor(String value, {required int cursorOffsetFromEnd}) {
    if (!_isEditing) {
      return;
    }

    if (_buffer == '0' && value != '.' && _cursorIndex <= 1) {
      _buffer = value;
      _cursorIndex = value.length - cursorOffsetFromEnd;
    } else {
      _buffer = _buffer.replaceRange(_cursorIndex, _cursorIndex, value);
      _cursorIndex += value.length - cursorOffsetFromEnd;
    }

    _showBlinkCursor = true;
    _restartCursorBlink();
    notifyListeners();
  }

  void insertDecimal({required RegExp segmentPattern}) {
    if (!_isEditing) {
      return;
    }

    final leftText = _buffer.substring(0, _cursorIndex);
    final segmentMatch = segmentPattern.firstMatch(leftText);
    final lastPart = segmentMatch?.group(0) ?? '';
    if (lastPart.contains('.')) {
      return;
    }

    final insertion = lastPart.isEmpty ? '0.' : '.';
    _buffer = _buffer.replaceRange(_cursorIndex, _cursorIndex, insertion);
    _cursorIndex += insertion.length;
    _showBlinkCursor = true;
    _restartCursorBlink();
    notifyListeners();
  }

  void deleteBackward({String fallbackText = '0'}) {
    if (!_isEditing || _buffer.isEmpty || _buffer == fallbackText || _cursorIndex == 0) {
      return;
    }

    _buffer = _buffer.replaceRange(_cursorIndex - 1, _cursorIndex, '');
    _cursorIndex -= 1;
    if (_buffer.isEmpty) {
      _buffer = fallbackText;
      _cursorIndex = fallbackText.length;
    }

    _showBlinkCursor = true;
    _restartCursorBlink();
    notifyListeners();
  }

  @override
  void dispose() {
    _cursorBlinkTimer?.cancel();
    super.dispose();
  }

  String _previewText() {
    final value = _buffer.isEmpty ? ' ' : _buffer;
    final safeCursorIndex = _cursorIndex.clamp(0, value.length);
    final cursor = _showBlinkCursor ? '|' : ' ';
    return value.replaceRange(safeCursorIndex, safeCursorIndex, cursor);
  }

  void _startCursorBlink() {
    _cursorBlinkTimer?.cancel();
    _cursorBlinkTimer = Timer.periodic(_cursorBlinkInterval, (_) {
      if (!_isEditing) {
        _cursorBlinkTimer?.cancel();
        return;
      }
      _showBlinkCursor = !_showBlinkCursor;
      notifyListeners();
    });
  }

  void _restartCursorBlink() {
    if (!_isEditing) {
      return;
    }
    _showBlinkCursor = true;
    _startCursorBlink();
  }

  int _calculateCursorIndex({
    required String text,
    required Offset localPosition,
    required double maxWidth,
    required TextStyle style,
    required int maxLines,
  }) {
    if (text.isEmpty) {
      return 0;
    }

    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.right,
      maxLines: maxLines,
      ellipsis: maxLines == 1 ? '...' : null,
    )..layout(maxWidth: maxWidth);

    final clampedDx = localPosition.dx.clamp(0.0, maxWidth).toDouble();

    for (var index = 0; index < text.length; index++) {
      final boxes = painter.getBoxesForSelection(
        TextSelection(baseOffset: index, extentOffset: index + 1),
      );
      if (boxes.isEmpty) {
        continue;
      }

      final box = boxes.first;
      final midpoint = (box.left + box.right) / 2;
      if (clampedDx <= midpoint) {
        return index;
      }
    }

    return text.length;
  }
}

/// Reusable tappable expression line jo shared editor controller use karti hai.
class EditableExpressionLine extends StatelessWidget {
  const EditableExpressionLine({
    super.key,
    required this.controller,
    required this.text,
    required this.style,
    this.textKey,
    this.editingBaseText,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    this.maxLines = 1,
    this.overflow = TextOverflow.ellipsis,
    this.textAlign = TextAlign.end,
  });

  final InlineExpressionEditorController controller;
  final String text;
  final Key? textKey;
  final String? editingBaseText;
  final TextStyle style;
  final EdgeInsets padding;
  final int maxLines;
  final TextOverflow overflow;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            return Material(
              color: Colors.transparent,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (details) => controller.beginOrMoveCursor(
                  baseText: editingBaseText ?? text,
                  localPosition: Offset(
                    details.localPosition.dx - padding.left,
                    details.localPosition.dy - padding.top,
                  ),
                  maxWidth: constraints.maxWidth - padding.horizontal,
                  style: style,
                  maxLines: maxLines,
                ),
                child: Padding(
                  padding: padding,
                  child: Text(
                    controller.textForDisplay(text),
                    key: textKey,
                    textAlign: textAlign,
                    style: style,
                    maxLines: maxLines,
                    overflow: overflow,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
