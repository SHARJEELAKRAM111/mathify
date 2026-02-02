import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/calculator_controller.dart';
import '../../domain/models/history_entry.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final calc = context.watch<CalculatorController>();
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          if (calc.history.isNotEmpty)
            IconButton(
              tooltip: 'Clear history',
              onPressed: () async {
                await calc.clearHistory();
                if (context.mounted) Navigator.of(context).maybePop();
              },
              icon: const Icon(Icons.delete_sweep_rounded),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
        child: calc.history.isEmpty
            ? _EmptyState(color: scheme.primary)
            : ListView.separated(
                itemCount: calc.history.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final entry = calc.history[index];
                  return Dismissible(
                    key: ValueKey(entry.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      decoration: BoxDecoration(
                        color: scheme.errorContainer,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      alignment: Alignment.centerRight,
                      child: Icon(Icons.delete_rounded, color: scheme.onErrorContainer),
                    ),
                    onDismissed: (_) => calc.deleteHistoryEntry(entry.id),
                    child: _HistoryCard(
                      entry: entry,
                      onTap: () {
                        calc.reuseHistory(entry);
                        Navigator.of(context).pop();
                      },
                      onLongPress: () async {
                        await calc.copyText(entry.pretty);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Copied entry')),
                          );
                        }
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({
    required this.entry,
    required this.onTap,
    required this.onLongPress,
  });

  final HistoryEntry entry;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dt = entry.createdAt;

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: scheme.outline.withOpacity(0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    entry.expression,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  _format(dt),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(color: scheme.onSurface.withOpacity(0.65)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('=', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    entry.result,
                    textAlign: TextAlign.right,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: scheme.primary,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Tap to reuse • Swipe to delete • Hold to copy',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: scheme.onSurface.withOpacity(0.6)),
            )
          ],
        ),
      ),
    );
  }

  static String _format(DateTime dt) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(dt.hour)}:${two(dt.minute)}';
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history_toggle_off_rounded, size: 64, color: color.withOpacity(0.8)),
            const SizedBox(height: 14),
            Text(
              'No calculations yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              'Your recent expressions will appear here.\nTip: long-press the "C" key for a full reset.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
