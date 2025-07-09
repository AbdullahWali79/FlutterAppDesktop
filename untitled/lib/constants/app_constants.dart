import 'package:flutter/material.dart';

class AppConstants {
  // Colors
  static const Color primaryColor = Color(0xFF4A90E2);
  static const Color secondaryColor = Color(0xFF9B51E0);
  static const Color backgroundColor = Color(0xFFF5F6FA);
  static const Color textColor = Color(0xFF2C3E50);
  static const Color successColor = Color(0xFF2ECC71);
  static const Color errorColor = Color(0xFFE74C3C);
  static const Color warningColor = Color(0xFFF1C40F);

  // Game Configuration
  static const int minScoreToUnlock = 70; // Percentage
  static const int totalLevels = 9; // Tables 2-10
  static const int questionsPerLevel = 10;
  static const int timePerQuestion = 30; // seconds

  // Animation Durations
  static const Duration buttonAnimationDuration = Duration(milliseconds: 300);
  static const Duration pageTransitionDuration = Duration(milliseconds: 500);

  // Sound Effects
  static const String clickSound = 'assets/audio/click.mp3';
  static const String correctAnswerSound = 'assets/audio/correct.mp3';
  static const String wrongAnswerSound = 'assets/audio/wrong.mp3';
  static const String levelCompleteSound = 'assets/audio/level_complete.mp3';
  static const String gameCompleteSound = 'assets/audio/game_complete.mp3';

  // Shared Preferences Keys
  static const String highScoreKey = 'high_score';
  static const String unlockedLevelsKey = 'unlocked_levels';
  static const String soundEnabledKey = 'sound_enabled';
  static const String musicEnabledKey = 'music_enabled';
} 