import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum BtnKind { filled, tonal, danger }

class ExpressiveButton extends StatefulWidget {
  const ExpressiveButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.kind = BtnKind.filled,
    this.busy = false,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final BtnKind kind;
  final bool busy;

  @override
  State<ExpressiveButton> createState() => _ExpressiveButtonState();
}

class _ExpressiveButtonState extends State<ExpressiveButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final style = switch (widget.kind) {
      BtnKind.filled => null,
      BtnKind.tonal => FilledButton.styleFrom(
          backgroundColor: cs.secondaryContainer,
          foregroundColor: cs.onSecondaryContainer),
      BtnKind.danger => FilledButton.styleFrom(
          backgroundColor: cs.errorContainer,
          foregroundColor: cs.onErrorContainer),
    };
    final enabled = widget.onPressed != null && !widget.busy;
    return Listener(
      onPointerDown: (_) => setState(() => _down = true),
      onPointerUp: (_) => setState(() => _down = false),
      onPointerCancel: (_) => setState(() => _down = false),
      child: AnimatedScale(
        scale: _down && enabled ? .95 : 1,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutBack,
        child: FilledButton(
          style: style,
          onPressed: enabled
              ? () {
                  HapticFeedback.mediumImpact();
                  widget.onPressed!();
                }
              : null,
          child: widget.busy
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.5))
              : Row(mainAxisSize: MainAxisSize.min, children: [
                  if (widget.icon != null) ...[
                    Icon(widget.icon),
                    const SizedBox(width: 10),
                  ],
                  Flexible(
                      child:
                          Text(widget.label, textAlign: TextAlign.center)),
                ]),
        ),
      ),
    );
  }
}
