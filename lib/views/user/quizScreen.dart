import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../controllers/question_controller.dart'; // Assurez-vous d'importer le contrôleur

class QuizScreen extends StatefulWidget {
  final int quizCategory;

  QuizScreen({required this.quizCategory});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final QuestionController questionController = Get.find();
  int currentQuestionIndex = 0;
  String? selectedOption;
  bool isAnswered = false;
  int score = 0;

  @override
  void initState() {
    super.initState();
    questionController.fetchQuestionsByCategory(widget.quizCategory);
  }

  void onOptionSelected(String option) {
    if (isAnswered) return; // Empêche les clics multiples après une réponse

    setState(() {
      selectedOption = option;
      isAnswered = true;

      // Trouver l'index de l'option sélectionnée
      int selectedIndex = questionController.questions[currentQuestionIndex].options.indexOf(option);

      // Vérifier si l'index de la réponse sélectionnée est le même que celui de la bonne réponse
      if (selectedIndex == questionController.questions[currentQuestionIndex].correctAnswer) {
        score++;
      }
    });
  }

  void nextQuestion() {
    setState(() {
      if (currentQuestionIndex < questionController.questions.length - 1) {
        currentQuestionIndex++;
        selectedOption = null;
        isAnswered = false;
      } else {
        showQuizCompletedDialog();
      }
    });
  }

  void showQuizCompletedDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Quiz Terminé'),
        content: Text('Félicitations, vous avez terminé le quiz !\nScore : $score / ${questionController.questions.length}'),
        backgroundColor: const Color(0xFF264653),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Retour à l'écran précédent
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Question ${currentQuestionIndex + 1} / ${questionController.questions.length}'),
        backgroundColor: const Color(0xFF264653),
      ),
      body: Obx(() {
        if (questionController.questions.isEmpty) {
          return Center(child: CircularProgressIndicator());
        }

        final currentQuestion = questionController.questions[currentQuestionIndex];

        return Stack(
          fit: StackFit.expand,
          children: [
            SvgPicture.asset(
              "assets/bg.svg",
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    currentQuestion.text, // Utiliser la question actuelle
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ...currentQuestion.options.asMap().entries.map<Widget>((entry) {
                    int index = entry.key;
                    String option = entry.value;
                    Color? optionColor;

                    if (isAnswered) {
                      // Comparer l'index de la réponse sélectionnée à l'index de la bonne réponse
                      if (index == currentQuestion.correctAnswer) {
                        optionColor = Colors.green; // Bonne réponse en vert
                      } else if (index == currentQuestion.options.indexOf(selectedOption!)) {
                        optionColor = Colors.red; // Mauvaise réponse en rouge
                      } else {
                        optionColor = Colors.grey; // Les autres options inactives
                      }
                    } else {
                      optionColor = const Color(0xFF2A9D8F); // Couleur par défaut (vert)
                    }

                    return GestureDetector(
                      onTap: () => onOptionSelected(option),
                      child: Card(
                        color: optionColor,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(
                            option,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: isAnswered ? nextQuestion : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2A9D8F),
                      disabledBackgroundColor: Colors.grey,
                    ),
                    child: Text(currentQuestionIndex < questionController.questions.length - 1 ? 'Suivant' : 'Terminer'),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}
