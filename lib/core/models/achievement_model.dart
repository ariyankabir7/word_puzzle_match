enum AchievementRewardType { coins, gems, hints, shuffles, freezes }

class Achievement {
  final String id;
  final String title;
  final String description;
  final String iconEmoji;
  final int targetValue;
  final AchievementRewardType rewardType;
  final int rewardAmount;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconEmoji,
    required this.targetValue,
    required this.rewardType,
    required this.rewardAmount,
  });

  static const List<Achievement> allAchievements = [
    Achievement(
      id: 'first_word',
      title: 'First Step',
      description: 'Find your very first hidden word',
      iconEmoji: '🔤',
      targetValue: 1,
      rewardType: AchievementRewardType.coins,
      rewardAmount: 50,
    ),
    Achievement(
      id: 'word_hunter',
      title: 'Word Hunter',
      description: 'Find 50 total words across levels',
      iconEmoji: '🔍',
      targetValue: 50,
      rewardType: AchievementRewardType.coins,
      rewardAmount: 150,
    ),
    Achievement(
      id: 'word_master',
      title: 'Word Master',
      description: 'Find 200 total words',
      iconEmoji: '🦉',
      targetValue: 200,
      rewardType: AchievementRewardType.gems,
      rewardAmount: 10,
    ),
    Achievement(
      id: 'star_collector',
      title: 'Star Collector',
      description: 'Earn 30 total stars on the map',
      iconEmoji: '⭐',
      targetValue: 30,
      rewardType: AchievementRewardType.coins,
      rewardAmount: 200,
    ),
    Achievement(
      id: 'speed_solver',
      title: 'Speed Solver',
      description: 'Complete level 1 or higher with speed',
      iconEmoji: '⚡',
      targetValue: 1,
      rewardType: AchievementRewardType.coins,
      rewardAmount: 100,
    ),
    Achievement(
      id: 'world_explorer',
      title: 'World Explorer',
      description: 'Reach Level 50 (Clear Green Valley)',
      iconEmoji: '🗺️',
      targetValue: 50,
      rewardType: AchievementRewardType.gems,
      rewardAmount: 15,
    ),
    Achievement(
      id: 'coin_hoarder',
      title: 'Treasure Hunter',
      description: 'Accumulate 1,000 total Coins',
      iconEmoji: '💰',
      targetValue: 1000,
      rewardType: AchievementRewardType.gems,
      rewardAmount: 25,
    ),
    Achievement(
      id: 'daily_devotee',
      title: 'Daily Devotee',
      description: 'Maintain a 7-day login streak',
      iconEmoji: '📅',
      targetValue: 7,
      rewardType: AchievementRewardType.gems,
      rewardAmount: 50,
    ),
  ];
}
