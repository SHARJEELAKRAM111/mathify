// ignore_for_file: unused_field, prefer_final_fields

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/calculator_logic.dart';

class CalculatorProvider extends ChangeNotifier {
  String _expression = '';
  String _result = '0';
  List<String> _history = [];
  bool _isScientificMode = false;
  bool _hapticEnabled = true;
  bool _soundEnabled = false;
  bool _showResult = false;
  String _lastOperator = '';

  // Settings
  bool _useDegrees = true; // DEG vs RAD
  bool _autoPreview = true;
  int _maxHistoryItems = 80;
  int _decimalPrecision = 10;

  // Memory register
  double _memory = 0;
  
  final CalculatorLogic _calculatorLogic = CalculatorLogic();

  CalculatorProvider() {
    _loadPrefs();
  }
  
  String get expression => _expression.isEmpty ? '0' : _expression;
  String get result => _result;
  bool get showResult => _showResult;
  List<String> get history => _history;
  bool get isScientificMode => _isScientificMode;
  bool get hapticEnabled => _hapticEnabled;
  bool get soundEnabled => _soundEnabled;

  bool get useDegrees => _useDegrees;
  bool get autoPreview => _autoPreview;
  int get maxHistoryItems => _maxHistoryItems;
  int get decimalPrecision => _decimalPrecision;
  double get memory => _memory;

  static const _prefsKeyHaptic = 'calc_haptic';
  static const _prefsKeySound = 'calc_sound';
  static const _prefsKeyDegrees = 'calc_degrees';
  static const _prefsKeyAutoPreview = 'calc_auto_preview';
  static const _prefsKeyMaxHistory = 'calc_max_history';
  static const _prefsKeyPrecision = 'calc_precision';
  static const _prefsKeyHistory = 'calc_history';
  static const _prefsKeyMemory = 'calc_memory';

  String get angleLabel => _useDegrees ? 'DEG' : 'RAD';
  
  void toggleScientificMode() {
    _isScientificMode = !_isScientificMode;
    if (_hapticEnabled) HapticFeedback.lightImpact();
    notifyListeners();
  }

  Future<void> toggleAngleUnit() async {
    _useDegrees = !_useDegrees;
    if (_hapticEnabled) HapticFeedback.lightImpact();
    await _saveSettings();
    notifyListeners();
  }
  
  Future<void> toggleHaptic() async {
    _hapticEnabled = !_hapticEnabled;
    if (_hapticEnabled) HapticFeedback.lightImpact();
    await _saveSettings();
    notifyListeners();
  }
  
  Future<void> toggleSound() async {
    _soundEnabled = !_soundEnabled;
    if (_hapticEnabled) HapticFeedback.lightImpact();
    await _saveSettings();
    notifyListeners();
  }

  Future<void> toggleAutoPreview() async {
    _autoPreview = !_autoPreview;
    if (_hapticEnabled) HapticFeedback.lightImpact();
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setDecimalPrecision(int value) async {
    _decimalPrecision = value.clamp(0, 12);
    await _saveSettings();
    // Re-format current result immediately
    _formatResult();
    notifyListeners();
  }

  Future<void> setMaxHistoryItems(int value) async {
    _maxHistoryItems = value.clamp(10, 200);
    if (_history.length > _maxHistoryItems) {
      _history = _history.take(_maxHistoryItems).toList();
      await _saveHistory();
    }
    await _saveSettings();
    notifyListeners();
  }
  
  void input(String value) {
    if (_hapticEnabled) HapticFeedback.selectionClick();
    if (_soundEnabled) {
      // Lightweight click without extra dependencies
      SystemSound.play(SystemSoundType.click);
    }
    
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
        _calculate();
        break;
      case '+/-':
        _toggleSign();
        break;
      case '%':
        _percentage();
        break;
      case 'π':
        _addToExpression('3.141592653589793');
        break;
      case 'e':
        _addToExpression('2.718281828459045');
        break;
      case 'x²':
        _power(2);
        break;
      case 'x³':
        _power(3);
        break;
      case '√':
        _squareRoot();
        break;
      case '∛':
        _cubeRoot();
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
        _addToExpression('^');
        break;
      case 'MC':
        memoryClear();
        break;
      case 'MR':
        memoryRecall();
        break;
      case 'M+':
        memoryAdd();
        break;
      case 'M-':
        memorySubtract();
        break;
      case '+':
      case '-':
      case '×':
      case '÷':
        _addOperator(value);
        break;
      case '.':
        _addDecimalPoint();
        break;
      case '(':
      case ')':
        _addToExpression(value);
        break;
      default:
        // It's a number
        _addNumber(value);
        break;
    }
    
    // Auto-calculate for preview
    if (_autoPreview && _expression.isNotEmpty && !_endsWithOperator()) {
      _calculatePreview();
    }
    
    notifyListeners();
  }
  
