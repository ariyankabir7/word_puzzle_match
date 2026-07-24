import 'package:flutter_test/flutter_test.dart';
import 'package:word_puzzle_match/core/models/achievement_model.dart';

void main() {
  group('Achievements Tests', () {
    test('8 Predefined Achievements Exist', () {
      expect(Achievement.allAchievements.length, 8);
    });

    test('Achievement attributes valid', () {
      for (final a in Achievement.allAchievements) {
        expect(a.id, isNotEmpty);
        expect(a.title, isNotEmpty);
        expect(a.description, isNotEmpty);
        expect(a.targetValue, greaterThan(0));
        expect(a.rewardAmount, greaterThan(0));
      }
    });
  });
}
