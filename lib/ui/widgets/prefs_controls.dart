import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/app_locale.dart';
import '../../core/app_strings.dart';
import '../../core/app_theme.dart';
import '../../cubit/app_cubit.dart';
import '../../cubit/appearance_cubit.dart';
import '../../cubit/locale_cubit.dart';

class LanguagePicker extends StatelessWidget {
  const LanguagePicker({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleCubit>().state;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!compact) ...[
          Text(AppStrings.language,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
        ],
        SegmentedButton<AppLocale>(
          segments: [
            ButtonSegment(
              value: AppLocale.english,
              label: Text(AppStrings.english),
              icon: const Icon(Icons.language_rounded, size: 18),
            ),
            ButtonSegment(
              value: AppLocale.romanUrdu,
              label: Text(AppStrings.romanUrdu),
              icon: const Icon(Icons.translate_rounded, size: 18),
            ),
          ],
          selected: {locale},
          onSelectionChanged: (s) {
            HapticFeedback.selectionClick();
            context.read<LocaleCubit>().setLocale(s.first);
            try {
              context.read<AppCubit>().reschedule();
            } catch (_) {}
          },
        ),
      ],
    );
  }
}

/// Compact language control for setup header (toggles EN / Roman Urdu).
class LanguageToggleIcon extends StatelessWidget {
  const LanguageToggleIcon({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleCubit>().state;
    final next = locale == AppLocale.english
        ? AppLocale.romanUrdu
        : AppLocale.english;
    final badge = locale == AppLocale.english ? 'EN' : 'UR';
    return Tooltip(
      message: AppStrings.language,
      child: IconButton.filledTonal(
        onPressed: () {
          HapticFeedback.selectionClick();
          context.read<LocaleCubit>().setLocale(next);
          try {
            context.read<AppCubit>().reschedule();
          } catch (_) {}
        },
        icon: Badge(
          label: Text(badge, style: const TextStyle(fontSize: 9)),
          child: const Icon(Icons.translate_rounded),
        ),
      ),
    );
  }
}

class AppearanceControls extends StatelessWidget {
  const AppearanceControls({super.key});

  @override
  Widget build(BuildContext context) {
    final a = context.watch<AppearanceCubit>().state;
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.appearance,
            style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        Text(AppStrings.themeMode,
            style: tt.labelLarge?.copyWith(color: cs.onSurfaceVariant)),
        const SizedBox(height: 8),
        SegmentedButton<ThemeMode>(
          segments: [
            ButtonSegment(
                value: ThemeMode.system, label: Text(AppStrings.themeSystem)),
            ButtonSegment(
                value: ThemeMode.light, label: Text(AppStrings.themeLight)),
            ButtonSegment(
                value: ThemeMode.dark, label: Text(AppStrings.themeDark)),
          ],
          selected: {a.themeMode},
          onSelectionChanged: (s) {
            HapticFeedback.selectionClick();
            context.read<AppearanceCubit>().setThemeMode(s.first);
          },
        ),
        const SizedBox(height: 16),
        Text(AppStrings.accentColor,
            style: tt.labelLarge?.copyWith(color: cs.onSurfaceVariant)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 12,
          runSpacing: 10,
          children: [
            for (final accent in AccentTheme.values)
              _AccentDot(
                accent: accent,
                selected: a.accent == accent,
                label: switch (accent) {
                  AccentTheme.solar => AppStrings.accentSolar,
                  AccentTheme.ocean => AppStrings.accentOcean,
                  AccentTheme.leaf => AppStrings.accentLeaf,
                  AccentTheme.ember => AppStrings.accentEmber,
                  AccentTheme.teal => AppStrings.accentTeal,
                  AccentTheme.rose => AppStrings.accentRose,
                },
                onTap: () => context.read<AppearanceCubit>().setAccent(accent),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text(AppStrings.fontLabel,
            style: tt.labelLarge?.copyWith(color: cs.onSurfaceVariant)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (final font in AppFont.values)
              ChoiceChip(
                label: Text(font.label),
                selected: a.font == font,
                onSelected: (_) {
                  HapticFeedback.selectionClick();
                  context.read<AppearanceCubit>().setFont(font);
                },
              ),
          ],
        ),
      ],
    );
  }
}

class _AccentDot extends StatelessWidget {
  const _AccentDot({
    required this.accent,
    required this.selected,
    required this.label,
    required this.onTap,
  });

  final AccentTheme accent;
  final bool selected;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      borderRadius: BorderRadius.circular(20),
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accent.seed,
              shape: BoxShape.circle,
              border: Border.all(
                color: selected
                    ? Theme.of(context).colorScheme.onSurface
                    : Colors.transparent,
                width: 3,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                          color: accent.seed.withValues(alpha: .45),
                          blurRadius: 12,
                          spreadRadius: 1)
                    ]
                  : null,
            ),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
