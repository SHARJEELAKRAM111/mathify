import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/persistence/prefs_keys.dart';
import '../../../../core/persistence/prefs_service.dart';
import '../../data/history_repository.dart';
import '../../domain/models/history_entry.dart';
import '../../domain/services/calculator_logic.dart';

class CalculatorController extends ChangeNotifier {
  CalculatorController(this._prefs) : _historyRepo = HistoryRepository(_prefs) {
    _loadSettings();
    _history = _historyRepo.load();
  }

  final PrefsService _prefs;
  final HistoryRepository _historyRepo;

  final CalculatorLogic _logic = CalculatorLogic();

  String _expression = '';
  String _result = '0';
  bool _showResult = false;

  bool _scientificEnabled = true;
  bool _hapticEnabled = true;
  bool _soundEnabled = false;

  List<HistoryEntry> _history = [];

  String get expression => _expression.isEmpty ? '0' : _expression;
  String get result => _result;
  bool get showResult => _showResult;

  bool get isScientificEnabled => _scientificEnabled;
  bool get hapticEnabled => _hapticEnabled;
  bool get soundEnabled => _soundEnabled;

  List<HistoryEntry> get history => List.unmodifiable(_history);

  void _loadSettings() {
    _scientificEnabled = _prefs.getBool(PrefKeys.scientific, defaultValue: false);
    _hapticEnabled = _prefs.getBool(PrefKeys.haptic, defaultValue: true);
    _soundEnabled = _prefs.getBool(PrefKeys.sound, defaultValue: false);
  }

  Future<void> _persistSettings() async {
    await _prefs.setBool(PrefKeys.scientific, _scientificEnabled);
    await _prefs.setBool(PrefKeys.haptic, _hapticEnabled);
    await _prefs.setBool(PrefKeys.sound, _soundEnabled);
  }

  void _feedback({bool strong = false}) {
    if (_soundEnabled) {
      SystemSound.play(SystemSoundType.click);
    }
    if (_hapticEnabled) {
      if (strong) {
        HapticFeedback.mediumImpact();
      } else {
        HapticFeedback.selectionClick();
      }
    }
  }

  Future<void> toggleScientific() async {
    _scientificEnabled = !_scientificEnabled;
    _feedback(strong: true);
    await _persistSettings();
    notifyListeners();
  }

  Future<void> toggleHaptic() async {
    _hapticEnabled = !_hapticEnabled;
    if (_hapticEnabled) {
      HapticFeedback.lightImpact();
    }
    await _persistSettings();
    notifyListeners();
  }

  Future<void> toggleSound() async {
    _soundEnabled = !_soundEnabled;
    _feedback(strong: true);
    await _persistSettings();
    notifyListeners();
  }

  /// Public input entrypoint.
  void onKey(String value) {
    _feedback();

    switch (value) {
      case 'AC':
        _allClear();
        break;
      case 'C':
        _clear();
        break;
      case 'DEL':
        _delete();
        break;
      case '=':
        _calculate(commitToHistory: true);
        break;
      case '+/-':
        _toggleSign();
        break;
      case '%':
        _percentage();
        break;
      case 'π':
        _appendToken('3.141592653589793');
        break;
      case 'e':
        _appendToken('2.718281828459045');
        break;
      case 'x²':
        _power(2);
        break;
      case 'x³':
        _power(3);
        break;
      case '√':
        _sqrt();
        break;
      case '∛':
        _cbrt();
        break;
      case 'n!':
        _factorial();
        break;
      case 'sin':
      case 'cos':
      case 'tan':
      case 'sin⁻¹':
      case 'cos⁻¹':
      case 'tan⁻¹':
      case 'ln':
      case 'log':
      case 'eˣ':
      case '10ˣ':
        _scientificFunction(value);
        break;
      case 'xʸ':
        _appendToken('^');
        break;
      case '+':
      case '-':
      case '×':
      case '÷':
        _addOperator(value);
        break;
      case '.':
        _addDecimal();
        break;
      case '(':
      case ')':
        _appendToken(value);
        break;
      default:
        _addNumber(value);
        break;
    }

    // Live preview
    if (_expression.isNotEmpty && !_endsWithOperator()) {
      _calculate(commitToHistory: false);
      _showResult = false;
    }

    notifyListeners();
  }

