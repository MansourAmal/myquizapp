import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:myquizapp/controllers/question_controller.dart';

class QuizCategoryScreen extends StatelessWidget {
  const QuizCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialisation du contrôleur
    final QuestionController questionController = Get.put(QuestionController());

    return Scaffold(
      body: Stack(
        children: [
          // Fond SVG avec gestion des erreurs
          Positioned.fill(
            child: SvgPicture.asset(
              "assets/bg.svg",
              fit: BoxFit.cover,
              placeholderBuilder: (BuildContext context) =>
              const Center(child: CircularProgressIndicator()),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GetBuilder<QuestionController>(
              builder: (controller) {
                // Affichage si aucune catégorie n'est disponible
                if (controller.savedCategories.isEmpty) {
                  return const Center(
                    child: Text(
                      "Aucune catégorie disponible.",
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  );
                }

                // GridView pour afficher les catégories sous forme de cartes
                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: controller.savedCategories.length,
                  itemBuilder: (context, index) {
                    // Génération de couleurs attrayantes
                    final List<Color> gradientColors = [
                      Colors.blueAccent,
                      Colors.lightBlueAccent.shade100
                    ];

                    if (index % 2 == 1) {
                      gradientColors[0] = Colors.pinkAccent;
                      gradientColors[1] = Colors.pink.shade100;
                    }

                    return GestureDetector(
                      onTap: () {
                        // Action lors de la sélection d'une catégorie
                        debugPrint(
                            "Tapped on Quiz: ${controller.savedCategories[index]}");
                      },
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              colors: gradientColors,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.category,
                                size: 48,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                controller.savedCategories[index],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                controller.savedSubtitles.length > index
                                    ? controller.savedSubtitles[index]
                                    : "Sous-titre indisponible",
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
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
    );
  }
}
