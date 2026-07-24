import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/level_model.dart';

class LevelService {
  // Cache loaded worlds to avoid re-parsing JSON on every call
  final Map<int, List<LevelModel>> _cache = {};

  /// Load all levels for a given world (1-indexed).
  Future<List<LevelModel>> loadWorld(int worldNumber) async {
    if (_cache.containsKey(worldNumber)) return _cache[worldNumber]!;

    final String jsonStr = await rootBundle.loadString(
      'assets/levels/world$worldNumber.json',
    );
    final Map<String, dynamic> data =
        jsonDecode(jsonStr) as Map<String, dynamic>;
    final List<dynamic> levelsList = data['levels'] as List<dynamic>;
    final levels = levelsList
        .map((lvl) => LevelModel.fromJson(lvl as Map<String, dynamic>))
        .toList();
    _cache[worldNumber] = levels;
    return levels;
  }

  /// Load a specific level by its global ID (1-based).
  Future<LevelModel> loadLevel(int levelId) async {
    final worldNumber = ((levelId - 1) ~/ 50) + 1;
    final levels = await loadWorld(worldNumber);
    return levels.firstWhere(
      (l) => l.id == levelId,
      orElse: () => levels.first,
    );
  }

  /// Preload multiple worlds in parallel.
  Future<void> preloadWorlds(List<int> worldNumbers) async {
    await Future.wait(worldNumbers.map(loadWorld));
  }

  void clearCache() => _cache.clear();
}
