import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/category_model.dart';

class CategoryController extends GetxController {

  var savedCategories = <Category>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadCategoriesFromBackend();
  }

  //final RxList<String> savedCategories = <String>[].obs;
  final RxList<String> savedSubtitles = <String>[].obs;
  final RxList<int> savedCategoryIds = <int>[].obs;

  final String _categoryKey = "categories";
  final String _subtitleKey = "subtitles";

  Future<void> loadCategoriesFromBackend() async {
    try {
      final response = await http.get(
          Uri.parse('http://localhost:8085/quiz/api/categories/all'));

      if (response.statusCode == 200) {
        final List<dynamic> categories = jsonDecode(response.body);

        // Mettre à jour la liste des catégories dans l'interface utilisateur
        savedCategories.value = categories.map((categoryJson) {
          return Category.fromJson(categoryJson);
        }).toList();

        // Assurez-vous de rafraîchir l'interface avec `update()`
        update();
      } else {
        Get.snackbar("Erreur", "Impossible de charger les catégories depuis le serveur.");
      }
    } catch (e) {
      Get.snackbar("Erreur", "Une erreur s'est produite : $e");
    }
  }



  Future<void> addCategoryToBackend(String title, String subtitle) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:8085/quiz/api/categories/add'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': title,
          'description': subtitle,
        }),
      );



      // Mettez à jour l'UI avec le nouvel état
      update(); // Cela rafraîchira l'UI

      print('Statut HTTP: ${response.statusCode}');
      print('Corps de la réponse: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('Catégorie ajoutée avec succès');
      } else {
        print('Échec de l\'ajout de la catégorie : ${response.statusCode}');
        print('Message du serveur : ${response.body}');
      }
    } catch (e) {
      print('Erreur lors de l\'appel à l\'API : $e');
    }
  }

  Future<void> deleteCategoryFromBackend(int categoryid) async {
    try {
      final response = await http.delete(
        Uri.parse('http://localhost:8085/quiz/api/categories/delete/$categoryid'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        await loadCategoriesFromBackend();
        // La catégorie a été supprimée avec succès, mettez à jour la liste locale
        savedCategories.removeWhere((cat) => cat.id == categoryid);
        int index = savedCategories.indexWhere((cat) => cat.id == categoryid);
        if (index != -1) {
          savedSubtitles.removeAt(index);
        }
        // Mettez à jour l'UI avec la nouvelle liste
        update();
        print("suppression avec succées");

      } else {
        print("Échec de la suppression de la catégorie.");
      }
    } catch (e) {
      print("Une erreur s'est produite lors de la suppression : $e");
    }
  }

  Future<void> updateCategoryOnBackend(int id, String title, String subtitle) async {
    try {
      final response = await http.put(
        Uri.parse('http://localhost:8085/quiz/api/categories/update/$id'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': title,
          'description': subtitle,
        }),
      );

      if (response.statusCode == 200) {
        print('Catégorie mise à jour avec succès');
        await loadCategoriesFromBackend(); // Rafraîchir les catégories après mise à jour

      } else {
        print('Échec de la mise à jour de la catégorie : ${response.statusCode}');

      }
    } catch (e) {
      print('Erreur lors de la mise à jour : $e');

    }
  }


}