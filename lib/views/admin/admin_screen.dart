import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:myquizapp/controllers/question_controller.dart';
import 'package:myquizapp/models/category_model.dart';

import '../../models/question_model.dart';

class QuestionPage extends StatelessWidget {
  final Category category;

  QuestionPage({required this.category});

  @override
  Widget build(BuildContext context) {
    final QuestionController questionController = Get.put(QuestionController());
    questionController.fetchQuestionsByCategory(category.id);

    return Scaffold(
      appBar: AppBar(
        title: Text("Questions: ${category.name}"),
        backgroundColor: const Color(0xFF264653),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          SvgPicture.asset(
            "assets/bg.svg",
            fit: BoxFit.cover,
          ),
          Obx(() {
            if (questionController.questions.isEmpty) {
              return const Center(
                child: Text(
                  "Aucune question disponible pour cette catégorie.",
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
              );
            }
            return ListView.builder(
              itemCount: questionController.questions.length,
              itemBuilder: (context, index) {
                final question = questionController.questions[index];
                return Card(
                  color: const Color(0xFF2ec4b6),
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 4,
                  child: ListTile(
                    title: Text(
                      question.text,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF264653),
                      ),
                    ),
                    subtitle: Text(
                      "Réponse correcte : ${question.correctAnswer}",
                      style: const TextStyle(fontSize: 14, color: Color(0xFF264653)),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            final TextEditingController questionTextController = TextEditingController(text: question.text);
                            final List<TextEditingController> optionsControllers = List.generate(4, (index) => TextEditingController(text: question.options[index]));
                            int correctAnswerIndex = question.correctAnswer;

                            // Afficher un formulaire pour modifier la question
                            _showUpdateQuestionDialog(context, questionController, question.id, question.category.id, questionTextController, optionsControllers, correctAnswerIndex);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            questionController.deleteQuestion(question.id, category.id);
                          },
                        ),
                      ],
                    ),

                  ),
                );
              },
            );
          }),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddQuestionDialog(context, questionController, category.id);
        },
        backgroundColor: const Color(0xFF264653),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddQuestionDialog(BuildContext context, QuestionController questionController, int categoryId) {
    final TextEditingController questionTextController = TextEditingController();
    final List<TextEditingController> optionsControllers = List.generate(4, (_) => TextEditingController());
    int correctAnswerIndex = 0;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF003049),
              title: const Text("Ajouter une question"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: questionTextController,
                      decoration: const InputDecoration(labelText: "Texte de la question"),
                    ),
                    for (int i = 0; i < 4; i++)
                      TextField(
                        controller: optionsControllers[i],
                        decoration: InputDecoration(labelText: "Option ${i + 1}"),
                      ),
                    DropdownButton<int>(
                      value: correctAnswerIndex,
                      items: List.generate(4, (index) => DropdownMenuItem(value: index, child: Text("Option ${index + 1}"))),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            correctAnswerIndex = value;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Annuler"),
                ),
                TextButton(
                  onPressed: () async {
                    final text = questionTextController.text;
                    final options = optionsControllers.map((controller) => controller.text).toList();

                    // Vérifier si tous les champs sont remplis
                    if (text.isEmpty || options.any((option) => option.isEmpty)) {
                      Get.snackbar("", "Veuillez remplir tous les champs.");
                      return;
                    }

                    // Créer un objet QuestionModel
                    QuestionModel newQuestion = QuestionModel(
                      id: 0, // L'id sera géré par le backend
                      text: text,
                      options: options,
                      correctAnswer: correctAnswerIndex,
                      category: category, // Création de la catégorie via son ID
                    );

                    // Appeler la méthode pour ajouter la question
                    await questionController.addQuestion(newQuestion);

                    Navigator.of(context).pop(); // Fermer la boîte de dialogue
                  },
                  child: const Text("Ajouter"),
                ),
              ],
            );
          },
        );
      },
    );
  }


  void _showUpdateQuestionDialog(
      BuildContext context,
      QuestionController questionController,
      int questionId,
      int categoryId,
      TextEditingController questionTextController,
      List<TextEditingController> optionsControllers,
      int correctAnswerIndex,
      ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF003049),
          title: const Text("Modifier une question"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: questionTextController,
                  decoration: const InputDecoration(labelText: "Texte de la question"),
                ),
                for (int i = 0; i < 4; i++)
                  TextField(
                    controller: optionsControllers[i],
                    decoration: InputDecoration(labelText: "Option ${i + 1}"),
                  ),
                DropdownButton<int>(
                  value: correctAnswerIndex,
                  items: List.generate(4, (index) => DropdownMenuItem(value: index, child: Text("Option ${index + 1}"))),
                  onChanged: (value) {
                    if (value != null) {
                      correctAnswerIndex = value;
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Annuler"),
            ),
            TextButton(
              onPressed: () async {
                final text = questionTextController.text;
                final options = optionsControllers.map((controller) => controller.text).toList();

                // Créer un objet QuestionModel pour la mise à jour
                QuestionModel updatedQuestion = QuestionModel(
                  id: questionId,
                  text: text,
                  options: options,
                  correctAnswer: correctAnswerIndex,
                  category: category,
                );

                // Appeler la méthode pour mettre à jour la question
                await questionController.updateQuestion(updatedQuestion);

                Navigator.of(context).pop();
              },
              child: const Text("Mettre à jour"),
            ),
          ],
        );
      },
    );
  }





}
