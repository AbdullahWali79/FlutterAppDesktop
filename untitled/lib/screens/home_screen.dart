import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/audio_service.dart';
import '../constants/app_constants.dart';
import 'level_selection_screen.dart';
import 'instructions_screen.dart';
import 'dart:io';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final audioService = Get.find<AudioService>();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppConstants.primaryColor,
              AppConstants.secondaryColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Math Fun Adventure!',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        offset: const Offset(2, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ).animate()
                  .fadeIn(duration: 600.ms)
                  .slideY(begin: -0.2, end: 0),
                
                const SizedBox(height: 60),
                
                _buildMenuButton(
                  'Start Game',
                  Icons.play_arrow_rounded,
                  () {
                    audioService.playClickSound();
                    Get.to(() => const LevelSelectionScreen());
                  },
                ),
                
                const SizedBox(height: 20),
                
                _buildMenuButton(
                  'Instructions',
                  Icons.help_outline_rounded,
                  () {
                    audioService.playClickSound();
                    Get.to(() => const InstructionsScreen());
                  },
                ),
                
                const SizedBox(height: 20),
                
                _buildMenuButton(
                  'Exit',
                  Icons.exit_to_app_rounded,
                  () async {
                    audioService.playClickSound();
                    final shouldExit = await Get.dialog(
                      AlertDialog(
                        title: const Text('Exit Game'),
                        content: const Text('Are you sure you want to exit?'),
                        actions: [
                          TextButton(
                            onPressed: () => Get.back(result: false),
                            child: const Text('No'),
                          ),
                          TextButton(
                            onPressed: () => Get.back(result: true),
                            child: const Text('Yes'),
                          ),
                        ],
                      ),
                    );
                    if (shouldExit == true) {
                      exit(0);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(String text, IconData icon, VoidCallback onPressed) {
    return Container(
      width: 250,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppConstants.primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 5,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28),
            const SizedBox(width: 10),
            Text(
              text,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    ).animate()
      .fadeIn(delay: 200.ms)
      .slideX(begin: 0.2, end: 0)
      .scale(delay: 200.ms);
  }
} 