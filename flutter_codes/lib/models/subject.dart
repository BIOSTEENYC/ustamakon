import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'category.dart';

@HiveType(typeId: 0)
class Subject extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String iconUrl;

  @HiveField(3)
  final String topicListUrl;

  @HiveField(4)
  List<Category> categories;

  @HiveField(5)
  final String emoji;

  Subject({
    required this.id,
    required this.name,
    required this.iconUrl,
    required this.topicListUrl,
    this.categories = const [],
    this.emoji = '',
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'] as String? ?? md5.convert(utf8.encode(json['name'] as String? ?? UniqueKey().toString())).toString(),
      name: json['name'] as String? ?? 'Noma\'lum Fan',
      iconUrl: json['icon_url'] as String? ?? '',
      topicListUrl: json['topic_list_url'] as String? ?? '',
      emoji: json['emoji'] as String? ?? '',
      categories: [],
    );
  }
}