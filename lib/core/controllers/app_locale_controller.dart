// =============================================================================
// FILE START: lib/core/controllers/app_locale_controller.dart
// =============================================================================

import 'package:kompyuter_sirlari/imports.dart';

/// Ilova tilini global holatda ushlab turuvchi kontroller.
/// MaterialApp ildizi shu orqali kuzatiladi — `af` tanlanganda
/// butun ilova RTL rejimga o'tadi (Directionality almashadi).
class AppLocaleController {
  AppLocaleController._();
  static final instance = AppLocaleController._();

  final ValueNotifier<String> languageCode = ValueNotifier(defaultLanguageCode);

  bool get isRtl => languageCode.value == rtlLanguageCode;

  void setLanguage(String code) => languageCode.value = code;
}
// =============================================================================
// FILE END: lib/core/controllers/app_locale_controller.dart
// =============================================================================