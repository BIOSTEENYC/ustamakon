// =============================================================================
// FILE START: lib/core/constants/app_constants.dart
// =============================================================================
/// Supabase sozlamalari — o'zingizning loyihangiz qiymatlarini kiriting.
class SupabaseConfig {
  SupabaseConfig._();
  static const String url = ' /*Supabase url manzili yozing*/ ';
  static const String anonKey = ' /*Supabaseni ANON keyini yozing*/ ';
}

/// Web admin panel paroli (xohlasangiz o'zgartiring).
class AdminConfig {
  AdminConfig._();
  static const String password = 'ustamakonadmin';
}

/// Tashqi havolalar.
class AppLinks {
  AppLinks._();
  static const String telegramDownload = 'https://t.me/biosteenyc_abdulhakim/234';
  static const String websiteDownload = 'https://biosteenyc.github.io/#/ilm';
  static const String privacyPolicy =
      'https://www.termsfeed.com/live/e377ee6a-de15-4295-a012-c0942d2479e9';
}

/// Umumiy metadata.
class AppMeta {
  AppMeta._();
  static const String appName = 'UstaMakon';
  static const String brandName = 'Biosteenyc';
  static const String engineTitle = 'UstaMakon Engine';
}
// =============================================================================
// FILE END: lib/core/constants/app_constants.dart
// =============================================================================