class Guide {
  final String title;
  final String iconEmoji;
  final String documentUrl;

  Guide({
    required this.title,
    required this.iconEmoji,
    required this.documentUrl,
  });

  factory Guide.fromJson(Map<String, dynamic> json) {
    return Guide(
      title: json['title'] as String,
      iconEmoji: json['icon_emoji'] as String,
      documentUrl: json['document_url'] as String,
    );
  }
}
