// =============================================================================
// FILE START: lib/data/models/app_script.dart
// =============================================================================
/// Supabase `scripts` jadvalidagi yozuv modeli
/// (title/info — tillar bo'yicha JSONB map).
library;

import 'package:kompyuter_sirlari/imports.dart';

class AppScript {
  const AppScript({
    required this.id,
    required this.title,
    required this.info,
    required this.code,
    required this.os,
    required this.category,
    required this.isDangerous,
  });

  final dynamic id;
  final Map<String, String> title;
  final Map<String, String> info;
  final String code;
  final String os;
  final String category;
  final bool isDangerous;

  factory AppScript.fromJson(Map<String, dynamic> json) => AppScript(
    id: json['id'],
    title: _stringMap(json['title']),
    info: _stringMap(json['info']),
    code: json['code']?.toString() ?? '',
    os: json['os']?.toString() ?? 'windows',
    category: json['category']?.toString() ?? 'optimization',
    isDangerous: json['is_dangerous'] == true,
  );

  String titleFor(String lang) => LocalizedText.resolve(title, lang);

  String infoFor(String lang) => LocalizedText.resolve(info, lang);

  IconData get osIcon =>
      os == 'linux' ? Icons.terminal_rounded : Icons.window_rounded;

  static Map<String, String> _stringMap(dynamic raw) {
    if (raw is Map) {
      return raw.map(
        (key, value) => MapEntry(key.toString(), value?.toString() ?? ''),
      );
    }
    if (raw is String) return {'uz': raw};
    return const {};
  }
}

/// Skript yaratish/tahrirlash uchun DTO.
class ScriptDraft {
  const ScriptDraft({
    required this.title,
    required this.info,
    required this.code,
    required this.os,
    required this.category,
    required this.isDangerous,
  });

  final Map<String, String> title;
  final Map<String, String> info;
  final String code;
  final String os;
  final String category;
  final bool isDangerous;

  /// DB-ga yozish uchun payload.
  Map<String, dynamic> toPayload() => {
    'title': title,
    'info': info,
    'code': code,
    'os': os,
    'category': category,
    'is_dangerous': isDangerous,
  };
}
// =============================================================================
// FILE END: lib/data/models/app_script.dart
// =============================================================================