  bool _endsWithOperator() {
    if (_expression.isEmpty) return false;
    final lastChar = _expression[_expression.length - 1];
    return ['+', '-', '×', '÷', '^', '('].contains(lastChar);
  }
  
  bool _isOperator(String value) {
    return ['+', '-', '×', '÷', '^'].contains(value);
  }
  
  void _addNumber(String number) {
    if (_showResult) {
      _expression = '';
      _showResult = false;
    }
    
    // Don't allow multiple zeros at the start
    if (_expression == '0' && number == '0') {
      return;
    }
    
    // Replace single zero with the number
    if (_expression == '0') {
      _expression = number;
    } else {
      _expression += number;
    }
  }
  
  void _addOperator(String operator) {
    if (_showResult) {
      _expression = _result;
      _showResult = false;
    }
    
    if (_expression.isEmpty || _expression == '0') {
      if (operator == '-') {
        _expression = '-';
      }
      return;
    }
    
    // Don't add operator after another operator (except minus after other operators)
    if (_endsWithOperator()) {
      if (operator == '-' && _expression[_expression.length - 1] != '-') {
        _expression += operator;
      } else {
        // Replace the last operator
        _expression = _expression.substring(0, _expression.length - 1) + operator;
      }
    } else {
      _expression += operator;
    }
    
    _lastOperator = operator;
  }
  
  void _addDecimalPoint() {
    if (_showResult) {
      _expression = '0.';
      _showResult = false;
      return;
    }
    
    // Check if we can add a decimal point
    String currentNumber = _getCurrentNumber();
    if (!currentNumber.contains('.')) {
      if (_expression.isEmpty || _endsWithOperator()) {
        _expression += '0.';
      } else {
        _expression += '.';
      }
    }
  }
  
  String _getCurrentNumber() {
    if (_expression.isEmpty) return '0';
    
    // Find the last operator
    int lastOperatorIndex = -1;
    for (int i = _expression.length - 1; i >= 0; i--) {
      if (_isOperator(_expression[i])) {
        lastOperatorIndex = i;
        break;
      }
    }
    
    if (lastOperatorIndex == -1) {
      return _expression;
    } else {
      return _expression.substring(lastOperatorIndex + 1);
    }
  }
  
