class AppConstants {
  // Grid sizes per difficulty
  static const Map<int, int> gridSizes = {
    1: 6, // Easy (1–50)
    2: 7, // Medium (51–200)
    3: 8, // Hard (201–350)
    4: 9, // Expert (351–500)
  };

  // Time limits per difficulty (seconds)
  static const Map<int, int> timeLimits = {
    1: 180, // Easy: 3:00
    2: 150, // Medium: 2:30
    3: 120, // Hard: 2:00
    4: 105, // Expert: 1:45
  };

  // Power-up defaults per level
  static const int defaultHints = 3;
  static const int defaultShuffles = 3;
  static const int defaultFreezes = 2;

  // Freeze duration in seconds
  static const int freezeDurationSeconds = 15;

  // Timer warning threshold (seconds remaining)
  static const int timerWarningThreshold = 30;

  // Lives
  static const int maxLives = 5;
  static const int lifeRechargeMinutes = 30;

  // Economy
  static const int coinBaseReward = 20;
  static const int coinMaxReward = 100;
  static const int gemMilestoneMin = 5;
  static const int gemMilestoneMax = 15;

  // Levels
  static const int totalLevels = 500;
  static const int levelsPerWorld = 50;
  static const int totalWorlds = 10;

  // Star thresholds
  static const double twoStarTimeThreshold = 0.5; // >50% time remaining
  static const int twoStarMaxWrongSwipes = 5; // <5 wrong swipes
  static const double threeStarTimeThreshold = 0.75; // >75% time remaining
  static const int threeStarMaxWrongSwipes = 0; // 0 wrong swipes

  // World Map node sizes
  static const double nodeSize = 54.0;
  static const double currentNodeSize = 62.0;

  // Splash duration
  static const int splashDurationMs = 2500;

  // Difficulty levels
  static const int difficultyEasy = 1;
  static const int difficultyMedium = 2;
  static const int difficultyHard = 3;
  static const int difficultyExpert = 4;

  // Directions allowed per difficulty
  // 1 = Easy: L→R, T→B only
  // 2 = Medium: + Diagonal
  // 3 = Hard: + Reverse H/V
  // 4 = Expert: all 8 directions
  static const Map<int, List<String>> allowedDirections = {
    1: ['LR', 'TB'],
    2: ['LR', 'TB', 'DIAG_DOWN', 'DIAG_UP'],
    3: ['LR', 'TB', 'RL', 'BT', 'DIAG_DOWN', 'DIAG_UP'],
    4: ['LR', 'TB', 'RL', 'BT', 'DIAG_DOWN', 'DIAG_UP', 'DIAG_DOWN_REV', 'DIAG_UP_REV'],
  };
}
