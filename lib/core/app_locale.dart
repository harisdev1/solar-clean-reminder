enum AppLocale {
  english,
  romanUrdu;

  String get prefsValue => name;

  static AppLocale fromPrefs(String? v) {
    if (v == AppLocale.english.name) return AppLocale.english;
    return AppLocale.romanUrdu;
  }
}

abstract final class PrefKeys {
  static const locale = 'app_locale';
  static const themeMode = 'theme_mode';
  static const accent = 'accent_theme';
  static const font = 'app_font';
}
