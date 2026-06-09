class Answer {
  final String id;
  final String questionId;
  final String answer;
  final DateTime createdAt;

  Answer({
    required this.id,
    required this.questionId,
    required this.answer,
    required this.createdAt,
  });

  factory Answer.fromJson(Map<String, dynamic> json) {
    return Answer(
      id: json['id'] as String,
      questionId: json['question_id'] as String,
      answer: json['answer'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
