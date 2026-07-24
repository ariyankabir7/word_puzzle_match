class PlayerProgress {
  static const int maxLives = 5;
  static const int lifeRechargeMinutes = 30;

  int coins;
  int gems;
  int lives;
  DateTime lastLifeTime;
  int currentLevel;
  Map<int, int> levelStars; // levelId -> stars (0–3)
  int hints;
  int shuffles;
  int freezes;
  int loginStreak;
  DateTime lastLoginDate;
  Set<int> claimedDailyRewards;
  Map<String, int> achievementProgress;
  Set<String> claimedAchievements;
  int totalWordsFound;
  int wrongSwipesCount;

  PlayerProgress({
    this.coins = 200,
    this.gems = 10,
    this.lives = maxLives,
    DateTime? lastLifeTime,
    this.currentLevel = 1,
    Map<int, int>? levelStars,
    this.hints = 3,
    this.shuffles = 3,
    this.freezes = 2,
    this.loginStreak = 0,
    DateTime? lastLoginDate,
    Set<int>? claimedDailyRewards,
    Map<String, int>? achievementProgress,
    Set<String>? claimedAchievements,
    this.totalWordsFound = 0,
    this.wrongSwipesCount = 0,
  })  : lastLifeTime = lastLifeTime ?? DateTime.now(),
        levelStars = levelStars ?? {},
        lastLoginDate = lastLoginDate ?? DateTime(2000),
        claimedDailyRewards = claimedDailyRewards ?? {},
        achievementProgress = achievementProgress ?? {},
        claimedAchievements = claimedAchievements ?? {};

  /// Recalculate lives based on elapsed time since last life loss.
  PlayerProgress withRechargedLives() {
    if (lives >= maxLives) {
      return copyWith(lives: maxLives, lastLifeTime: DateTime.now());
    }

    final now = DateTime.now();
    final elapsedMinutes = now.difference(lastLifeTime).inMinutes;
    final livesGained = elapsedMinutes ~/ lifeRechargeMinutes;

    if (livesGained > 0) {
      final newLives = (lives + livesGained).clamp(0, maxLives);
      final newLastLifeTime = newLives >= maxLives
          ? now
          : lastLifeTime.add(Duration(minutes: livesGained * lifeRechargeMinutes));
      return copyWith(lives: newLives, lastLifeTime: newLastLifeTime);
    }
    return this;
  }

  /// Returns remaining seconds until the next life recharges.
  int secondsUntilNextLife() {
    if (lives >= maxLives) return 0;
    final now = DateTime.now();
    final nextLifeTime = lastLifeTime.add(const Duration(minutes: lifeRechargeMinutes));
    final diff = nextLifeTime.difference(now).inSeconds;
    return diff > 0 ? diff : 0;
  }

  factory PlayerProgress.fromJson(Map<String, dynamic> json) {
    final progress = PlayerProgress(
      coins: (json['coins'] as int?) ?? 200,
      gems: (json['gems'] as int?) ?? 10,
      lives: (json['lives'] as int?) ?? maxLives,
      lastLifeTime: json['lastLifeTime'] != null
          ? DateTime.parse(json['lastLifeTime'] as String)
          : DateTime.now(),
      currentLevel: (json['currentLevel'] as int?) ?? 1,
      levelStars: (json['levelStars'] as Map<String, dynamic>? ?? {})
          .map((k, v) => MapEntry(int.parse(k), v as int)),
      hints: (json['hints'] as int?) ?? 3,
      shuffles: (json['shuffles'] as int?) ?? 3,
      freezes: (json['freezes'] as int?) ?? 2,
      loginStreak: (json['loginStreak'] as int?) ?? 0,
      lastLoginDate: json['lastLoginDate'] != null
          ? DateTime.parse(json['lastLoginDate'] as String)
          : DateTime(2000),
      claimedDailyRewards: (json['claimedDailyRewards'] as List<dynamic>? ?? [])
          .map((e) => e as int)
          .toSet(),
      achievementProgress: (json['achievementProgress'] as Map<String, dynamic>? ?? {})
          .map((k, v) => MapEntry(k, v as int)),
      claimedAchievements: (json['claimedAchievements'] as List<dynamic>? ?? [])
          .map((e) => e as String)
          .toSet(),
      totalWordsFound: (json['totalWordsFound'] as int?) ?? 0,
      wrongSwipesCount: (json['wrongSwipesCount'] as int?) ?? 0,
    );

    return progress.withRechargedLives();
  }

  Map<String, dynamic> toJson() {
    return {
      'coins': coins,
      'gems': gems,
      'lives': lives,
      'lastLifeTime': lastLifeTime.toIso8601String(),
      'currentLevel': currentLevel,
      'levelStars': levelStars.map((k, v) => MapEntry(k.toString(), v)),
      'hints': hints,
      'shuffles': shuffles,
      'freezes': freezes,
      'loginStreak': loginStreak,
      'lastLoginDate': lastLoginDate.toIso8601String(),
      'claimedDailyRewards': claimedDailyRewards.toList(),
      'achievementProgress': achievementProgress,
      'claimedAchievements': claimedAchievements.toList(),
      'totalWordsFound': totalWordsFound,
      'wrongSwipesCount': wrongSwipesCount,
    };
  }

  /// Number of stars earned for a level (0 if not completed).
  int starsForLevel(int levelId) => levelStars[levelId] ?? 0;

  /// Whether a level is unlocked (completed or is the next level).
  bool isLevelUnlocked(int levelId) {
    if (levelId == 1) return true;
    if (levelId <= currentLevel) return true;
    return levelStars.containsKey(levelId - 1);
  }

  /// Total stars collected.
  int get totalStars => levelStars.values.fold(0, (sum, s) => sum + s);

  PlayerProgress copyWith({
    int? coins,
    int? gems,
    int? lives,
    DateTime? lastLifeTime,
    int? currentLevel,
    Map<int, int>? levelStars,
    int? hints,
    int? shuffles,
    int? freezes,
    int? loginStreak,
    DateTime? lastLoginDate,
    Set<int>? claimedDailyRewards,
    Map<String, int>? achievementProgress,
    Set<String>? claimedAchievements,
    int? totalWordsFound,
    int? wrongSwipesCount,
  }) {
    return PlayerProgress(
      coins: coins ?? this.coins,
      gems: gems ?? this.gems,
      lives: lives ?? this.lives,
      lastLifeTime: lastLifeTime ?? this.lastLifeTime,
      currentLevel: currentLevel ?? this.currentLevel,
      levelStars: levelStars ?? Map.from(this.levelStars),
      hints: hints ?? this.hints,
      shuffles: shuffles ?? this.shuffles,
      freezes: freezes ?? this.freezes,
      loginStreak: loginStreak ?? this.loginStreak,
      lastLoginDate: lastLoginDate ?? this.lastLoginDate,
      claimedDailyRewards: claimedDailyRewards ?? Set.from(this.claimedDailyRewards),
      achievementProgress: achievementProgress ?? Map.from(this.achievementProgress),
      claimedAchievements: claimedAchievements ?? Set.from(this.claimedAchievements),
      totalWordsFound: totalWordsFound ?? this.totalWordsFound,
      wrongSwipesCount: wrongSwipesCount ?? this.wrongSwipesCount,
    );
  }
}
