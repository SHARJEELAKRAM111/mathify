import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum ButtonType {
  number,
  operator,
  scientific,
  clear,
  equals,
}

class CalcButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final ButtonType type;
  final bool isScientific;

  const CalcButton({
    Key? key,
    required this.text,
    required this.onPressed,
    required this.type,
    this.isScientific = false,
  }) : super(key: key);

  @override
  State<CalcButton> createState() => _CalcButtonState();
}

class _CalcButtonState extends State<CalcButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getButtonColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    switch (widget.type) {
      case ButtonType.equals:
        return colorScheme.primary;
      case ButtonType.operator:
        return colorScheme.primary.withOpacity(0.15);
      case ButtonType.scientific:
        return colorScheme.secondary.withOpacity(0.1);
      case ButtonType.clear:
        return colorScheme.error.withOpacity(0.1);
      case ButtonType.number:
      return colorScheme.surface;
    }
  }

  Color _getTextColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    switch (widget.type) {
      case ButtonType.equals:
        return Colors.white;
      case ButtonType.operator:
        return colorScheme.primary;
      case ButtonType.scientific:
        return colorScheme.secondary;
      case ButtonType.clear:
        return colorScheme.error;
      case ButtonType.number:
      return colorScheme.onSurface;
    }
  }

  double _getFontSize() {
    if (widget.isScientific) {
      if (widget.text.length > 3) return 14;
      if (widget.text.length > 2) return 16;
      return 18;
    }
    
    if (widget.text == '=') return 28;
    if (widget.type == ButtonType.operator) return 24;
    return 22;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _animationController.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _animationController.reverse();
        widget.onPressed();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _animationController.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: _getButtonColor(context),
                borderRadius: BorderRadius.circular(widget.isScientific ? 12 : 16),
                border: widget.type == ButtonType.number
                    ? Border.all(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.1),
                        width: 1,
                      )
                    : null,
                boxShadow: _isPressed
                    ? []
                    : [
                        BoxShadow(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Center(
                child: Text(
                  widget.text,
                  style: GoogleFonts.poppins(
                    fontSize: _getFontSize(),
                    fontWeight: widget.type == ButtonType.equals
                        ? FontWeight.w600
                        : FontWeight.w500,
                    color: _getTextColor(context),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
