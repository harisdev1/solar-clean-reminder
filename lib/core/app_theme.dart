import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum AccentTheme {
  solar(Color(0xFFFFB300)),
  ocean(Color(0xFF1E88E5)),
  leaf(Color(0xFF43A047)),
  ember(Color(0xFFFF7043)),
  teal(Color(0xFF00897B)),
  rose(Color(0xFFD81B60));

  const AccentTheme(this.seed);
  final Color seed;

  String get prefsValue => name;

  static AccentTheme fromPrefs(String? v) {
    for (final a in AccentTheme.values) {
      if (a.name == v) return a;
    }
    return AccentTheme.solar;
  }
}

enum AppFont {
  outfit,
  nunito,
  rubik,
  jakarta,
  sora,
  manrope;

  String get prefsValue => name;

  static AppFont fromPrefs(String? v) {
    for (final f in AppFont.values) {
      if (f.name == v) return f;
    }
    return AppFont.outfit;
  }

  TextTheme textTheme(TextTheme base) => switch (this) {
        AppFont.outfit => GoogleFonts.outfitTextTheme(base),
        AppFont.nunito => GoogleFonts.nunitoTextTheme(base),
        AppFont.rubik => GoogleFonts.rubikTextTheme(base),
        AppFont.jakarta => GoogleFonts.plusJakartaSansTextTheme(base),
        AppFont.sora => GoogleFonts.soraTextTheme(base),
        AppFont.manrope => GoogleFonts.manropeTextTheme(base),
      };

  String get label => switch (this) {
        AppFont.outfit => 'Outfit',
        AppFont.nunito => 'Nunito',
        AppFont.rubik => 'Rubik',
        AppFont.jakarta => 'Jakarta',
        AppFont.sora => 'Sora',
        AppFont.manrope => 'Manrope',
      };
}

ThemeMode themeModeFromPrefs(String? v) => switch (v) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };

String themeModeToPrefs(ThemeMode m) => switch (m) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };

ThemeData buildAppTheme({
  required ColorScheme scheme,
  required AppFont font,
}) {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
  );
  final text = font.textTheme(base.textTheme);
  return base.copyWith(
    textTheme: text,
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(60),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        textStyle: text.labelLarge?.copyWith(
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ) ??
            const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceContainerHigh,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: BorderSide.none,
      ),
    ),
    chipTheme: ChipThemeData(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
  );
}
