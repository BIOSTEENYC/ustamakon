import 'guide.dart';

class Category {
  final String categoryName;
  final String iconEmoji;
  final List<Guide> guides;

  // Zamonaviy UI uchun qo'shimcha maydonlar
  final String? id;
  final String? name;
  final String? description;

  Category({
    required this.categoryName,
    required this.iconEmoji,
    required this.guides,
    this.id,
    this.name,
    this.description,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    var guidesList = json['guides'] as List;
    return Category(
      categoryName: json['category_name'] as String,
      iconEmoji: json['icon_emoji'] as String,
      guides: guidesList.map((i) => Guide.fromJson(i)).toList(),
      id: json['id']?.toString(),
      name: json['name'] as String?,
      description: json['description'] as String?,
    );
  }
}
