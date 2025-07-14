import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:hive_flutter/hive_flutter.dart';

@HiveType(typeId: 2)
class Guide extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String iconEmoji;

  @HiveField(3)
  final String documentUrl;

  @HiveField(4) // Yangi maydon: oflayn rejim uchun
  bool isDownloaded;

  Guide({
    required this.id,
    required this.title,
    required this.iconEmoji,
    required this.documentUrl,
    this.isDownloaded = false, // Default qiymat
  });

  factory Guide.fromJson(Map<String, dynamic> json) {
    String guideTitle = json['title'] as String? ?? 'Noma\'lum Mavzu';
    String icon = json['icon_emoji'] as String? ?? '📄';
    String docUrl = json['document_url'] as String? ?? '';
    return Guide(
      id: md5.convert(utf8.encode(guideTitle + docUrl)).toString(),
      title: guideTitle,
      iconEmoji: icon,
      documentUrl: docUrl,
      isDownloaded: false, // JSON dan o'qilganda default false
    );
  }
}