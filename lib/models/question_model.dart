import 'category_model.dart';

class QuestionModel {
  final int id;
  final String text;
  final List<String> options;
  final int correctAnswer;
  final Category category; // Modèle imbriqué

  QuestionModel({
    required this.id,
    required this.text,
    required this.options,
    required this.correctAnswer,
    required this.category,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'options': options,
      'correctAnswer': correctAnswer,
      'category': category.toJson(), // Convertir l'objet imbriqué
    };
  }

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] as int, // Vérifiez que `id` est un entier
      text: json['text'] as String,
      options: List<String>.from(json['options']), // Liste d'options
      correctAnswer: json['correctAnswer'] as int, // Indice entier
      category: Category.fromJson(json['category']), // Création de l'objet Category
    );
  }
}
