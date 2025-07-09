import '../models/question_model.dart';
import 'dart:math';

class QuestionGenerator {
  static List<QuestionModel> generateQuestions(int table, int count) {
    final random = Random();
    final questions = <QuestionModel>[];

    for (int i = 1; i <= count; i++) {
      int correct = table * i;
      Set<int> options = {correct};
      while (options.length < 4) {
        int wrong = (random.nextInt(10) + 1) * table;
        if (wrong != correct) options.add(wrong);
      }
      questions.add(
        QuestionModel(
          a: table,
          b: i,
          options: options.toList()..shuffle(),
          correctAnswer: correct,
        ),
      );
    }
    questions.shuffle();
    return questions;
  }
} 