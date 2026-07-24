import 'package:flutter/material.dart';

enum OwlMood { idle, happy, celebrate, surprised }

class OwlMascot extends StatelessWidget {
  final double size;
  final OwlMood mood;

  const OwlMascot({
    super.key,
    this.size = 120,
    this.mood = OwlMood.idle,
  });

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
