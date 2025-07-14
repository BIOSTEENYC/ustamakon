import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'guide.dart';

@HiveType(typeId: 1)
class Category extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String iconEmoji;

  @HiveField(3)
  List<Guide> guides;

  Category({
    required this.id,
    required this.name,
    required this.iconEmoji,
    this.guides = const [],
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    String categoryName = json['category_name'] as String? ?? 'Noma\'lum Kategoriya';
    String icon = json['icon_emoji'] as String? ?? '❓';
    return Category(
      id: md5.convert(utf8.encode(categoryName)).toString(),
      name: categoryName,
      iconEmoji: icon,
      guides: (json['guides'] as List<dynamic>?)
          ?.map((guideJson) => Guide.fromJson(guideJson as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }
}