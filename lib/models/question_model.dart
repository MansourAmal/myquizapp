class QuestionModel {
  final String question;
  final List<String> options;
  final int correctAnswer;
  final String category;

  QuestionModel({
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.category,
  });

  Map<String, dynamic> toJson() {
    return {
      'text': question,
      'options': options,
      'correctAnswer': correctAnswer,
      'category': category,
    };
  }

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      question: json['text'],
      options: List<String>.from(json['options']),
      correctAnswer: json['correctAnswer'],
      category: json['category'],
    );
  }
}