  void _addToExpression(String value) {
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
        _calculatePreview();
      }
    }
  }
  
  void _toggleSign() {
    String currentNumber = _getCurrentNumber();
    if (currentNumber.isNotEmpty && currentNumber != '0') {
      // Find where the current number starts
      int start = _expression.length - currentNumber.length;
      
      if (currentNumber.startsWith('-')) {
        // Remove the negative sign
        _expression = _expression.substring(0, start) + 
                      currentNumber.substring(1);
      } else {
        // Add negative sign
        _expression = '${_expression.substring(0, start)}-$currentNumber';
      }
      
      if (!_endsWithOperator()) {
        _calculatePreview();
      }
    }
  }
  
  void _percentage() {
    String currentNumber = _getCurrentNumber();
    if (currentNumber.isNotEmpty && currentNumber != '0') {
      try {
        double value = double.parse(currentNumber);
        String percentValue = (value / 100).toString();
        
        int start = _expression.length - currentNumber.length;
        _expression = _expression.substring(0, start) + percentValue;
        
        _calculatePreview();
      } catch (e) {
        // Handle error
      }
    }
  }
  
  void _power(int exponent) {
    String currentNumber = _getCurrentNumber();
    if (currentNumber.isNotEmpty) {
      try {
        double value = double.parse(currentNumber);
        double result = 1;
        for (int i = 0; i < exponent; i++) {
          result *= value;
        }
        
        int start = _expression.length - currentNumber.length;
        _expression = _expression.substring(0, start) + result.toString();
        _formatExpression();
        _calculatePreview();
      } catch (e) {
        // Handle error
      }
    }
  }
  
  void _squareRoot() {
    String currentNumber = _getCurrentNumber();
    if (currentNumber.isNotEmpty) {
      try {
        double value = double.parse(currentNumber);
        if (value >= 0) {
          double result = _calculatorLogic.sqrt(value);
          
          int start = _expression.length - currentNumber.length;
          _expression = _expression.substring(0, start) + result.toString();
          _formatExpression();
          _calculatePreview();
        }
      } catch (e) {
        // Handle error
      }
    }
  }
  
  void _cubeRoot() {
    String currentNumber = _getCurrentNumber();
    if (currentNumber.isNotEmpty) {
      try {
        double value = double.parse(currentNumber);
        double result = _calculatorLogic.cubeRoot(value);
        
        int start = _expression.length - currentNumber.length;
        _expression = _expression.substring(0, start) + result.toString();
        _formatExpression();
        _calculatePreview();
      } catch (e) {
        // Handle error
      }
    }
  }
  
  void _factorial() {
    String currentNumber = _getCurrentNumber();
    if (currentNumber.isNotEmpty) {
      try {
        int value = int.parse(double.parse(currentNumber).toInt().toString());
        if (value >= 0 && value <= 20) {
          int result = _calculatorLogic.factorial(value);
          
          int start = _expression.length - currentNumber.length;
          _expression = _expression.substring(0, start) + result.toString();
          _calculatePreview();
        }
      } catch (e) {
        // Handle error
      }
    }
  }
  
  void _scientificFunction(String function) {
    String currentNumber = _getCurrentNumber();
    if (currentNumber.isNotEmpty) {
      try {
        double value = double.parse(currentNumber);
        double result;
        
        switch (function) {
          case 'sin':
            result = _calculatorLogic.sin(value, degrees: _useDegrees);
            break;
          case 'cos':
            result = _calculatorLogic.cos(value, degrees: _useDegrees);
            break;
          case 'tan':
            result = _calculatorLogic.tan(value, degrees: _useDegrees);
            break;
          case 'sin⁻¹':
            result = _calculatorLogic.asin(value, degrees: _useDegrees);
            break;
          case 'cos⁻¹':
            result = _calculatorLogic.acos(value, degrees: _useDegrees);
            break;
          case 'tan⁻¹':
            result = _calculatorLogic.atan(value, degrees: _useDegrees);
            break;
          case 'ln':
            result = _calculatorLogic.ln(value);
            break;
          case 'log':
            result = _calculatorLogic.log(value);
            break;
          case 'eˣ':
            result = _calculatorLogic.exp(value);
            break;
          case '10ˣ':
            result = _calculatorLogic.pow10(value);
            break;
          default:
            result = value;
        }
        
        int start = _expression.length - currentNumber.length;
        _expression = _expression.substring(0, start) + result.toString();
        _formatExpression();
        _calculatePreview();
      } catch (e) {
        // Handle error
      }
    }
  }
  
  void _calculatePreview() {
    if (_expression.isEmpty || _endsWithOperator()) return;
    
    String expr = _expression.replaceAll('×', '*').replaceAll('÷', '/').replaceAll('^', '**');
    
    try {
      double calcResult = _calculatorLogic.evaluate(expr);
      _result = calcResult.toString();
      _formatResult();
    } catch (e) {
      // Don't show error in preview, just keep previous result
    }
  }
  
  void _calculate() {
    if (_expression.isEmpty) return;
    
    // If expression ends with operator, remove it
    String expr = _expression;
    if (_endsWithOperator()) {
      expr = expr.substring(0, expr.length - 1);
    }
    
    if (expr.isEmpty) return;
    
    expr = expr.replaceAll('×', '*').replaceAll('÷', '/').replaceAll('^', '**');
    
    try {
      double calcResult = _calculatorLogic.evaluate(expr);
      
      // Add to history
      String historyEntry = '$_expression = ${calcResult.toString()}';
      _history.insert(0, historyEntry);
      if (_history.length > _maxHistoryItems) {
        _history = _history.take(_maxHistoryItems).toList();
      }
      _saveHistory();
      
      _result = calcResult.toString();
      _formatResult();
      _showResult = true;
      
      // Don't clear expression, keep it visible
    } catch (e) {
      _result = 'Error';
      _showResult = true;
    }
  }
  
  void _formatExpression() {
    // Format numbers in expression if needed
    // This is kept simple for now
  }
  
  void _formatResult() {
    if (_result.contains('.')) {
      double? value = double.tryParse(_result);
      if (value != null && value == value.toInt()) {
        _result = value.toInt().toString();
      } else if (value != null) {
        // Limit decimals based on user preference
        _result = value.toStringAsFixed(_decimalPrecision);
        // Remove trailing zeros
        _result = _result.replaceAll(RegExp(r'0+$'), '');
        if (_result.endsWith('.')) {
          _result = _result.substring(0, _result.length - 1);
        }
      }
    }
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _hapticEnabled = prefs.getBool(_prefsKeyHaptic) ?? true;
    _soundEnabled = prefs.getBool(_prefsKeySound) ?? false;
    _useDegrees = prefs.getBool(_prefsKeyDegrees) ?? true;
    _autoPreview = prefs.getBool(_prefsKeyAutoPreview) ?? true;
    _maxHistoryItems = prefs.getInt(_prefsKeyMaxHistory) ?? 80;
    _decimalPrecision = prefs.getInt(_prefsKeyPrecision) ?? 10;
    _memory = prefs.getDouble(_prefsKeyMemory) ?? 0;

    _history = prefs.getStringList(_prefsKeyHistory) ?? <String>[];
    if (_history.length > _maxHistoryItems) {
      _history = _history.take(_maxHistoryItems).toList();
    }

    notifyListeners();
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKeyHistory, _history);
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKeyHaptic, _hapticEnabled);
    await prefs.setBool(_prefsKeySound, _soundEnabled);
    await prefs.setBool(_prefsKeyDegrees, _useDegrees);
    await prefs.setBool(_prefsKeyAutoPreview, _autoPreview);
    await prefs.setInt(_prefsKeyMaxHistory, _maxHistoryItems);
    await prefs.setInt(_prefsKeyPrecision, _decimalPrecision);
    await prefs.setDouble(_prefsKeyMemory, _memory);
  }
  
  void clearHistory() {
    _history.clear();
    _saveHistory();
    notifyListeners();
  }

  Future<void> deleteHistoryItem(int index) async {
    if (index < 0 || index >= _history.length) return;
    _history.removeAt(index);
    await _saveHistory();
    notifyListeners();
  }
  
  void useHistoryResult(String entry) {
    if (entry.contains('=')) {
      List<String> parts = entry.split('=');
      _expression = parts[0].trim();
      _result = parts[1].trim();
      _showResult = true;
      notifyListeners();
    }
  }
  
  void copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    if (_hapticEnabled) HapticFeedback.mediumImpact();
  }

  // Memory register actions
  Future<void> memoryClear() async {
    _memory = 0;
    if (_hapticEnabled) HapticFeedback.lightImpact();
    await _saveSettings();
    notifyListeners();
  }

  Future<void> memoryRecall() async {
    if (_showResult) {
      _expression = '';
      _showResult = false;
    }
    _addToExpression(_memory.toString());
    if (_autoPreview && _expression.isNotEmpty && !_endsWithOperator()) {
      _calculatePreview();
    }
    await _saveSettings();
    notifyListeners();
  }

  Future<void> memoryAdd() async {
    final v = double.tryParse(_result);
    if (v != null) {
      _memory += v;
      if (_hapticEnabled) HapticFeedback.lightImpact();
      await _saveSettings();
      notifyListeners();
    }
  }

  Future<void> memorySubtract() async {
    final v = double.tryParse(_result);
    if (v != null) {
      _memory -= v;
      if (_hapticEnabled) HapticFeedback.lightImpact();
      await _saveSettings();
      notifyListeners();
    }
  }
}
