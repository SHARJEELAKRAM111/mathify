import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/calculator_provider.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final calc = context.watch<CalculatorProvider>();
    final theme = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Section(
            title: 'Appearance',
            children: [
              SwitchListTile.adaptive(
                value: theme.isDarkMode,
                onChanged: (_) => theme.toggleTheme(),
                title: const Text('Dark mode'),
                subtitle: const Text('Use a darker theme for low light'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _Section(
            title: 'Calculator',
            children: [
              SwitchListTile.adaptive(
                value: calc.hapticEnabled,
                onChanged: (_) => calc.toggleHaptic(),
                title: const Text('Haptic feedback'),
                subtitle: const Text('Vibration on tap'),
              ),
              SwitchListTile.adaptive(
                value: calc.soundEnabled,
                onChanged: (_) => calc.toggleSound(),
                title: const Text('Sound'),
                subtitle: const Text('Click sound on tap'),
              ),
              SwitchListTile.adaptive(
                value: calc.autoPreview,
                onChanged: (_) => calc.toggleAutoPreview(),
                title: const Text('Live preview'),
                subtitle: const Text('Show result while typing'),
              ),
              ListTile(
                title: const Text('Angle unit'),
                subtitle: Text('Currently: ${calc.angleLabel}'),
                trailing: FilledButton.tonal(
                  onPressed: () => calc.toggleAngleUnit(),
                  child: Text(calc.angleLabel),
                ),
              ),
              ListTile(
                title: const Text('Decimal precision'),
                subtitle: Text('${calc.decimalPrecision} decimals'),
              ),
              _PrecisionChips(
                value: calc.decimalPrecision,
                onChanged: (v) => calc.setDecimalPrecision(v),
              ),
              const SizedBox(height: 4),
              ListTile(
                title: const Text('Max history items'),
                subtitle: Text('${calc.maxHistoryItems} items'),
              ),
              _HistoryLimitSlider(
                value: calc.maxHistoryItems,
                onChanged: (v) => calc.setMaxHistoryItems(v),
              ),
              const Divider(height: 28),
              ListTile(
                title: const Text('Memory register'),
                subtitle: Text('M = ${_formatMemory(calc.memory)}'),
                trailing: TextButton(
                  onPressed: () => calc.memoryClear(),
                  child: const Text('Clear'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _Section(
            title: 'About',
            children: const [
              ListTile(
                title: Text('Tips'),
                subtitle: Text('• Long-press expression or result to copy\n• Swipe history items to delete\n• Use MC/MR/M+/M- in scientific mode'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _formatMemory(double m) {
    final asInt = m.toInt();
    if (m == asInt.toDouble()) return asInt.toString();
    return m.toString();
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

class _PrecisionChips extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const _PrecisionChips({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const options = [0, 2, 4, 6, 8, 10, 12];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: options
            .map(
              (o) => ChoiceChip(
                label: Text(o.toString()),
                selected: value == o,
                onSelected: (_) => onChanged(o),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _HistoryLimitSlider extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const _HistoryLimitSlider({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Slider(
        value: value.toDouble(),
        min: 20,
        max: 200,
        divisions: 18,
        label: value.toString(),
        onChanged: (v) => onChanged(v.round()),
      ),
    );
  }
}
