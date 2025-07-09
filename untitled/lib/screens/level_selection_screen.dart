import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/game_controller.dart';
import '../services/audio_service.dart';
import '../constants/app_constants.dart';
import '../models/level_model.dart';
import 'game_screen.dart';

class LevelSelectionScreen extends StatelessWidget {
  const LevelSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameController = Get.find<GameController>();
    final audioService = Get.find<AudioService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Level'),
        centerTitle: true,
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppConstants.primaryColor.withOpacity(0.8),
              AppConstants.secondaryColor.withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildScoreBar(gameController),
                const SizedBox(height: 20),
                Expanded(
                  child: Obx(() => GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 1,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: gameController.levels.length,
                    itemBuilder: (context, index) {
                      final level = gameController.levels[index];
                      return _buildLevelButton(
                        level,
                        () {
                          audioService.playClickSound();
                          if (level.isUnlocked) {
                            gameController.currentLevel.value = index;
                            Get.to(() => const GameScreen());
                          }
                        },
                      );
                    },
                  )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScoreBar(GameController gameController) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildScoreItem(
            'Total Score',
            gameController.totalScore.value.toString(),
            Icons.stars,
          ),
          _buildScoreItem(
            'Energy',
            '${gameController.energy.value}%',
            Icons.bolt,
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: 600.ms)
      .slideY(begin: -0.2, end: 0);
  }

  Widget _buildScoreItem(String label, String value, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppConstants.primaryColor, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppConstants.textColor,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppConstants.primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildLevelButton(LevelModel level, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          print('Tapped level: ${level.levelNumber}, unlocked: ${level.isUnlocked}');
          if (level.isUnlocked) onTap();
        },
        borderRadius: BorderRadius.circular(15),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: level.isUnlocked ? Colors.white : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                level.levelIcon,
                size: 40,
                color: level.isUnlocked
                    ? AppConstants.primaryColor
                    : Colors.grey.shade400,
              ),
              const SizedBox(height: 8),
              Text(
                'Table of ${level.tableNumber}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: level.isUnlocked
                      ? AppConstants.textColor
                      : Colors.grey.shade400,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'High Score: ${level.highScore}',
                style: TextStyle(
                  fontSize: 12,
                  color: level.isUnlocked
                      ? AppConstants.primaryColor
                      : Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate()
      .fadeIn(delay: (level.levelNumber * 100).ms)
      .scale(delay: (level.levelNumber * 100).ms);
  }
} 