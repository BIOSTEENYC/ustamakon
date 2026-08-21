// =============================================================================
// FILE START: lib/core/utils/localized_text.dart
// =============================================================================
/// Supabase JSONB (tillar bo'yicha map) qiymatini hal qiluvchi yordamchi.
/// Tartib: tanlangan til → o'zbek → istalgan birinchi til → bo'sh string.
class LocalizedText {
  LocalizedText._();

  static String resolve(dynamic jsonb, String lang) {
    if (jsonb is Map) {
      final direct = jsonb[lang] ?? jsonb['uz'];
      if (direct != null) return direct.toString();
      for (final value in jsonb.values) {
        if (value != null) return value.toString();
      }
      return '';
    }
    return jsonb?.toString() ?? '';
  }
}
// =============================================================================
// FILE END: lib/core/utils/localized_text.dart
// =============================================================================