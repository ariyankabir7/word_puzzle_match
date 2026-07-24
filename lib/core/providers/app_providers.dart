import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/achievement_model.dart';
import '../models/player_progress.dart';
import '../services/storage_service.dart';
import '../services/level_service.dart';
import '../services/audio_service.dart';
import '../services/ads_service.dart';
import '../services/haptics_service.dart';

// ── Services ─────────────────────────────────────────────────────────────────

final storageServiceProvider = Provider<StorageService>((ref) {
  throw UnimplementedError('storageService must be overridden in ProviderScope');
});

final levelServiceProvider = Provider<LevelService>((ref) {
  return LevelService();
});

final audioServiceProvider = Provider<AudioService>((ref) {
  final storage = ref.watch(storageServiceProvider);
  final audio = AudioService();
  audio.updateSettings(
    sound: storage.getSoundEnabled(),
    music: storage.getMusicEnabled(),
  );
  ref.onDispose(() => audio.dispose());
  return audio;
});

final adsServiceProvider = Provider<AdsService>((ref) {
  return AdsService();
});

final hapticsServiceProvider = Provider<HapticsService>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return HapticsService(storage);
});

// ── Player Progress ───────────────────────────────────────────────────────────

class PlayerProgressNotifier extends StateNotifier<PlayerProgress> {
  final StorageService _storage;

  PlayerProgressNotifier(this._storage) : super(_storage.loadProgress()) {
    checkLifeRecharge();
  }

  void checkLifeRecharge() {
    state = state.withRechargedLives();
    _save();
  }

  bool spendLife() {
    checkLifeRecharge();
    if (state.lives > 0) {
      final newLives = state.lives - 1;
      final newLastLifeTime = state.lives == PlayerProgress.maxLives
          ? DateTime.now()
          : state.lastLifeTime;

      state = state.copyWith(
        lives: newLives,
        lastLifeTime: newLastLifeTime,
      );
      _save();
      return true;
    }
    return false;
  }

  void refillLives() {
    state = state.copyWith(
      lives: PlayerProgress.maxLives,
      lastLifeTime: DateTime.now(),
    );
    _save();
  }

  void addCoins(int amount) {
    state = state.copyWith(coins: state.coins + amount);
    _save();
  }

  bool spendCoins(int amount) {
    if (state.coins >= amount) {
      state = state.copyWith(coins: state.coins - amount);
      _save();
      return true;
    }
    return false;
  }

  void addGems(int amount) {
    state = state.copyWith(gems: state.gems + amount);
    _save();
  }

  bool spendGems(int amount) {
    if (state.gems >= amount) {
      state = state.copyWith(gems: state.gems - amount);
      _save();
      return true;
    }
    return false;
  }

  void recordLevelComplete({
    required int levelId,
    required int stars,
    required int coinsEarned,
    int gemsEarned = 0,
  }) {
    final currentStars = state.levelStars[levelId] ?? 0;
    final updatedStars = Map<int, int>.from(state.levelStars);
    if (stars > currentStars) {
      updatedStars[levelId] = stars;
    }

    final newCurrentLevel =
        levelId >= state.currentLevel ? levelId + 1 : state.currentLevel;

    // Update achievement progress for star collector and level progress
    final updatedAchievementProgress = Map<String, int>.from(state.achievementProgress);
    updatedAchievementProgress['star_collector'] =
        updatedStars.values.fold(0, (sum, s) => sum + s);
    updatedAchievementProgress['world_explorer'] = newCurrentLevel - 1;

    state = state.copyWith(
      coins: state.coins + coinsEarned,
      gems: state.gems + gemsEarned,
      currentLevel: newCurrentLevel,
      levelStars: updatedStars,
      achievementProgress: updatedAchievementProgress,
    );
    _save();
  }

  void recordWordFound() {
    final newTotal = state.totalWordsFound + 1;
    final updatedAchievementProgress = Map<String, int>.from(state.achievementProgress);
    updatedAchievementProgress['first_word'] = 1;
    updatedAchievementProgress['word_hunter'] = newTotal;
    updatedAchievementProgress['word_master'] = newTotal;

    state = state.copyWith(
      totalWordsFound: newTotal,
      achievementProgress: updatedAchievementProgress,
    );
    _save();
  }

  void recordWrongSwipe() {
    state = state.copyWith(wrongSwipesCount: state.wrongSwipesCount + 1);
    _save();
  }

  // ── Power-Up Inventory Management ──────────────────────────────────────────

  void useHint() {
    if (state.hints > 0) {
      state = state.copyWith(hints: state.hints - 1);
      _save();
    }
  }

  void useShuffle() {
    if (state.shuffles > 0) {
      state = state.copyWith(shuffles: state.shuffles - 1);
      _save();
    }
  }

  void useFreeze() {
    if (state.freezes > 0) {
      state = state.copyWith(freezes: state.freezes - 1);
      _save();
    }
  }

  bool buyHint({int count = 3, int cost = 100}) {
    if (spendCoins(cost)) {
      state = state.copyWith(hints: state.hints + count);
      _save();
      return true;
    }
    return false;
  }

  bool buyShuffle({int count = 3, int cost = 100}) {
    if (spendCoins(cost)) {
      state = state.copyWith(shuffles: state.shuffles + count);
      _save();
      return true;
    }
    return false;
  }

  bool buyFreeze({int count = 2, int cost = 150}) {
    if (spendCoins(cost)) {
      state = state.copyWith(freezes: state.freezes + count);
      _save();
      return true;
    }
    return false;
  }

  bool buyPowerUpPack({int cost = 300}) {
    if (spendCoins(cost)) {
      state = state.copyWith(
        hints: state.hints + 3,
        shuffles: state.shuffles + 3,
        freezes: state.freezes + 2,
      );
      _save();
      return true;
    }
    return false;
  }

  // ── Daily Reward & Achievement Claims ─────────────────────────────────────

  bool claimDailyReward(int dayIndex, int coinReward, int gemReward, int hintReward, int shuffleReward) {
    if (state.claimedDailyRewards.contains(dayIndex)) return false;

    final updatedClaimed = Set<int>.from(state.claimedDailyRewards)..add(dayIndex);
    final now = DateTime.now();

    state = state.copyWith(
      coins: state.coins + coinReward,
      gems: state.gems + gemReward,
      hints: state.hints + hintReward,
      shuffles: state.shuffles + shuffleReward,
      loginStreak: (state.loginStreak % 7) + 1,
      lastLoginDate: now,
      claimedDailyRewards: updatedClaimed,
    );
    _save();
    return true;
  }

  bool claimAchievement(Achievement achievement) {
    if (state.claimedAchievements.contains(achievement.id)) return false;

    final updatedClaimed = Set<String>.from(state.claimedAchievements)..add(achievement.id);
    int newCoins = state.coins;
    int newGems = state.gems;

    if (achievement.rewardType == AchievementRewardType.coins) {
      newCoins += achievement.rewardAmount;
    } else if (achievement.rewardType == AchievementRewardType.gems) {
      newGems += achievement.rewardAmount;
    }

    state = state.copyWith(
      coins: newCoins,
      gems: newGems,
      claimedAchievements: updatedClaimed,
    );
    _save();
    return true;
  }

  void resetProgress() {
    state = PlayerProgress();
    _save();
  }

  void _save() => _storage.saveProgress(state);
}

final playerProgressProvider =
    StateNotifierProvider<PlayerProgressNotifier, PlayerProgress>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return PlayerProgressNotifier(storage);
});
