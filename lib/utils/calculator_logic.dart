import 'dart:math' as math;

class CalculatorLogic {
  // Basic arithmetic operations
  double add(double a, double b) => a + b;
  double subtract(double a, double b) => a - b;
  double multiply(double a, double b) => a * b;
  double divide(double a, double b) {
    if (b == 0) throw Exception('Division by zero');
    return a / b;
  }
  
  // Power operations
  double power(double base, double exponent) => math.pow(base, exponent).toDouble();
  double sqrt(double value) => math.sqrt(value);
  double cubeRoot(double value) => math.pow(value, 1/3).toDouble();
  
  // Trigonometric functions (input in radians)
  double sin(double value) => math.sin(value * math.pi / 180);
  double cos(double value) => math.cos(value * math.pi / 180);
  double tan(double value) => math.tan(value * math.pi / 180);
  
  // Inverse trigonometric functions (output in radians)
  double asin(double value) {
    if (value < -1 || value > 1) throw Exception('Invalid input for asin');
    return math.asin(value) * 180 / math.pi;
  }
  
  double acos(double value) {
    if (value < -1 || value > 1) throw Exception('Invalid input for acos');
    return math.acos(value) * 180 / math.pi;
  }
  
  double atan(double value) => math.atan(value) * 180 / math.pi;
  
  // Logarithmic functions
  double ln(double value) {
    if (value <= 0) throw Exception('Invalid input for ln');
    return math.log(value);
  }
  
  double log(double value) {
    if (value <= 0) throw Exception('Invalid input for log');
    return math.log(value) / math.ln10;
  }
  
  // Exponential functions
  double exp(double value) => math.exp(value);
  double pow10(double value) => math.pow(10, value).toDouble();
  
  // Factorial
  int factorial(int n) {
    if (n < 0) throw Exception('Factorial of negative number');
    if (n == 0 || n == 1) return 1;
    int result = 1;
    for (int i = 2; i <= n; i++) {
      result *= i;
    }
    return result;
  }
  
  // Expression evaluation
  double evaluate(String expression) {
    try {
      // Remove spaces
      expression = expression.replaceAll(' ', '');
      
      // Handle special cases
      if (expression.isEmpty) return 0;
      if (expression == 'Error') throw Exception('Invalid expression');
      
      // Simple expression parser
      // This is a basic implementation - for production, use a proper expression parser
      return _evaluateExpression(expression);
    } catch (e) {
      throw Exception('Invalid expression');
    }
  }
  
  double _evaluateExpression(String expression) {
    // Handle parentheses first
    while (expression.contains('(')) {
      int start = expression.lastIndexOf('(');
      int end = expression.indexOf(')', start);
      if (end == -1) throw Exception('Mismatched parentheses');
      
      String subExpression = expression.substring(start + 1, end);
      double result = _evaluateExpression(subExpression);
      expression = expression.substring(0, start) + result.toString() + expression.substring(end + 1);
    }
    
    // Handle power operations (**)
    while (expression.contains('**')) {
      int index = expression.indexOf('**');
      
      // Find the left operand
      int leftStart = index - 1;
      while (leftStart > 0 && (_isDigit(expression[leftStart - 1]) || expression[leftStart - 1] == '.')) {
        leftStart--;
      }
      if (leftStart > 0 && expression[leftStart - 1] == '-') leftStart--;
      
      // Find the right operand
      int rightEnd = index + 2;
      if (rightEnd < expression.length && expression[rightEnd] == '-') rightEnd++;
      while (rightEnd < expression.length && (_isDigit(expression[rightEnd]) || expression[rightEnd] == '.')) {
        rightEnd++;
      }
      
      double left = double.parse(expression.substring(leftStart, index));
      double right = double.parse(expression.substring(index + 2, rightEnd));
      double result = power(left, right);
      
      expression = expression.substring(0, leftStart) + result.toString() + expression.substring(rightEnd);
    }
    
    // Handle multiplication and division
    expression = _evaluateMultiplicationDivision(expression);
    
    // Handle addition and subtraction
    expression = _evaluateAdditionSubtraction(expression);
    
    return double.parse(expression);
  }
  
