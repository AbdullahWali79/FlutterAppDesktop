import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/level_model.dart';
import '../constants/app_constants.dart';

class GameController extends GetxController {
  final RxList<LevelModel> levels = <LevelModel>[].obs;
  final RxInt currentLevel = 0.obs;
  final RxInt totalScore = 0.obs;
  final RxInt energy = 100.obs;

  Future<GameController> init() async {
    _initializeLevels();
    await _loadProgress();
    return this;
  }

  void _initializeLevels() {
    levels.value = List.generate(
      AppConstants.totalLevels,
      (index) => LevelModel(
        levelNumber: index + 1,
        tableNumber: index + 2, // Tables from 2 to 10
        levelIcon: LevelModel.levelIcons[index],
        isUnlocked: index == 0, // First level is unlocked by default
      ),
    );
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final unlockedLevels = prefs.getStringList(AppConstants.unlockedLevelsKey) ?? ['1'];
    final highScoresString = prefs.getString(AppConstants.highScoreKey) ?? '{}';
    final highScores = <String, int>{};
    // Parse high scores from string
    final reg = RegExp(r'(\d+): (\d+)');
    for (final match in reg.allMatches(highScoresString)) {
      highScores[match.group(1)!] = int.parse(match.group(2)!);
    }
    for (var i = 0; i < levels.length; i++) {
      final levelNum = (i + 1).toString();
      levels[i] = LevelModel(
        levelNumber: i + 1,
        tableNumber: i + 2,
        levelIcon: LevelModel.levelIcons[i],
        isUnlocked: i == 0 || unlockedLevels.contains(levelNum),
        highScore: highScores[levelNum] ?? 0,
      );
    }
  }

  Future<void> saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final unlockedLevels = levels
        .where((level) => level.isUnlocked)
        .map((level) => level.levelNumber.toString())
        .toList();
    await prefs.setStringList(AppConstants.unlockedLevelsKey, unlockedLevels);
    // Save high scores as a map
    final highScores = <String, int>{};
    for (var level in levels) {
      highScores[level.levelNumber.toString()] = level.highScore;
    }
    await prefs.setString(AppConstants.highScoreKey, highScores.toString());
  }

  Future<void> updateLevelScore(int levelIndex, int score) async {
    if (score > levels[levelIndex].highScore) {
      levels[levelIndex] = LevelModel(
        levelNumber: levels[levelIndex].levelNumber,
        tableNumber: levels[levelIndex].tableNumber,
        levelIcon: levels[levelIndex].levelIcon,
        isUnlocked: levels[levelIndex].isUnlocked,
        highScore: score,
      );
      await saveProgress();
    }
  }

  void unlockNextLevel() async {
    if (currentLevel.value < levels.length - 1) {
      final nextLevel = currentLevel.value + 1;
      levels[nextLevel] = LevelModel(
        levelNumber: nextLevel + 1,
        tableNumber: nextLevel + 2,
        levelIcon: LevelModel.levelIcons[nextLevel],
        isUnlocked: true,
      );
      await saveProgress();
    }
  }

  void updateScore(int score) {
    totalScore.value += score;
    energy.value = (energy.value + 10).clamp(0, 100);
    if (score >= AppConstants.minScoreToUnlock) {
      unlockNextLevel();
    }
  }

  void resetGame() {
    currentLevel.value = 0;
    totalScore.value = 0;
    energy.value = 100;
  }
} 