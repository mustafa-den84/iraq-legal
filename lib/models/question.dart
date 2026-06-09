class Question {
  final String id;
  final String question;
  final String lang;
  final DateTime createdAt;

  Question({
    required this.id,
    required this.question,
    required this.lang,
    required this.createdAt,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String,
      question: json['question'] as String,
      lang: json['lang'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
