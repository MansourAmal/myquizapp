import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:myquizapp/controllers/CategoryController.dart';
import 'package:myquizapp/controllers/question_controller.dart';
import 'package:myquizapp/views/admin/admin_screen.dart';
import '../../models/category_model.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final QuestionController questionController = Get.put(QuestionController());
    final CategoryController categoryController = Get.put(CategoryController());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        centerTitle: true,
        backgroundColor: const Color(0xFF264653),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          SvgPicture.asset(
            "assets/bg.svg",
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Obx(() {
              if (categoryController.savedCategories.isEmpty) {
                return const Center(
                  child: Text(
                    "Aucune catégorie disponible.",
                    style: TextStyle(fontSize: 18, color: Color(0xFF2a9d8f)),
                  ),
                );
              }

              return ListView.builder(
                itemCount: categoryController.savedCategories.length,
                itemBuilder: (context, index) {
                  final Category category = categoryController.savedCategories[index];
                  return _buildCategoryCard(context, category, categoryController);
                },
              );
            }),
          ),
        ],
      ),

      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            backgroundColor: const Color(0xFF2a9d8f),
            onPressed: () => _showAddCategoryDialog(context, categoryController),
            child: const Icon(Icons.add, color: Colors.white),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            backgroundColor: const Color(0xFF2ec4b6),
            onPressed: () => _showDateSearchDialog(context, categoryController),
            child: const Icon(Icons.search, color: Colors.white),
          ),
        ],
      ),

    );
  }

  Widget _buildCategoryCard(BuildContext context, Category category, CategoryController controller) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: const Color(0xFF2ec4b6),
      child: ListTile(
        onTap: () => Get.to(() => QuestionPage(category: category)),        title: Text(
          category.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF264653),
          ),
        ),
        subtitle: Text(
          category.description ?? "Description indisponible",
          style: const TextStyle(color: Color(0xFF2a9d8f)),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Color(0xFF3a86ff)),
              onPressed: () => _showEditCategoryDialog(context, controller, category),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Color(0xFFf94144)),
              onPressed: () async {
                final confirm = await _showDeleteConfirmationDialog(context);
                if (confirm == true) {
                  await _handleDeleteCategory(controller, category);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleDeleteCategory(CategoryController controller, Category category) async {
    try {
      await controller.deleteCategoryFromBackend(category.id!);
      Fluttertoast.showToast(
        msg: "Catégorie supprimée avec succès",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Erreur lors de la suppression : $e",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  void _showAddCategoryDialog(BuildContext context, CategoryController controller) {
    TextEditingController titleController = TextEditingController();
    TextEditingController subtitleController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF003049),
          title: const Text(
            "Ajouter une catégorie",
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField("Titre de la catégorie", titleController),
              _buildTextField("Sous-titre", subtitleController),
            ],
          ),
          actions: [
            _buildCancelButton(context),
            _buildSubmitButton(
              context,
              onPressed: () async {
                if (titleController.text.isNotEmpty) {
                  await _handleAddCategory(controller, titleController.text, subtitleController.text);
                  Navigator.of(context).pop();
                } else {
                  Fluttertoast.showToast(
                    msg: "Veuillez remplir tous les champs",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
      ),
      style: const TextStyle(color: Colors.white),
    );
  }

  TextButton _buildCancelButton(BuildContext context) {
    return TextButton(
      onPressed: () => Navigator.of(context).pop(),
      child: const Text("Annuler", style: TextStyle(color: Color(0xFF264653))),
    );
  }

  ElevatedButton _buildSubmitButton(BuildContext context, {required VoidCallback onPressed}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF264653)),
      onPressed: onPressed,
      child: const Text("Créer"),
    );
  }

  Future<void> _handleAddCategory(CategoryController controller, String title, String subtitle) async {
    try {
      // Appel à l'API pour ajouter la catégorie
      await controller.addCategoryToBackend(title, subtitle);

      // Rafraîchissement de la liste des catégories après ajout
      await controller.loadCategoriesFromBackend();

      Fluttertoast.showToast(
        msg: "Catégorie ajoutée avec succès",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Erreur lors de l'ajout : $e",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
    }




  Future<bool?> _showDeleteConfirmationDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFd62828),
          title: const Text(
            "Confirmer la suppression",
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            "Êtes-vous sûr de vouloir supprimer cette catégorie ?",
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            _buildCancelButton(context),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF264653)),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("Oui"),
            ),
          ],
        );
      },
    );
  }
}


  void _showEditCategoryDialog(BuildContext context, CategoryController controller, Category category) {
    TextEditingController titleController = TextEditingController(text: category.name);
    TextEditingController subtitleController = TextEditingController(text: category.description);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF264653),
          title: const Text(
            "Modifier la catégorie",
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: "Titre de la catégorie",
                  labelStyle: TextStyle(color: Colors.white),
                ),
              ),
              TextField(
                controller: subtitleController,
                decoration: const InputDecoration(
                  labelText: "Sous-titre",
                  labelStyle: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Annuler", style: TextStyle(color: Color(0xFF264653))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF264653)),
              onPressed: () async {
                if (titleController.text.isNotEmpty) {
                  try {
                    await controller.updateCategoryOnBackend(
                      category.id!,
                      titleController.text.trim(),
                      subtitleController.text.trim(),
                    );
                    Navigator.of(context).pop();
                    Fluttertoast.showToast(
                      msg: "Catégorie mise à jour avec succès!",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                    );
                  } catch (e) {
                    Fluttertoast.showToast(
                      msg: "Échec de la mise à jour de la catégorie. Essayez à nouveau.",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                    );
                  }
                } else {
                  Fluttertoast.showToast(
                    msg: "Veuillez remplir tous les champs",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                  );
                }
              },
              child: const Text("Mettre à jour"),
            ),
          ],
        );
      },
    );
  }


  Future<bool?> _showDeleteConfirmationDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF264653),
          title: const Text(
            "Confirmer la suppression",
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            "Êtes-vous sûr de vouloir supprimer cette catégorie ?",
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Non",
                  style: TextStyle(color: Color(0xFF264653))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF264653)),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("Oui"),
            ),
          ],
        );
      },
    );
  }

  void _showDateSearchDialog(BuildContext context, CategoryController controller) {
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF003049),
          title: const Text(
            "Rechercher par date",
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null) {
                    selectedDate = pickedDate;
                  }
                },
                child: const Text("Sélectionner une date"),
              ),
            ],
          ),
          actions: [
            _buildCancelButton(context),
            TextButton(
              onPressed: () async {
                if (selectedDate != null) {
                  await controller.searchCategoriesByDate(selectedDate!);
                  Navigator.of(context).pop();
                } else {
                  Fluttertoast.showToast(
                    msg: "Veuillez sélectionner une date.",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                  );
                }
              },
              child: const Text("Rechercher", style: TextStyle(color: Colors.green)),
            ),
          ],
        );
      },
    );
  }


}
