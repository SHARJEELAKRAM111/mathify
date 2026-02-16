import 'package:flutter/material.dart';

import '../../../../core/theme/calc_tokens.dart';

enum CalcKeyStyle { number, operator, action, equals, scientific }

class CalcKey extends StatefulWidget {
  const CalcKey({
    super.key,
    required this.label,
    required this.onTap,
    this.onLongPress,
    this.style = CalcKeyStyle.number,
    this.flex = 1,
    this.icon,
    this.subtitle,
  });

  final String label;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final CalcKeyStyle style;
  final int flex;
  final IconData? icon;
  final String? subtitle;

  @override
  State<CalcKey> createState() => _CalcKeyState();
}

class _CalcKeyState extends State<CalcKey> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<CalcTokens>()!;
    final scheme = Theme.of(context).colorScheme;

    Color bg;
    Color fg;
    Color border = tokens.keyBorder.withOpacity(0.22);

    switch (widget.style) {
      case CalcKeyStyle.operator:
        bg = tokens.operatorBg;
        fg = tokens.operatorFg;
        border = tokens.operatorFg.withOpacity(0.15);
        break;
      case CalcKeyStyle.action:
        bg = tokens.actionBg;
        fg = tokens.actionFg;
        border = tokens.actionFg.withOpacity(0.18);
        break;
      case CalcKeyStyle.equals:
        bg = tokens.equalsBg;
        fg = tokens.equalsFg;
        border = Colors.transparent;
        break;
      case CalcKeyStyle.scientific:
        bg = tokens.keyBg.withOpacity(0.85);
        fg = scheme.secondary;
        border = scheme.secondary.withOpacity(0.15);
        break;
      case CalcKeyStyle.number:
        bg = tokens.keyBg;
        fg = tokens.keyFg;
        break;
    }

    final radius = BorderRadius.circular(tokens.keyRadius);
    final shadowOpacity = _pressed ? 0.0 : 1.0;

    return Expanded(
      flex: widget.flex,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        scale: _pressed ? 0.97 : 1.0,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOut,
          margin: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: radius,
            border: Border.all(color: border),
            boxShadow: [
              BoxShadow(
                color: tokens.keyShadow.withOpacity(0.22 * shadowOpacity),
                blurRadius: tokens.keyElevation,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: radius,
              onTap: widget.onTap,
              onLongPress: widget.onLongPress,
              onHighlightChanged: (v) => setState(() => _pressed = v),
              child: Padding(
                 padding: EdgeInsets.symmetric(
   // horizontal: 10,
    //vertical: widget.style == CalcKeyStyle.operator ? 22 : 12, // ✅ smaller height
  ),
               // padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                child: Center(
                  child: _KeyFace(
                    label: widget.label,
                    subtitle: widget.subtitle,
                    icon: widget.icon,
                    fg: fg,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _KeyFace extends StatelessWidget {
  const _KeyFace({
    required this.label,
    required this.fg,
    this.icon,
    this.subtitle,
  });

  final String label;
  final Color fg;
  final IconData? icon;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    if (icon != null) {
      return Icon(icon, color: fg, size: 22);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: fg,
            height: 1,
            letterSpacing: -0.4,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            subtitle!,
            style: textTheme.labelSmall?.copyWith(
              color: fg.withOpacity(0.75),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}
