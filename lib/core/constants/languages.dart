// =============================================================================
// FILE START: lib/core/constants/languages.dart
// =============================================================================
/// Qo'llab-quvvatlanadigan til metadata-si.
class AppLanguage {
  const AppLanguage({
    required this.code,
    required this.label,
    required this.shortLabel,
    required this.flag,
  });

  final String code;
  final String label;
  final String shortLabel;
  final String flag;
}

const List<AppLanguage> supportedLanguages = [
  AppLanguage(code: 'uz', label: "O'zbekcha", shortLabel: "O'zbek", flag: '🇺🇿'),
  AppLanguage(code: 'kr', label: 'Ўзбекча (Кирилл)', shortLabel: 'Ўзбек', flag: '🇺🇿'),
  AppLanguage(code: 'af', label: 'اوزبیک (Afg)', shortLabel: 'اوزبیک', flag: '🇦🇫'),
  AppLanguage(code: 'tg', label: 'Тоҷикӣ', shortLabel: 'Тоҷикӣ', flag: '🇹🇯'),
  AppLanguage(code: 'ky', label: 'Кыргызча', shortLabel: 'Кыргызча', flag: '🇰🇬'),
];

const String defaultLanguageCode = 'uz';

/// Arab yozuvida yoziladigan til — tanlanganda ilova RTL rejimga o'tadi.
const String rtlLanguageCode = 'af';
// =============================================================================
// FILE END: lib/core/constants/languages.dart
// =============================================================================