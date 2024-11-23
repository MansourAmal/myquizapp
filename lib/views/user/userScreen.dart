import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:myquizapp/controllers/CategoryController.dart';
import 'package:myquizapp/views/user/quizScreen.dart';

import '../../controllers/question_controller.dart';

class UserScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Charger les catégories depuis l'API au démarrage
    final QuestionController questionController = Get.put(QuestionController());
    final CategoryController categoryController = Get.put(CategoryController());

    categoryController.loadCategoriesFromBackend();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sélectionnez une catégorie'),
        centerTitle: true,
        backgroundColor: const Color(0xFF264653),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Image d'arrière-plan (SVG)
          SvgPicture.asset(
            "assets/bg.svg",
            fit: BoxFit.cover,
          ),
          // Contenu principal
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Choisissez une catégorie pour commencer le quiz :',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF54b986),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Obx(() {
                    // Vérifiez si les catégories sont chargées
                    if (questionController.savedCategories.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    return GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // Deux colonnes
                        crossAxisSpacing: 12, // Espacement horizontal entre les cartes
                        mainAxisSpacing: 12, // Espacement vertical entre les cartes
                        childAspectRatio: 0.8, // Proportions ajustées pour réduire la taille
                      ),
                      itemCount: questionController.savedCategories.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            // Naviguer vers l'écran de quiz avec la catégorie choisie
                            Get.to(() => QuizScreen(quizCategory: questionController.savedCategories[index]));
                          },
                          child: Card(
                            elevation: 6,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF00c6a9).withOpacity(0.8),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.category,
                                      size: 36, // Taille réduite de l'icône
                                      color: Colors.white,
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      questionController.savedCategories[index],
                                      style: const TextStyle(
                                        fontSize: 14, // Taille réduite du texte
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
