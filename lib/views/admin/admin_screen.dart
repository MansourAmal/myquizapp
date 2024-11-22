import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../controllers/question_controller.dart';

class AdminScreen extends StatelessWidget {
  final String quizCategory;

  AdminScreen({required this.quizCategory});

  final QuestionController questionController = Get.put(QuestionController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Questions pour $quizCategory'),
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
            child: GetBuilder<QuestionController>(
              builder: (controller) {
                if (controller.getQuestionsByCategory(quizCategory).isEmpty) {
                  return const Center(
                    child: Text(
                      "Aucune question disponible.",
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF2a9d8f),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: controller.getQuestionsByCategory(quizCategory).length,
                  itemBuilder: (context, index) {
                    final question = controller.getQuestionsByCategory(quizCategory)[index];
                    return Card(
                      elevation: 6,
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: const Color(0xFF2a9d8f).withOpacity(0.8),
                      child: ListTile(
                        title: Text(
                          question['text'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF264653),
                          ),
                        ),
                        subtitle: Text(
                          "Réponse correcte: Option ${question['correctAnswer'] + 1}",
                          style: const TextStyle(color: Color(0xFF264653)),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                _showEditQuestionDialog(context, controller, quizCategory, index);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                controller.deleteQuestion(quizCategory, index);
                                controller.update();
                                Fluttertoast.showToast(
                                  msg: "Question supprimée",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                );
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
        onPressed: () {
          _showAddQuestionDialog(context);
        },
        child: const Icon(Icons.add),
        backgroundColor: const Color(0xFF2a9d8f),
      ),
    );
  }

  // Boîte de dialogue pour ajouter une question
  void _showAddQuestionDialog(BuildContext context) {
    final TextEditingController questionController = TextEditingController();
    final List<TextEditingController> optionControllers =
    List.generate(4, (index) => TextEditingController());
    final TextEditingController correctAnswerController =
    TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Ajouter une question"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: questionController,
                  decoration: const InputDecoration(
                    labelText: "Question",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                ...List.generate(4, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: TextFormField(
                      controller: optionControllers[index],
                      decoration: InputDecoration(
                        labelText: "Option ${index + 1}",
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 8),
                TextFormField(
                  controller: correctAnswerController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Réponse correcte (0-3)",
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Annuler"),
            ),
            ElevatedButton(
              onPressed: () {
                _addQuestion(
                  context,
                  questionController.text,
                  optionControllers.map((ctrl) => ctrl.text).toList(),
                  correctAnswerController.text,
                );
              },
              child: const Text("Ajouter"),
            ),
          ],
        );
      },
    );
  }

  void _addQuestion(BuildContext context, String question, List<String> options,
      String correctAnswer) {
    if (question.isEmpty ||
        options.any((option) => option.isEmpty) ||
        correctAnswer.isEmpty) {
      Fluttertoast.showToast(
        msg: "Veuillez remplir tous les champs",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }

    final correctAnswerIndex = int.tryParse(correctAnswer);
    if (correctAnswerIndex == null || correctAnswerIndex < 0 || correctAnswerIndex > 3) {
      Fluttertoast.showToast(
        msg: "L'index de la réponse correcte doit être entre 0 et 3",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }

    // Ajouter la question via le controller
    questionController.addQuestion(
      quizCategory,
      question,
      options,
      correctAnswerIndex,
    );
    questionController.update();

    Navigator.of(context).pop();
    Fluttertoast.showToast(
      msg: "Question ajoutée avec succès",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  // Boîte de dialogue pour modifier une question (existant déjà)
  void _showEditQuestionDialog(
      BuildContext context,
      QuestionController controller,
      String category,
      int index) {
    // Code existant pour la modification
  }
}
