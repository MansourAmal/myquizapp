import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/category_model.dart';
import '../models/question_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class QuestionController extends GetxController {
  @override
  void onInit() {
    super.onInit();
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

  /*// Charger les catégories depuis SharedPreferences
  Future<void> loadCategoriesFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    savedCategories.value = prefs.getStringList('categories') ?? [];
    savedSubtitles.value = prefs.getStringList('subtitles') ?? [];
    update();
  }*/

  // Sauvegarder les catégories et les sous-titres dans SharedPreferences
  Future<void> _saveCategories() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('categories', savedCategories);
    await prefs.setStringList('subtitles', savedSubtitles);
  }

  /*// Ajouter une catégorie
  void addCategory(String title, String subtitle) {
    // Ajouter la catégorie dans l'API
    addCategoryToBackend(title, subtitle);

    // Ensuite, ajouter la catégorie localement dans SharedPreferences
    savedCategories.add(title);
    savedSubtitles.add(subtitle);
    _saveCategories();
    update();
  }*/








  // Modifier une catégorie
  void updateCategory(int index, String title, String subtitle) {
    savedCategories[index] = title;
    savedSubtitles[index] = subtitle;
    _saveCategories();
    update();
  }

 /* // Supprimer une catégorie
  void removeCategory(int index) {
    savedCategories.removeAt(index);
    savedSubtitles.removeAt(index);
    _saveCategories();
    update();
  }*/






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
      Category category,
      int index,
      String newText,
      List<String> newOptions,
      int newCorrectAnswer,
      ) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Charger les questions existantes
      List<String> questionList = prefs.getStringList(category.name) ?? [];
      if (index < questionList.length) {
        final updatedQuestion = QuestionModel(
          question: newText,
          options: newOptions,
          correctAnswer: newCorrectAnswer,
          category: category,
        );
        questionList[index] = jsonEncode(updatedQuestion.toJson());
        await prefs.setStringList(category.name, questionList);
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

  Future<void> addQuestion(
      Category category,
      String questionText,
      List<String> options,
      int correctAnswer,
      ) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Créer une nouvelle question avec la catégorie correcte
      final newQuestion = QuestionModel(
        question: questionText,
        options: options,
        correctAnswer: correctAnswer,
        category: category, // Utiliser directement la catégorie passée en paramètre
      );

      // Ajouter au stockage local
      _questions.add(newQuestion);

      // Récupérer la liste de questions de la catégorie depuis SharedPreferences
      List<String> questionList = prefs.getStringList(category.id.toString()) ?? [];
      questionList.add(jsonEncode(newQuestion.toJson()));

      // Sauvegarder la liste mise à jour dans SharedPreferences
      await prefs.setStringList(category.id.toString(), questionList);

      update();
    } catch (e) {
      Get.snackbar("Erreur", "Échec de l'ajout de la question : $e");
    }
  }



}
