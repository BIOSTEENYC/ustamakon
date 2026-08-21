// =============================================================================
// FILE START: lib/data/repositories/settings_repository.dart
// =============================================================================

import 'package:kompyuter_sirlari/imports.dart';

/// SharedPreferences asosidagi foydalanuvchi sozlamalari.
class SettingsRepository {
  SettingsRepository._();
  static final instance = SettingsRepository._();

  static const _kLang = 'app_lang';
  static const _kFirstRun = 'is_first_run';

  Future<String> getLanguage() async =>
      (await SharedPreferences.getInstance()).getString(_kLang) ?? defaultLanguageCode;

  Future<void> setLanguage(String code) async =>
      (await SharedPreferences.getInstance()).setString(_kLang, code);

  Future<bool> isFirstRun() async =>
      (await SharedPreferences.getInstance()).getBool(_kFirstRun) ?? true;

  Future<void> setFirstRun(bool value) async =>
      (await SharedPreferences.getInstance()).setBool(_kFirstRun, value);
}
// =============================================================================
// FILE END: lib/data/repositories/settings_repository.dart
// =============================================================================