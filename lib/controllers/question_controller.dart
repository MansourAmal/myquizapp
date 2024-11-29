import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

  }

  var questions = <QuestionModel>[].obs;
  final String apiUrl = "http://localhost:8085/quiz/api/questions";


  Future<void> fetchQuestionsByCategory(int categoryId) async {
    try {
      final response = await http.get(
          Uri.parse("$apiUrl/by-category/$categoryId"));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        questions.value =
            data.map((json) => QuestionModel.fromJson(json)).toList();
      } else {
        Get.snackbar("Erreur", "Impossible de charger les questions");
      }
    } catch (e) {
      Get.snackbar("Erreur", "Une erreur s'est produite : $e");
    }
  }




  Future<void> addQuestion(QuestionModel question) async {
    try {
      final response = await http.post(
        Uri.parse("$apiUrl/add"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'text': question.text,
          'options': question.options,
          'correctAnswer': question.correctAnswer,
          'category': {
            'id': question.category.id,
            'name': question.category.name,
          },
        }),
      );

      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {  // Vérifier les deux codes de statut
        print("Succès Question ajoutée avec succès");

        // Mise à jour de la liste des questions
        if (question.category.id != null) {
          fetchQuestionsByCategory(question.category.id); // Recharger les questions
        } else {
          print("ID de catégorie invalide, impossible de recharger les questions.");
        }
      } else {
        print("Erreur côté serveur : ${response.body}");
        Get.snackbar("Erreur", "Impossible d'ajouter la question");
      }
    } catch (e) {
      print("Erreur : Une erreur s'est produite : $e");
      Get.snackbar("Erreur", "Une erreur s'est produite : $e");
    }
  }








  Future<void> updateQuestion(QuestionModel question) async {
    try {
      final response = await http.put(
        Uri.parse("$apiUrl/update/${question.id}"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(question.toJson()),
      );

      if (response.statusCode == 200) {
        Get.snackbar("Succès", "Question mise à jour avec succès");
        fetchQuestionsByCategory(question.category.id);
      } else {
        Get.snackbar("Erreur", "Impossible de mettre à jour la question");
      }
    } catch (e) {
      Get.snackbar("Erreur", "Une erreur s'est produite : $e");
    }
  }


  Future<void> deleteQuestion(int questionId, int categoryId) async {
    try {
      final response = await http.delete(
        Uri.parse("$apiUrl/delete/$questionId"),
      );

      if (response.statusCode == 200) {
        Get.snackbar("Succès", "Question supprimée avec succès");
        fetchQuestionsByCategory(categoryId); // Recharger les questions
      } else {
        Get.snackbar("Erreur", "Impossible de supprimer la question");
      }
    } catch (e) {
      Get.snackbar("Erreur", "Une erreur s'est produite : $e");
    }
  }

}