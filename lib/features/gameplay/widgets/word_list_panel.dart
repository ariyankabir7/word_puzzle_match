import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class WordListPanel extends StatelessWidget {
  final List<String> words;
  final Set<String> foundWords;
  final Map<String, int> wordColorIndices;

  const WordListPanel({
    super.key,
    required this.words,
    required this.foundWords,
    required this.wordColorIndices,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'FIND THESE WORDS',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textLight,
              fontSize: 11,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          _buildWordGrid(),
        ],
      ),
    );
  }

  Widget _buildWordGrid() {
    final leftWords = <String>[];
    final rightWords = <String>[];
    for (int i = 0; i < words.length; i++) {
      if (i % 2 == 0) {
        leftWords.add(words[i]);
      } else {
        rightWords.add(words[i]);
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _WordColumn(words: leftWords, foundWords: foundWords, colorIndices: wordColorIndices)),
        Expanded(child: _WordColumn(words: rightWords, foundWords: foundWords, colorIndices: wordColorIndices)),
      ],
    );
  }
}

class _WordColumn extends StatelessWidget {
  final List<String> words;
  final Set<String> foundWords;
  final Map<String, int> colorIndices;

  const _WordColumn({required this.words, required this.foundWords, required this.colorIndices});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: words.map((word) => _WordItem(
        word: word,
        isFound: foundWords.contains(word),
        colorIndex: colorIndices[word],
      )).toList(),
    );
  }
}

class _WordItem extends StatelessWidget {
  final String word;
  final bool isFound;
  final int? colorIndex;

  const _WordItem({
    required this.word,
    required this.isFound,
    this.colorIndex,
  });

  @override
  Widget build(BuildContext context) {
    final color = colorIndex != null
        ? AppColors.wordFoundColors[colorIndex! % AppColors.wordFoundColors.length]
        : null;

    Widget child = Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Text(
        word,
        style: isFound
            ? AppTextStyles.wordListItemFound.copyWith(
                color: color?.withValues(alpha: 0.6),
              )
            : AppTextStyles.wordListItem,
      ),
    );

    if (isFound) {
      child = child
          .animate()
          .shimmer(duration: 600.ms, color: color ?? AppColors.lushGreen);
    }

    return child;
  }
}
