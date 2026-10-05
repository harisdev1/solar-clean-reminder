import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/app_locale.dart';
import '../core/app_theme.dart';

class AppearanceState {
  const AppearanceState({
    this.themeMode = ThemeMode.system,
    this.accent = AccentTheme.solar,
    this.font = AppFont.outfit,
  });

  final ThemeMode themeMode;
  final AccentTheme accent;
  final AppFont font;

  AppearanceState copyWith({
    ThemeMode? themeMode,
    AccentTheme? accent,
    AppFont? font,
  }) =>
      AppearanceState(
        themeMode: themeMode ?? this.themeMode,
        accent: accent ?? this.accent,
        font: font ?? this.font,
      );
}

class AppearanceCubit extends Cubit<AppearanceState> {
  AppearanceCubit() : super(const AppearanceState());

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    emit(AppearanceState(
      themeMode: themeModeFromPrefs(p.getString(PrefKeys.themeMode)),
      accent: AccentTheme.fromPrefs(p.getString(PrefKeys.accent)),
      font: AppFont.fromPrefs(p.getString(PrefKeys.font)),
    ));
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    emit(state.copyWith(themeMode: mode));
    final p = await SharedPreferences.getInstance();
    await p.setString(PrefKeys.themeMode, themeModeToPrefs(mode));
  }

  Future<void> setAccent(AccentTheme accent) async {
    emit(state.copyWith(accent: accent));
    final p = await SharedPreferences.getInstance();
    await p.setString(PrefKeys.accent, accent.prefsValue);
  }

  Future<void> setFont(AppFont font) async {
    emit(state.copyWith(font: font));
    final p = await SharedPreferences.getInstance();
    await p.setString(PrefKeys.font, font.prefsValue);
  }
}
