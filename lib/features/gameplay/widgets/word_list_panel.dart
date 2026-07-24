import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

  static const List<Color> _wordColors = [
    Color(0xFF2E7D32), // Green
    Color(0xFFD84315), // Deep Orange
    Color(0xFFC2185B), // Pink
    Color(0xFF1565C0), // Blue
    Color(0xFF6A1B9A), // Purple
    Color(0xFFE65100), // Orange
    Color(0xFF00838F), // Teal
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEA),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFFE082), width: 2.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'FIND THESE WORDS',
            style: GoogleFonts.fredoka(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF8E24AA),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 18,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: List.generate(words.length, (index) {
              final word = words[index];
              final isFound = foundWords.contains(word);
              final textColor = _wordColors[index % _wordColors.length];

              return Text(
                word,
                style: GoogleFonts.fredoka(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isFound ? textColor.withValues(alpha: 0.35) : textColor,
                  decoration: isFound ? TextDecoration.lineThrough : null,
                  decorationThickness: 2,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
