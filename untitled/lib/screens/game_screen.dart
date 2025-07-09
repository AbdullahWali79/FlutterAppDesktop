import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/game_controller.dart';
import '../utils/question_generator.dart';
import '../constants/app_constants.dart';
import '../models/question_model.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late List<QuestionModel> questions;
  int currentQuestion = 0;
  int score = 0;
  int energy = 100;
  bool answered = false;
  int? selectedAnswer;
  bool showResult = false;
  bool didUpdateScore = false;

  @override
  void initState() {
    super.initState();
    final gameController = Get.find<GameController>();
    final level = gameController.levels[gameController.currentLevel.value];
    questions = QuestionGenerator.generateQuestions(level.tableNumber, AppConstants.questionsPerLevel);
  }

  void answerQuestion(int answer) {
    if (answered) return;
    setState(() {
      answered = true;
      selectedAnswer = answer;
      if (answer == questions[currentQuestion].correctAnswer) {
        score++;
        energy = (energy + 10).clamp(0, 100);
      } else {
        energy = (energy - 10).clamp(0, 100);
      }
    });
    Future.delayed(const Duration(seconds: 1), nextQuestion);
  }

  void nextQuestion() async {
    if (currentQuestion < questions.length - 1) {
      setState(() {
        currentQuestion++;
        answered = false;
        selectedAnswer = null;
      });
    } else {
      setState(() {
        showResult = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameController = Get.find<GameController>();
    final level = gameController.levels[gameController.currentLevel.value];
    if (showResult) {
      // Unlock next level and update high score only once
      final passed = score >= (questions.length * 0.7).ceil();
      if (!didUpdateScore) {
        gameController.updateLevelScore(gameController.currentLevel.value, score);
        if (passed) {
          gameController.unlockNextLevel();
        }
        didUpdateScore = true;
      }
      return Scaffold(
        appBar: AppBar(
          title: Text('Level ${level.levelNumber} Complete!'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Get.back(),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Your Score: $score / ${questions.length}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text('High Score: ${score > level.highScore ? score : level.highScore}', style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 20),
              if (passed)
                const Text('Congratulations! Next level unlocked!', style: TextStyle(color: Colors.green, fontSize: 20)),
              if (!passed)
                const Text('Score at least 70% to unlock next level.', style: TextStyle(color: Colors.red, fontSize: 20)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Get.back(),
                child: const Text('Back to Levels'),
              ),
            ],
          ),
        ),
      );
    }
    final q = questions[currentQuestion];
    return Scaffold(
      appBar: AppBar(
        title: Text('Level ${level.levelNumber} - Table of ${level.tableNumber}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Score: $score', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text('Energy: $energy', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 40),
            Center(
              child: Text(
                '${q.a} × ${q.b} = ?',
                style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 40),
            ...q.options.map((option) {
              // Determine the text color
              Color textColor = AppConstants.textColor;
              if (answered) {
                if (option == q.correctAnswer) {
                  textColor = Colors.white; // correct answer
                } else if (selectedAnswer == option) {
                  textColor = Colors.white; // wrong selected
                } else {
                  textColor = AppConstants.textColor.withOpacity(0.7); // unselected
                }
              }
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ElevatedButton(
                  onPressed: answered ? null : () => answerQuestion(option),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: answered
                        ? (option == q.correctAnswer
                            ? Colors.green
                            : (selectedAnswer == option ? Colors.red : null))
                        : null,
                    foregroundColor: textColor,
                    textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    minimumSize: const Size.fromHeight(60),
                  ),
                  child: Text(
                    option.toString(),
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                ),
              );
            }),
            const Spacer(),
            Text('Question ${currentQuestion + 1} of ${questions.length}', textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
} 