import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class QuizScreen extends StatefulWidget {
  final String quizCategory;

  QuizScreen({required this.quizCategory});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final List<Map<String, dynamic>> questions = [
    {
      'question': 'Quelle est la capitale de la France ?',
      'options': ['Paris', 'Londres', 'Berlin', 'Madrid'],
      'answer': 'Paris',
    },
    {
      'question': 'Quelle est la plus grande planète du système solaire ?',
      'options': ['Terre', 'Jupiter', 'Mars', 'Saturne'],
      'answer': 'Jupiter',
    },
    {
      'question': 'Qui a écrit "Roméo et Juliette" ?',
      'options': ['Shakespeare', 'Victor Hugo', 'Molière', 'Balzac'],
      'answer': 'Shakespeare',
    },
  ];

  int currentQuestionIndex = 0;
  String? selectedOption;
  bool isAnswered = false;
  int score = 0;

  void onOptionSelected(String option) {
    if (isAnswered) return; // Empêche les clics multiples après une réponse

    setState(() {
      selectedOption = option;
      isAnswered = true;

      if (option == questions[currentQuestionIndex]['answer']) {
        score++;
      }
    });
  }

  void nextQuestion() {
    setState(() {
      if (currentQuestionIndex < questions.length - 1) {
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
        content: Text('Félicitations, vous avez terminé le quiz !\nScore : $score / ${questions.length}'),
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
    final currentQuestion = questions[currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('Question ${currentQuestionIndex + 1} / ${questions.length}'),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  currentQuestion['question'],
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                ...currentQuestion['options'].map<Widget>((option) {
                  Color? optionColor;
                  if (isAnswered) {
                    if (option == currentQuestion['answer']) {
                      optionColor = Colors.green; // Bonne réponse en vert
                    } else if (option == selectedOption) {
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
                  child: Text(currentQuestionIndex < questions.length - 1 ? 'Suivant' : 'Terminer'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
