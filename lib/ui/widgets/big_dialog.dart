import 'package:flutter/material.dart';

import '../../core/app_strings.dart';
import 'expressive_button.dart';

Future<bool?> showBigDialog(
  BuildContext context, {
  required IconData icon,
  required String title,
  required String body,
  required String primary,
  String? secondary,
  bool danger = false,
}) {
  return showGeneralDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierLabel: AppStrings.close,
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 380),
    pageBuilder: (c, _, __) {
      final cs = Theme.of(c).colorScheme;
      final tt = Theme.of(c).textTheme;
      return Dialog(
        backgroundColor: cs.surfaceContainerHigh,
        insetPadding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 700),
                curve: Curves.elasticOut,
                builder: (_, v, child) =>
                    Transform.scale(scale: v, child: child),
                child: Container(
                  height: 96,
                  width: 96,
                  decoration: BoxDecoration(
                    color: danger ? cs.errorContainer : cs.primaryContainer,
                    borderRadius: BorderRadius.circular(34),
                  ),
                  child: Icon(icon,
                      size: 50,
                      color: danger
                          ? cs.onErrorContainer
                          : cs.onPrimaryContainer),
                ),
              ),
              const SizedBox(height: 22),
              Text(title,
                  textAlign: TextAlign.center,
                  style: tt.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              Text(body,
                  textAlign: TextAlign.center,
                  style: tt.bodyLarge
                      ?.copyWith(color: cs.onSurfaceVariant)),
              const SizedBox(height: 26),
              ExpressiveButton(
                  label: primary,
                  kind: danger ? BtnKind.danger : BtnKind.filled,
                  onPressed: () => Navigator.pop(c, true)),
              if (secondary != null) ...[
                const SizedBox(height: 10),
                ExpressiveButton(
                    label: secondary,
                    kind: BtnKind.tonal,
                    onPressed: () => Navigator.pop(c, false)),
              ],
            ]),
          ),
        ),
      );
    },
    transitionBuilder: (c, a, _, child) => FadeTransition(
      opacity: CurvedAnimation(parent: a, curve: Curves.easeOut),
      child: ScaleTransition(
        scale: Tween(begin: .85, end: 1.0)
            .animate(CurvedAnimation(parent: a, curve: Curves.easeOutBack)),
        child: child,
      ),
    ),
  );
}

const sheetShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(40)));
