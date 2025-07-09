import 'package:flutter/material.dart';

class InstructionsScreen extends StatelessWidget {
  const InstructionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Instructions')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            'How to Play:\n\n'
            '1. Select a level (table).\n'
            '2. Answer multiplication questions.\n'
            '3. Get 70% or more to unlock the next level!\n\n'
            'Use your mouse or keyboard to select answers.',
            style: const TextStyle(fontSize: 20),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
} 