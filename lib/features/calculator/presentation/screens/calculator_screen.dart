import 'package:flutter/material.dart';
import 'package:mathify/features/calculator/presentation/screens/notes_list_screen.dart';
import 'package:provider/provider.dart';

import '../controllers/calculator_controller.dart';
import '../widgets/calc_key.dart';
import '../widgets/display_panel.dart';
import '../../../settings/presentation/widgets/settings_sheet.dart';
import 'history_screen.dart';

class CalculatorScreen extends StatelessWidget {
  const CalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final calc = context.watch<CalculatorController>();
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(

        title:
        Icon(Icons.calculate),
  //       Image.asset("assets/app_icon_calc.png",height: 30,width: 30,
  // ),
       // const Text('CalcPad'),
        actions: [
             IconButton(
      tooltip: 'Add Notes',
      icon: const Icon(Icons.note_add_rounded),
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const NotesListScreen(),
          ),
        );
      },
    ),

          IconButton(
            tooltip: 'Customize',
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              showDragHandle: true,
              backgroundColor: Theme.of(context).colorScheme.surface,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
              ),
              builder: (_) => const SettingsSheet(),
            ),
            icon: const Icon(Icons.tune_rounded),
          ),
    
        ],
      ),
     
      body: Padding(
        // padding: const EdgeInsets.all(0),
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
        child: Column(
          children: [
            // Image.asset("assets/icon/logo_mathify.png",height: 50,width: 50,),
            GestureDetector(
              onHorizontalDragEnd: (details) {
                // Swipe left to backspace, swipe right to clear expression
                final v = details.primaryVelocity ?? 0;
                if (v < -240) {
                  calc.backspace();
                } else if (v > 380) {
                  calc.clearExpression();
                }
              },
              child: DisplayPanel(
                expression: calc.expression,
                result: calc.result,
                onCopy: () {
                  calc.copyResultToClipboard();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Result copied'),
                      duration: const Duration(milliseconds: 900),
                      backgroundColor: scheme.primary.withOpacity(0.85),
                    ),
                  );
                },
                onHistory: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const HistoryScreen()),
                ),
                hint: 'Swipe ← delete | Swipe → clear',
              ),
            ),
            const SizedBox(height: 12),
           // if (calc.isScientificEnabled)
             _ScientificStrip(onKey: calc.onKey),
            const SizedBox(height: 10),
            Expanded(
              child: _KeyPad(
                isScientificEnabled: true,
                onKey: calc.onKey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScientificStrip extends StatelessWidget {
  const _ScientificStrip({required this.onKey});

  final ValueChanged<String> onKey;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final keys = const [
      'sin',
      'cos',
      'tan',
      'ln',
      'log',
      'x²',
      'x³',
      'xʸ',
      '√',
      '∛',
      'n!',
      'π',
      'e',
      '(',
      ')',
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.outline.withOpacity(0.25)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final k in keys) ...[
              _ChipKey(
                label: k,
                onTap: () => onKey(k),
              ),
              const SizedBox(width: 10),
            ],
          ],
        ),
      ),
    );
  }
}

class _ChipKey extends StatelessWidget {
  const _ChipKey({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: scheme.secondary.withOpacity(0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: scheme.secondary.withOpacity(0.22)),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: scheme.secondary,
              ),
        ),
      ),
    );
  }
}

class _KeyPad extends StatelessWidget {
  const _KeyPad({
    required this.onKey,
    required this.isScientificEnabled,
  });

  final ValueChanged<String> onKey;
  final bool isScientificEnabled;

  @override
  Widget build(BuildContext context) {
    // Layout intentionally non-standard: operators are in a vertical rail on the right.
    return LayoutBuilder(
      builder: (context, constraints) {
        // final maxHeight = constraints.maxHeight;
        // final isShort = maxHeight < 420;

        return Row(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        CalcKey(
                          label: 'C',
                          style: CalcKeyStyle.action,
                          onTap: () => onKey('C'),
                          onLongPress: () => onKey('AC'),
                          subtitle: 'hold: AC',
                        ),
                        CalcKey(
                          label: 'DEL',
                          style: CalcKeyStyle.action,
                          onTap: () => onKey('DEL'),
                          onLongPress: () => onKey('AC'),
                          subtitle: 'hold: AC',
                        ),
                        CalcKey(
                          label: '%',
                          style: CalcKeyStyle.operator,
                          onTap: () => onKey('%'),
                        ),
                        
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        CalcKey(label: '7', onTap: () => onKey('7')),
                        CalcKey(label: '8', onTap: () => onKey('8')),
                        CalcKey(label: '9', onTap: () => onKey('9')),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        CalcKey(label: '4', onTap: () => onKey('4')),
                        CalcKey(label: '5', onTap: () => onKey('5')),
                        CalcKey(label: '6', onTap: () => onKey('6')),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        CalcKey(label: '1', onTap: () => onKey('1')),
                        CalcKey(label: '2', onTap: () => onKey('2')),
                        CalcKey(label: '3', onTap: () => onKey('3')),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        CalcKey(
                          label: '0',
                          flex: 2,
                          onTap: () => onKey('0'),
                        ),
                        CalcKey(
                          label: '.',
                          onTap: () => onKey('.'),
                        ),
                        
                      ],
                    ),
                  ),
                 
                    // const SizedBox(height: 2),
                    Expanded(
                      child: Row(
                        children: [
                          CalcKey(
                            label: '+/-',
                            style: CalcKeyStyle.operator,
                            onTap: () => onKey('+/-'),
                          ),
                          CalcKey(
                            label: '(',
                            style: CalcKeyStyle.operator,
                            onTap: () => onKey('('),
                          ),
                          CalcKey(
                            label: ')',
                            style: CalcKeyStyle.operator,
                            onTap: () => onKey(')'),
                          ),
                        ],
                      ),
                    ),
                  ],
                
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CalcKey(
                    
                    label: '÷',
                    style: CalcKeyStyle.operator,
                    onTap: () => onKey('÷'),
                  ),
                  CalcKey(
                    label: '×',
                    style: CalcKeyStyle.operator,
                    onTap: () => onKey('×'),
                  ),
                  CalcKey(
                    label: '−',
                    style: CalcKeyStyle.operator,
                    onTap: () => onKey('-'),
                  ),
                  CalcKey(
                    label: '+',
                    style: CalcKeyStyle.operator,
                    onTap: () => onKey('+'),
                  ),
                  CalcKey(
                    label: '=',
                    style: CalcKeyStyle.equals,
                    onTap: () => onKey('='),
                    onLongPress: () => onKey('='),
                    subtitle: isScientificEnabled ? 'solve' : null,
                  ),
                ],
              ),
            ),
          
          ],
        );
      },
    );
  }
}
