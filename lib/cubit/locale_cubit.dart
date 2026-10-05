import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/app_locale.dart';
import '../core/app_strings.dart';

class LocaleCubit extends Cubit<AppLocale> {
  LocaleCubit() : super(AppLocale.romanUrdu);

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    final locale = AppLocale.fromPrefs(p.getString(PrefKeys.locale));
    AppStrings.setLocale(locale);
    emit(locale);
  }

  Future<void> setLocale(AppLocale locale) async {
    AppStrings.setLocale(locale);
    emit(locale);
    final p = await SharedPreferences.getInstance();
    await p.setString(PrefKeys.locale, locale.prefsValue);
  }
}
