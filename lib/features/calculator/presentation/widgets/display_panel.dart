import 'package:flutter/material.dart';

import '../../../../core/theme/calc_tokens.dart';

class DisplayPanel extends StatelessWidget {
  const DisplayPanel({
    super.key,
    required this.expression,
    required this.result,
    required this.onCopy,
    required this.onHistory,
    this.hint,
  });

  final String expression;
  final String result;
  final VoidCallback onCopy;
  final VoidCallback onHistory;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<CalcTokens>()!;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
      decoration: BoxDecoration(
        color: tokens.displayBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: scheme.outline.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.calculate_rounded, size: 18, color: scheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  hint ?? 'Expression',
                  style: textTheme.labelMedium?.copyWith(
                    color: scheme.onSurface.withOpacity(0.7),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'History',
                onPressed: onHistory,
                icon: Icon(Icons.history_rounded, color: scheme.onSurface),
              ),
              IconButton(
                tooltip: 'Copy result',
                onPressed: onCopy,
                icon: Icon(Icons.copy_rounded, color: scheme.onSurface),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            expression,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: textTheme.titleMedium?.copyWith(
              color: tokens.displayFg.withOpacity(0.85),
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            result,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: textTheme.displaySmall?.copyWith(
              color: tokens.displayFg,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
            ),
          ),
        ],
      ),
    );
  }
}
