import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/calculator_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/calc_button.dart';
import 'history_screen.dart';

class CalculatorScreen extends StatelessWidget {
  const CalculatorScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            _buildDisplay(context),
            Expanded(
              child: _buildButtonGrid(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final calcProvider = Provider.of<CalculatorProvider>(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(
                  calcProvider.isScientificMode 
                    ? Icons.calculate 
                    : Icons.science,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onPressed: () => calcProvider.toggleScientificMode(),
                tooltip: calcProvider.isScientificMode 
                  ? 'Basic Mode' 
                  : 'Scientific Mode',
              ),
              IconButton(
                icon: Icon(
                  Icons.history,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const HistoryScreen(),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        const begin = Offset(0.0, 1.0);
                        const end = Offset.zero;
                        const curve = Curves.easeOutCubic;

                        var tween = Tween(begin: begin, end: end).chain(
                          CurveTween(curve: curve),
                        );

                        return SlideTransition(
                          position: animation.drive(tween),
                          child: child,
                        );
                      },
                    ),
                  );
                },
                tooltip: 'History',
              ),
              IconButton(
                icon: Icon(
                  calcProvider.hapticEnabled 
                    ? Icons.vibration 
                    : Icons.phone_android,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
                onPressed: () => calcProvider.toggleHaptic(),
                tooltip: 'Toggle Haptic',
              ),
            ],
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            child: IconButton(
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return ScaleTransition(
                    scale: animation,
                    child: child,
                  );
                },
                child: Icon(
                  themeProvider.isDarkMode 
                    ? Icons.light_mode 
                    : Icons.dark_mode,
                  key: ValueKey(themeProvider.isDarkMode),
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              onPressed: () => themeProvider.toggleTheme(),
              tooltip: 'Toggle Theme',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisplay(BuildContext context) {
    final calcProvider = Provider.of<CalculatorProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Expression display
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            reverse: true,
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                fontSize: calcProvider.showResult ? 20 : _calculateFontSize(calcProvider.expression, screenWidth),
                fontWeight: FontWeight.w400,
                color: calcProvider.showResult 
                  ? Theme.of(context).colorScheme.onSurface.withOpacity(0.6)
                  : Theme.of(context).colorScheme.onSurface,
              ),
              child: GestureDetector(
                onLongPress: () {
                  calcProvider.copyToClipboard(calcProvider.expression);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Expression copied'),
                      duration: const Duration(seconds: 1),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                  );
                },
                child: Text(calcProvider.expression),
              ),
            ),
          ),
          
          // Result display (shown when equals is pressed or during preview)
          if (calcProvider.result != '0' || calcProvider.showResult) ...[
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutBack,
                style: Theme.of(context).textTheme.displayLarge!.copyWith(
                  fontSize: calcProvider.showResult 
                    ? _calculateFontSize(calcProvider.result, screenWidth)
                    : 24,
                  fontWeight: calcProvider.showResult ? FontWeight.w500 : FontWeight.w300,
                  color: calcProvider.showResult 
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
                child: GestureDetector(
                  onLongPress: () {
                    calcProvider.copyToClipboard(calcProvider.result);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Result copied'),
                        duration: const Duration(seconds: 1),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                      ),
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (calcProvider.showResult)
                        Text(
                          '= ',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      Text(calcProvider.result),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  double _calculateFontSize(String text, double screenWidth) {
    if (text.length <= 6) return 48;
    if (text.length <= 10) return 36;
    if (text.length <= 14) return 28;
    return 24;
  }

  Widget _buildButtonGrid(BuildContext context) {
    final calcProvider = Provider.of<CalculatorProvider>(context);
    
    if (calcProvider.isScientificMode) {
      return _buildScientificButtons(context);
    } else {
      return _buildBasicButtons(context);
    }
  }

  Widget _buildBasicButtons(BuildContext context) {
    final buttons = [
      ['AC', 'C', 'DEL', '÷'],
      ['7', '8', '9', '×'],
      ['4', '5', '6', '-'],
      ['1', '2', '3', '+'],
      ['0', '.', '+/-', '='],
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: buttons.map((row) {
          return Expanded(
            child: Row(
              children: row.map((button) {
                return Expanded(
                  flex: button == '0' ? 2 : 1,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: CalcButton(
                      text: button,
                      onPressed: () {
                        context.read<CalculatorProvider>().input(button);
                      },
                      type: _getButtonType(button),
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildScientificButtons(BuildContext context) {
    final buttons = [
      ['(', ')', 'π', 'e', 'AC'],
      ['sin', 'cos', 'tan', '%', 'DEL'],
      ['sin⁻¹', 'cos⁻¹', 'tan⁻¹', 'ln', 'log'],
      ['x²', 'x³', 'xʸ', '√', '∛'],
      ['n!', 'eˣ', '10ˣ', '+/-', '÷'],
      ['7', '8', '9', '×', ''],
      ['4', '5', '6', '-', ''],
      ['1', '2', '3', '+', ''],
      ['0', '.', '=', '', ''],
    ];

    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: buttons.map((row) {
          return Expanded(
            child: Row(
              children: row.map((button) {
                if (button.isEmpty) {
                  return const Expanded(child: SizedBox());
                }
                return Expanded(
                  flex: button == '0' ? 2 : 1,
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: CalcButton(
                      text: button,
                      onPressed: () {
                        context.read<CalculatorProvider>().input(button);
                      },
                      type: _getButtonType(button),
                      isScientific: true,
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }

  ButtonType _getButtonType(String button) {
    if (button == '=') return ButtonType.equals;
    if (['AC', 'C', 'DEL'].contains(button)) return ButtonType.clear;
    if (['+', '-', '×', '÷', '%', '+/-'].contains(button)) return ButtonType.operator;
    if (['sin', 'cos', 'tan', 'sin⁻¹', 'cos⁻¹', 'tan⁻¹', 'ln', 'log',
         'x²', 'x³', 'xʸ', '√', '∛', 'n!', 'eˣ', '10ˣ', 'π', 'e', '(', ')']
        .contains(button)) return ButtonType.scientific;
    return ButtonType.number;
  }
}
