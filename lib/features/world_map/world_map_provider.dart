import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/player_progress.dart';
import '../../core/providers/app_providers.dart';
import 'widgets/level_node_widget.dart';

class WorldMapState {
  final PlayerProgress progress;
  final int worldNumber;

  const WorldMapState({required this.progress, required this.worldNumber});

  NodeState nodeStateForLevel(int levelId) {
    if (!progress.isLevelUnlocked(levelId)) return NodeState.locked;
    if (levelId == progress.currentLevel) return NodeState.current;
    final stars = progress.starsForLevel(levelId);
    switch (stars) {
      case 1: return NodeState.oneStar;
      case 2: return NodeState.twoStar;
      case 3: return NodeState.threeStar;
      default: return NodeState.unlocked;
    }
  }
}

final worldMapProvider = Provider.family<WorldMapState, int>((ref, worldNumber) {
  final progress = ref.watch(playerProgressProvider);
  return WorldMapState(progress: progress, worldNumber: worldNumber);
});
