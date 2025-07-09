class Subject {
  final String name;
  final String emoji;
  final String topicListUrl;

  Subject({
    required this.name,
    required this.emoji,
    required this.topicListUrl,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      name: json['name'] as String,
      emoji: json['emoji'] as String,
      topicListUrl: json['topic_list_url'] as String,
    );
  }
}
