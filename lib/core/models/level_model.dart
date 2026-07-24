import 'word_position.dart';

class LevelModel {
  final int id;
  final String world;
  final int difficulty; // 1=Easy, 2=Medium, 3=Hard, 4=Expert
  final int gridSize;   // 6, 7, 8, or 9
  final List<String> words;
  final List<List<String>> grid;
  final List<WordPosition> wordPositions;
  final int timeLimit; // in seconds

  const LevelModel({
    required this.id,
    required this.world,
    required this.difficulty,
    required this.gridSize,
    required this.words,
    required this.grid,
    required this.wordPositions,
    required this.timeLimit,
  });

  factory LevelModel.fromJson(Map<String, dynamic> json) {
    return LevelModel(
      id: json['id'] as int,
      world: json['world'] as String,
      difficulty: json['difficulty'] as int,
      gridSize: json['gridSize'] as int,
      words: List<String>.from(json['words'] as List),
      grid: (json['grid'] as List)
          .map((row) => List<String>.from(row as List))
          .toList(),
      wordPositions: (json['wordPositions'] as List)
          .map((pos) => WordPosition.fromJson(pos as Map<String, dynamic>))
          .toList(),
      timeLimit: json['timeLimit'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'world': world,
      'difficulty': difficulty,
      'gridSize': gridSize,
      'words': words,
      'grid': grid,
      'wordPositions': wordPositions.map((pos) => pos.toJson()).toList(),
      'timeLimit': timeLimit,
    };
  }

  /// Returns world number (1-based) for display purposes.
  int get worldNumber => int.tryParse(world.replaceAll(RegExp(r'[^0-9]'), '')) ?? 1;

  /// Returns a human-friendly level number within the world.
  int get levelInWorld => ((id - 1) % 50) + 1;
}
