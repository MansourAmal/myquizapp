import 'category_model.dart';

class QuestionModel {
  final String question;
  final List<String> options;
  final int correctAnswer;
  final Category category;  // Utilisation de l'objet Category au lieu d'une chaîne de caractères

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
      'category': category.toJson(),  // Convertir l'objet Category en JSON
    };
  }

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      question: json['text'],
      options: List<String>.from(json['options']),
      correctAnswer: json['correctAnswer'],
      category: Category.fromJson(json['category']),  // Créer un objet Category à partir du JSON
    );
  }
}