  /// Convenience for swipe gestures: delete last char.
  void backspace() {
    _feedback();
    _delete();
    notifyListeners();
  }

  /// Convenience for gesture: long swipe to clear.
  void clearExpression() {
    _feedback(strong: true);
    _clear();
    notifyListeners();
  }

  bool _endsWithOperator() {
    if (_expression.isEmpty) return false;
    final last = _expression[_expression.length - 1];
    return ['+', '-', '×', '÷', '^', '('].contains(last);
  }

  bool _isOperator(String v) => ['+', '-', '×', '÷', '^'].contains(v);

  void _addNumber(String number) {
    if (_showResult) {
      _expression = '';
      _showResult = false;
    }

    if (_expression == '0' && number == '0') return;
    if (_expression == '0') {
      _expression = number;
    } else {
      _expression += number;
    }
  }

  void _addOperator(String op) {
    if (_showResult) {
      _expression = _result;
      _showResult = false;
    }

    if (_expression.isEmpty || _expression == '0') {
      if (op == '-') _expression = '-';
      return;
    }

    if (_endsWithOperator()) {
      // allow negative right after operator
      if (op == '-' && _expression[_expression.length - 1] != '-') {
        _expression += op;
      } else {
        _expression = _expression.substring(0, _expression.length - 1) + op;
      }
    } else {
      _expression += op;
    }
  }

  void _addDecimal() {
    if (_showResult) {
      _expression = '0.';
      _showResult = false;
      return;
    }

    final current = _getCurrentNumber();
    if (!current.contains('.')) {
      if (_expression.isEmpty || _endsWithOperator()) {
        _expression += '0.';
      } else {
        _expression += '.';
      }
    }
  }

  String _getCurrentNumber() {
    if (_expression.isEmpty) return '0';

    int lastOp = -1;
    for (int i = _expression.length - 1; i >= 0; i--) {
      if (_isOperator(_expression[i])) {
        lastOp = i;
        break;
      }
    }

    return lastOp == -1 ? _expression : _expression.substring(lastOp + 1);
  }

  void _appendToken(String value) {
    if (_showResult) {
      _expression = '';
      _showResult = false;
    }
    if (_expression == '0') {
      _expression = value;
    } else {
      _expression += value;
    }
  }

  void _allClear() {
    _expression = '';
    _result = '0';
    _showResult = false;
  }

  void _clear() {
    _expression = '';
    _result = '0';
    _showResult = false;
  }

  void _delete() {
    if (_showResult) {
      _expression = _result;
      _result = '0';
      _showResult = false;
    }

    if (_expression.isNotEmpty) {
      _expression = _expression.substring(0, _expression.length - 1);
      if (_expression.isEmpty) {
        _result = '0';
      } else if (!_endsWithOperator()) {
        _calculate(commitToHistory: false);
      }
    }
  }

  void _toggleSign() {
    final current = _getCurrentNumber();
    if (current.isEmpty || current == '0') return;

    final start = _expression.length - current.length;
    if (current.startsWith('-')) {
      _expression = _expression.substring(0, start) + current.substring(1);
    } else {
      _expression = '${_expression.substring(0, start)}-$current';
    }
  }

  void _percentage() {
    final current = _getCurrentNumber();
    if (current.isEmpty || current == '0') return;
    final value = double.tryParse(current);
    if (value == null) return;

    final percent = (value / 100).toString();
    final start = _expression.length - current.length;
    _expression = _expression.substring(0, start) + percent;
  }

  void _power(int exponent) {
    final current = _getCurrentNumber();
    final value = double.tryParse(current);
    if (value == null) return;

    double out = 1;
    for (int i = 0; i < exponent; i++) {
      out *= value;
    }
    final start = _expression.length - current.length;
    _expression = _expression.substring(0, start) + out.toString();
  }

  void _sqrt() {
    final current = _getCurrentNumber();
    final value = double.tryParse(current);
    if (value == null || value < 0) return;

    final out = _logic.sqrt(value);
    final start = _expression.length - current.length;
    _expression = _expression.substring(0, start) + out.toString();
  }