  String _evaluateMultiplicationDivision(String expression) {
    while (expression.contains('*') || expression.contains('/')) {
      int multiplyIndex = expression.indexOf('*');
      int divideIndex = expression.indexOf('/');
      
      // Skip ** operator
      if (multiplyIndex > 0 && multiplyIndex + 1 < expression.length && expression[multiplyIndex + 1] == '*') {
        multiplyIndex = expression.indexOf('*', multiplyIndex + 2);
      }
      
      int index;
      String operator;
      
      if (multiplyIndex == -1) {
        index = divideIndex;
        operator = '/';
      } else if (divideIndex == -1) {
        index = multiplyIndex;
        operator = '*';
      } else {
        if (multiplyIndex < divideIndex) {
          index = multiplyIndex;
          operator = '*';
        } else {
          index = divideIndex;
          operator = '/';
        }
      }
      
      if (index == -1) break;
      
      // Find the left operand
      int leftStart = index - 1;
      while (leftStart > 0 && (_isDigit(expression[leftStart - 1]) || expression[leftStart - 1] == '.')) {
        leftStart--;
      }
      if (leftStart > 0 && expression[leftStart - 1] == '-' && (leftStart == 1 || !_isDigit(expression[leftStart - 2]))) {
        leftStart--;
      }
      
      // Find the right operand
      int rightEnd = index + 1;
      if (rightEnd < expression.length && expression[rightEnd] == '-') rightEnd++;
      while (rightEnd < expression.length && (_isDigit(expression[rightEnd]) || expression[rightEnd] == '.')) {
        rightEnd++;
      }
      
      double left = double.parse(expression.substring(leftStart, index));
      double right = double.parse(expression.substring(index + 1, rightEnd));
      double result = operator == '*' ? multiply(left, right) : divide(left, right);
      
      expression = expression.substring(0, leftStart) + result.toString() + expression.substring(rightEnd);
    }
    
    return expression;
  }
  
  String _evaluateAdditionSubtraction(String expression) {
    // Handle leading negative sign
    int startIndex = 0;
    if (expression.startsWith('-')) {
      startIndex = 1;
    }
    
    while (expression.substring(startIndex).contains('+') || expression.substring(startIndex).contains('-')) {
      int addIndex = expression.indexOf('+', startIndex);
      int subtractIndex = startIndex;
      
      // Find the next subtraction that's not a negative sign
      while (subtractIndex < expression.length) {
        subtractIndex = expression.indexOf('-', subtractIndex + 1);
        if (subtractIndex == -1) break;
        if (subtractIndex > 0 && _isDigit(expression[subtractIndex - 1])) break;
      }
      
      int index;
      String operator;
      
      if (addIndex == -1) {
        if (subtractIndex == -1) break;
        index = subtractIndex;
        operator = '-';
      } else if (subtractIndex == -1) {
        index = addIndex;
        operator = '+';
      } else {
        if (addIndex < subtractIndex) {
          index = addIndex;
          operator = '+';
        } else {
          index = subtractIndex;
          operator = '-';
        }
      }
      
      if (index == -1) break;
      
      // Find the left operand
      int leftStart = index - 1;
      while (leftStart > 0 && (_isDigit(expression[leftStart - 1]) || expression[leftStart - 1] == '.')) {
        leftStart--;
      }
      if (leftStart > 0 && expression[leftStart - 1] == '-' && (leftStart == 1 || !_isDigit(expression[leftStart - 2]))) {
        leftStart--;
      }
      
      // Find the right operand
      int rightEnd = index + 1;
      if (rightEnd < expression.length && expression[rightEnd] == '-') rightEnd++;
      while (rightEnd < expression.length && (_isDigit(expression[rightEnd]) || expression[rightEnd] == '.')) {
        rightEnd++;
      }
      
      double left = double.parse(expression.substring(leftStart, index));
      double right = double.parse(expression.substring(index + 1, rightEnd));
      double result = operator == '+' ? add(left, right) : subtract(left, right);
      
      expression = expression.substring(0, leftStart) + result.toString() + expression.substring(rightEnd);
    }
    
    return expression;
  }
  
  bool _isDigit(String char) {
    return char.codeUnitAt(0) >= 48 && char.codeUnitAt(0) <= 57;
  }
}
