import 'package:flutter/material.dart';

class LevelModel {
  final int levelNumber;
  final int tableNumber;
  final bool isUnlocked;
  final int highScore;
  final IconData levelIcon;

  LevelModel({
    required this.levelNumber,
    required this.tableNumber,
    this.isUnlocked = false,
    this.highScore = 0,
    required this.levelIcon,
  });

  static List<IconData> levelIcons = [
    Icons.one_k,
    Icons.two_k,
    Icons.three_k,
    Icons.four_k,
    Icons.five_k,
    Icons.six_k,
    Icons.seven_k,
    Icons.eight_k,
    Icons.nine_k,
  ];
} 