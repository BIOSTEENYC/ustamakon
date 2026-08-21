// =============================================================================
// FILE START: lib/core/constants/fonts.dart
// =============================================================================
/// Tillar bo'yicha shriftlar (estetika).
///
/// ⚠️ Litsenziya eslatmasi:
/// - "Google Sans" va "Arial / Arial Black" Google Fonts'da YO'Q (xususiy).
///   Shuning uchun eng yaqin ochiq alternativlar ishlatiladi:
///   • Latin (uz):        PlusJakartaSans  → Google Sans'ga eng yaqin ochiq shrift
///   • Kirill (kr,tg,ky): Arimo            → Arial'ning ochiq ekvivalenti
///   • Arab (af):         NotoNastaliqUrdu → Google Nastaliq Urdu (serif, Google Fonts)
///   Agar litsenziyali GoogleSans.ttf / Arial.ttf bo'lsa — `assets/fonts/`ga solib,
///   quyidagi o'zgaruvchilarni o'zgartiring (family nomi pubspec bilan bir xil bo'lsin).
///
/// 📄 pubspec.yaml'ga qo'shish (shrift fayllarini `assets/fonts/`ga soling):
///   flutter:
///     fonts:
///       - family: PlusJakartaSans
///         fonts:
///           - asset: assets/fonts/PlusJakartaSans-variable.ttf
///       - family: Arimo
///         fonts:
///           - asset: assets/fonts/Arimo-variable.ttf
///       - family: NotoNastaliqUrdu
///         fonts:
///           - asset: assets/fonts/NotoNastaliqUrdu-variable.ttf
class AppFonts {
  AppFonts._();

  static const String latin = 'PlusJakartaSans';
  static const String arabic = 'NotoNastaliqUrdu';
  static const String cyrillic = 'Arimo';

  /// Har bir til kodi uchun shrift oilasi.
  static const Map<String, String> byLanguage = {
    'uz': latin,
    'af': arabic,
    'kr': cyrillic,
    'tg': cyrillic,
    'ky': cyrillic,
  };

  static String forLanguage(String lang) => byLanguage[lang] ?? latin;
}
// =============================================================================
// FILE END: lib/core/constants/fonts.dart
// =============================================================================