  void _cbrt() {
    final current = _getCurrentNumber();
    final value = double.tryParse(current);
    if (value == null) return;

    final out = _logic.cubeRoot(value);
    final start = _expression.length - current.length;
    _expression = _expression.substring(0, start) + out.toString();
  }

  void _factorial() {
    final current = _getCurrentNumber();
    final numeric = double.tryParse(current);
    if (numeric == null) return;

    final intValue = numeric.toInt();
    if (intValue < 0 || intValue > 20) return;

    final out = _logic.factorial(intValue);
    final start = _expression.length - current.length;
    _expression = _expression.substring(0, start) + out.toString();
  }

  void _scientificFunction(String function) {
    final current = _getCurrentNumber();
    final value = double.tryParse(current);
    if (value == null) return;

    double out = value;
    try {
      switch (function) {
        case 'sin':
          out = _logic.sin(value);
          break;
        case 'cos':
          out = _logic.cos(value);
          break;
        case 'tan':
          out = _logic.tan(value);
          break;
        case 'sin⁻¹':
          out = _logic.asin(value);
          break;
        case 'cos⁻¹':
          out = _logic.acos(value);
          break;
        case 'tan⁻¹':
          out = _logic.atan(value);
          break;
        case 'ln':
          out = _logic.ln(value);
          break;
        case 'log':
          out = _logic.log(value);
          break;
        case 'eˣ':
          out = _logic.exp(value);
          break;
        case '10ˣ':
          out = _logic.pow10(value);
          break;
      }

      final start = _expression.length - current.length;
      _expression = _expression.substring(0, start) + out.toString();
    } catch (_) {
      // ignore - keep expression unchanged
    }
  }

  void _calculate({required bool commitToHistory}) {
    if (_expression.isEmpty) return;

    var expr = _expression;
    if (_endsWithOperator()) {
      expr = expr.substring(0, expr.length - 1);
    }
    if (expr.isEmpty) return;

    expr = expr.replaceAll('×', '*').replaceAll('÷', '/').replaceAll('^', '**');

    try {
      final calc = _logic.evaluate(expr);
      _result = calc.toString();
      _formatResult();

      if (commitToHistory) {
        _showResult = true;
        final entry = HistoryEntry(
          id: _newId(),
          expression: _expression,
          result: _result,
          createdAt: DateTime.now(),
        );
        _history.insert(0, entry);
        _historyRepo.save(_history);
      }
    } catch (_) {
      if (commitToHistory) {
        _result = 'Error';
        _showResult = true;
      }
    }
  }

  void _formatResult() {
    if (!_result.contains('.')) return;
    final value = double.tryParse(_result);
    if (value == null) return;

    if (value == value.toInt()) {
      _result = value.toInt().toString();
      return;
    }

    // Limit to 10 decimal places and trim
    _result = value.toStringAsFixed(10).replaceAll(RegExp(r'0+$'), '');
    if (_result.endsWith('.')) _result = _result.substring(0, _result.length - 1);
  }

  String _newId() {
    // short stable-ish id without extra deps
    final now = DateTime.now().microsecondsSinceEpoch;
    final salt = math.Random().nextInt(999999);
    return '${now}_$salt';
  }

  Future<void> clearHistory() async {
    _feedback(strong: true);
    _history = [];
    await _historyRepo.clear();
    notifyListeners();
  }

  Future<void> deleteHistoryEntry(String id) async {
    _feedback();
    _history.removeWhere((e) => e.id == id);
    await _historyRepo.save(_history);
    notifyListeners();
  }

  void reuseHistory(HistoryEntry entry) {
    _feedback(strong: true);
    _expression = entry.expression;
    _result = entry.result;
    _showResult = true;
    notifyListeners();
  }

  Future<void> copyResultToClipboard() async {
    _feedback(strong: true);
    await Clipboard.setData(ClipboardData(text: _result));
  }

  Future<void> copyText(String text) async {
    _feedback(strong: true);
    await Clipboard.setData(ClipboardData(text: text));
  }
}
