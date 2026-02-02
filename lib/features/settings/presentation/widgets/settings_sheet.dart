import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_themes.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../features/calculator/presentation/controllers/calculator_controller.dart';

class SettingsSheet extends StatelessWidget {
  const SettingsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();
    final calc = context.watch<CalculatorController>();
    final scheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Customize', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Themes', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final t in AppThemes.all)
                  _ThemeChip(
                    name: t.name,
                    selected: themeController.themeId == t.id,
                    onTap: () => themeController.setTheme(t.id),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            Divider(color: scheme.outline.withOpacity(0.35)),
            const SizedBox(height: 10),
            _ToggleTile(
              title: 'Haptic feedback',
              subtitle: 'Tactile clicks on key press',
              value: calc.hapticEnabled,
              onChanged: (_) => calc.toggleHaptic(),
              icon: Icons.vibration_rounded,
            ),
            _ToggleTile(
              title: 'Sound feedback',
              subtitle: 'System click sound on press',
              value: calc.soundEnabled,
              onChanged: (_) => calc.toggleSound(),
              icon: Icons.volume_up_rounded,
            ),
            _ToggleTile(
              title: 'Scientific mode',
              subtitle: 'Show advanced keys (sin, log, …)',
              value: calc.isScientificEnabled,
              onChanged: (_) => calc.toggleScientific(),
              icon: Icons.science_rounded,
            ),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }
}

class _ThemeChip extends StatelessWidget {
  const _ThemeChip({
    required this.name,
    required this.selected,
    required this.onTap,
  });

  final String name;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? scheme.primary.withOpacity(0.18) : scheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? scheme.primary : scheme.outline.withOpacity(0.25)),
        ),
        child: Text(
          name,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: selected ? scheme.primary : scheme.onSurface,
              ),
        ),
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  const _ToggleTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: scheme.secondary.withOpacity(0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: scheme.secondary.withOpacity(0.22)),
        ),
        child: Icon(icon, color: scheme.secondary),
      ),
      title: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
      subtitle: Text(subtitle),
      trailing: Switch.adaptive(value: value, onChanged: onChanged),
      onTap: () => onChanged(!value),
    );
  }
}
