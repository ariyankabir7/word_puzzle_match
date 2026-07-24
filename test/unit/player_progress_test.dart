import 'package:flutter_test/flutter_test.dart';
import 'package:word_puzzle_match/core/models/player_progress.dart';

void main() {
  group('PlayerProgress Tests', () {
    test('Initial progress defaults', () {
      final progress = PlayerProgress();
      expect(progress.coins, 200);
      expect(progress.gems, 10);
      expect(progress.lives, 5);
      expect(progress.currentLevel, 1);
      expect(progress.hints, 3);
      expect(progress.shuffles, 3);
      expect(progress.freezes, 2);
    });

    test('Lives recharge logic calculation', () {
      final pastTime = DateTime.now().subtract(const Duration(minutes: 65));
      final progress = PlayerProgress(
        lives: 2,
        lastLifeTime: pastTime,
      ).withRechargedLives();

      // 65 minutes = 2 lives gained (30 min per life) -> 2 + 2 = 4 lives
      expect(progress.lives, 4);
    });

    test('JSON serialization & deserialization', () {
      final original = PlayerProgress(
        coins: 500,
        gems: 25,
        lives: 4,
        currentLevel: 12,
        levelStars: {1: 3, 2: 2, 3: 3},
        totalWordsFound: 45,
      );

      final json = original.toJson();
      final loaded = PlayerProgress.fromJson(json);

      expect(loaded.coins, 500);
      expect(loaded.gems, 25);
      expect(loaded.currentLevel, 12);
      expect(loaded.starsForLevel(1), 3);
      expect(loaded.starsForLevel(2), 2);
      expect(loaded.totalStars, 8);
    });

    test('Level unlock logic', () {
      final progress = PlayerProgress(
        currentLevel: 5,
        levelStars: {1: 3, 2: 2, 3: 1, 4: 3},
      );

      expect(progress.isLevelUnlocked(1), true);
      expect(progress.isLevelUnlocked(5), true);
      expect(progress.isLevelUnlocked(6), false);
    });
  });
}
