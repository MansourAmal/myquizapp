import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/question_model.dart';

class QuestionController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    //loadQuestionCategoryFromSharedPreferences();
    loadAllQuestionsFromStorage();
  }

  final RxList<QuestionModel> _questions = <QuestionModel>[].obs;
  List<QuestionModel> get questions => _questions;

  final String _categoryKey = "category_title";
  final String _subtitleKey = "subtitle";

  final TextEditingController categoryTitleController = TextEditingController();
  final TextEditingController categorySubtitleController = TextEditingController();

  final RxList<String> savedCategories = <String>[].obs;
  final RxList<String> savedSubtitles = <String>[].obs;

  // Méthodes pour charger et sauvegarder les questions depuis le stockage
  void loadAllQuestionsFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _questions.clear();

      for (var category in savedCategories) {
        final questionList = prefs.getStringList(category) ?? [];
        for (var questionJson in questionList) {
          final question = QuestionModel.fromJson(jsonDecode(questionJson));
          _questions.add(question);
        }
      }
      update();
    } catch (e) {
      Get.snackbar("Erreur", "Échec du chargement des questions : $e");
    }
  }

  // Récupérer les questions d'une catégorie
  List<Map<String, dynamic>> getQuestionsByCategory(String category) {
    return _questions
        .where((question) => question.category == category)
        .map((q) => q.toJson())
        .toList();
  }

  // Supprimer une question
  Future<void> deleteQuestion(String category, int index) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Charger les questions de la catégorie
      List<String> questionList = prefs.getStringList(category) ?? [];
      if (index < questionList.length) {
        questionList.removeAt(index);
        await prefs.setStringList(category, questionList);
      }

      // Mettre à jour la liste locale
      _questions.removeWhere(
              (q) => q.category == category && _questions.indexOf(q) == index);

      update();
    } catch (e) {
      Get.snackbar("Erreur", "Échec de la suppression : $e");
    }
  }

  // Mettre à jour une question existante
  Future<void> updateQuestion(
      String category,
      int index,
      String newText,
      List<String> newOptions,
      int newCorrectAnswer,
      ) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Charger les questions existantes
      List<String> questionList = prefs.getStringList(category) ?? [];
      if (index < questionList.length) {
        final updatedQuestion = QuestionModel(
          question: newText,
          options: newOptions,
          correctAnswer: newCorrectAnswer,
          category: category,
        );
        questionList[index] = jsonEncode(updatedQuestion.toJson());
        await prefs.setStringList(category, questionList);
      }

      // Mettre à jour la liste locale
      _questions[index] = QuestionModel(
        question: newText,
        options: newOptions,
        correctAnswer: newCorrectAnswer,
        category: category,
      );

      update();
    } catch (e) {
      Get.snackbar("Erreur", "Échec de la mise à jour : $e");
    }
  }

  // Ajouter une nouvelle question
  Future<void> addQuestion(
      String category,
      String questionText,
      List<String> options,
      int correctAnswer,
      ) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Créer une nouvelle question
      final newQuestion = QuestionModel(
        question: questionText,
        options: options,
        correctAnswer: correctAnswer,
        category: category,
      );

      // Ajouter au stockage local
      _questions.add(newQuestion);

      // Ajouter au stockage partagé
      List<String> questionList = prefs.getStringList(category) ?? [];
      questionList.add(jsonEncode(newQuestion.toJson()));
      await prefs.setStringList(category, questionList);

      update();
    } catch (e) {
      Get.snackbar("Erreur", "Échec de l'ajout de la question : $e");
    }
  }
}
