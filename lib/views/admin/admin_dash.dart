import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:myquizapp/controllers/question_controller.dart';
import 'package:myquizapp/views/admin/admin_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final QuestionController questionController = Get.put(QuestionController());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        centerTitle: true,
        backgroundColor: const Color(0xFF264653), // Couleur principale
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          SvgPicture.asset(
            "assets/bg.svg",
            fit: BoxFit.fitWidth,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GetBuilder<QuestionController>(
              builder: (controller) {
                if (controller.savedCategories.isEmpty) {
                  return const Center(
                    child: Text(
                      "Aucune catégorie disponible.",
                      style: TextStyle(fontSize: 18, color: Color(0xFF2a9d8f)),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: controller.savedCategories.length,
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: const Color(0xFF2ec4b6), // Couleur de fond des cartes
                      child: ListTile(
                        onTap: () {
                          Get.to(() => AdminScreen(
                              quizCategory: controller.savedCategories[index]));
                        },
                        title: Text(
                          controller.savedCategories[index],
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF264653)),
                        ),
                        subtitle: Text(
                          controller.savedSubtitles.length > index
                              ? controller.savedSubtitles[index]
                              : "Sous-titre indisponible",
                          style: const TextStyle(color: Color(0xFF2a9d8f)),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit,
                                  color: Color(0xFF3a86ff)),
                              onPressed: () {
                                _showEditCategoryDialog(
                                    context, controller, index);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete,
                                  color: Color(0xFFf94144)),
                              onPressed: () {
                                controller.savedCategories.removeAt(index);
                                controller.savedSubtitles.removeAt(index);
                                controller.update();
                                Fluttertoast.showToast(
                                    msg: "Catégorie supprimée",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2a9d8f), // Couleur du bouton flottant
        onPressed: () {
          _showAddCategoryDialog(context, questionController);
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showAddCategoryDialog(
      BuildContext context, QuestionController controller) {
    TextEditingController titleController = TextEditingController();
    TextEditingController subtitleController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF003049), // Couleur du dialogue
          title: const Text(
            "Ajouter une catégorie",
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
              child: const Text("Annuler",
                  style: TextStyle(color: Color(0xFF264653))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF264653)),
              onPressed: () {
                if (titleController.text.isNotEmpty &&
                    subtitleController.text.isNotEmpty) {
                  controller.savedCategories.add(titleController.text);
                  controller.savedSubtitles.add(subtitleController.text);
                  controller.update();

                  Navigator.of(context).pop();
                  Fluttertoast.showToast(
                    msg: "Catégorie ajoutée avec succès",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                  );
                } else {
                  Fluttertoast.showToast(
                    msg: "Veuillez remplir tous les champs",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                  );
                }
              },
              child: const Text("Créer"),
            ),
          ],
        );
      },
    );
  }

  void _showEditCategoryDialog(
      BuildContext context, QuestionController controller, int index) {
    TextEditingController titleController =
    TextEditingController(text: controller.savedCategories[index]);
    TextEditingController subtitleController =
    TextEditingController(text: controller.savedSubtitles[index]);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2ec4b6),
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
              child: const Text("Annuler",
                  style: TextStyle(color: Color(0xFF264653))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF264653)),
              onPressed: () {
                if (titleController.text.isNotEmpty &&
                    subtitleController.text.isNotEmpty) {
                  controller.savedCategories[index] = titleController.text;
                  controller.savedSubtitles[index] = subtitleController.text;
                  controller.update();

                  Navigator.of(context).pop();
                  Fluttertoast.showToast(
                    msg: "Catégorie modifiée avec succès",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                  );
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
}
