import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/app_locale.dart';
import 'core/app_strings.dart';
import 'core/app_theme.dart';
import 'cubit/app_cubit.dart';
import 'cubit/appearance_cubit.dart';
import 'cubit/locale_cubit.dart';
import 'ui/root.dart';

class SolarApp extends StatelessWidget {
  const SolarApp({
    super.key,
    required this.localeCubit,
    required this.appearanceCubit,
  });

  final LocaleCubit localeCubit;
  final AppearanceCubit appearanceCubit;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: localeCubit),
        BlocProvider.value(value: appearanceCubit),
        BlocProvider(create: (_) => AppCubit()),
      ],
      child: BlocBuilder<LocaleCubit, AppLocale>(
        builder: (context, _) {
          return BlocBuilder<AppearanceCubit, AppearanceState>(
            builder: (context, appearance) {
              return DynamicColorBuilder(
                builder: (lightDyn, darkDyn) {
                  final seed = appearance.accent.seed;
                  final useDyn = appearance.accent == AccentTheme.solar;
                  final light = (useDyn ? lightDyn?.harmonized() : null) ??
                      ColorScheme.fromSeed(seedColor: seed);
                  final dark = (useDyn ? darkDyn?.harmonized() : null) ??
                      ColorScheme.fromSeed(
                          seedColor: seed, brightness: Brightness.dark);
                  return MaterialApp(
                    title: AppStrings.appName,
                    debugShowCheckedModeBanner: false,
                    theme: buildAppTheme(
                        scheme: light, font: appearance.font),
                    darkTheme: buildAppTheme(
                        scheme: dark, font: appearance.font),
                    themeMode: appearance.themeMode,
                    home: const Root(),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
