import 'package:flutter/material.dart';

class WorldTheme {
  final int worldNumber;
  final String name;
  final String iconEmoji;
  final List<Color> bgGradient;
  final Color pathColor;
  final Color pathDashColor;
  final Color nodeBorderColor;
  final Color accentColor;
  final IconData decorationIcon;

  const WorldTheme({
    required this.worldNumber,
    required this.name,
    required this.iconEmoji,
    required this.bgGradient,
    required this.pathColor,
    required this.pathDashColor,
    required this.nodeBorderColor,
    required this.accentColor,
    required this.decorationIcon,
  });

  static const List<WorldTheme> themes = [
    // World 1: Green Valley
    WorldTheme(
      worldNumber: 1,
      name: 'Green Valley',
      iconEmoji: '🌳',
      bgGradient: [Color(0xFF87CEEB), Color(0xFF5CB8E4), Color(0xFF6BCB77)],
      pathColor: Color(0xFFF9C74F),
      pathDashColor: Colors.white70,
      nodeBorderColor: Color(0xFF4CAF59),
      accentColor: Color(0xFF6BCB77),
      decorationIcon: Icons.park_rounded,
    ),
    // World 2: Sunny Beach
    WorldTheme(
      worldNumber: 2,
      name: 'Sunny Beach',
      iconEmoji: '🏖️',
      bgGradient: [Color(0xFF4EA8DE), Color(0xFF48CAE4), Color(0xFFF4A261)],
      pathColor: Color(0xFFE9C46A),
      pathDashColor: Colors.white70,
      nodeBorderColor: Color(0xFF2A9D8F),
      accentColor: Color(0xFFF4A261),
      decorationIcon: Icons.beach_access_rounded,
    ),
    // World 3: Mystic Forest
    WorldTheme(
      worldNumber: 3,
      name: 'Mystic Forest',
      iconEmoji: '🍄',
      bgGradient: [Color(0xFF3A0CA3), Color(0xFF560BAD), Color(0xFF2A9D8F)],
      pathColor: Color(0xFFF72585),
      pathDashColor: Colors.white70,
      nodeBorderColor: Color(0xFF7209B7),
      accentColor: Color(0xFFB5179E),
      decorationIcon: Icons.forest_rounded,
    ),
    // World 4: Snowy Peaks
    WorldTheme(
      worldNumber: 4,
      name: 'Snowy Peaks',
      iconEmoji: '🏔️',
      bgGradient: [Color(0xFFA0C4FF), Color(0xFFB9FBC0), Color(0xFFEDF2F4)],
      pathColor: Color(0xFF00B4D8),
      pathDashColor: Colors.white70,
      nodeBorderColor: Color(0xFF0077B6),
      accentColor: Color(0xFF90E0EF),
      decorationIcon: Icons.ac_unit_rounded,
    ),
    // World 5: Desert Dunes
    WorldTheme(
      worldNumber: 5,
      name: 'Desert Dunes',
      iconEmoji: '🏜️',
      bgGradient: [Color(0xFFF39C12), Color(0xFFE67E22), Color(0xFFD35400)],
      pathColor: Color(0xFFF1C40F),
      pathDashColor: Colors.white70,
      nodeBorderColor: Color(0xFFC0392B),
      accentColor: Color(0xFFE67E22),
      decorationIcon: Icons.wb_sunny_rounded,
    ),
    // World 6: Sky Kingdom
    WorldTheme(
      worldNumber: 6,
      name: 'Sky Kingdom',
      iconEmoji: '☁️',
      bgGradient: [Color(0xFF7209B7), Color(0xFF4CC9F0), Color(0xFF4895EF)],
      pathColor: Color(0xFFFFD166),
      pathDashColor: Colors.white70,
      nodeBorderColor: Color(0xFF4361EE),
      accentColor: Color(0xFF4CC9F0),
      decorationIcon: Icons.cloud_rounded,
    ),
    // World 7: Ocean Deep
    WorldTheme(
      worldNumber: 7,
      name: 'Ocean Deep',
      iconEmoji: '🌊',
      bgGradient: [Color(0xFF03045E), Color(0xFF0077B6), Color(0xFF00B4D8)],
      pathColor: Color(0xFF90E0EF),
      pathDashColor: Colors.white70,
      nodeBorderColor: Color(0xFF023E8A),
      accentColor: Color(0xFF00B4D8),
      decorationIcon: Icons.water_rounded,
    ),
    // World 8: Candy Land
    WorldTheme(
      worldNumber: 8,
      name: 'Candy Land',
      iconEmoji: '🍬',
      bgGradient: [Color(0xFFFF70A6), Color(0xFFFF9770), Color(0xFFFFD670)],
      pathColor: Color(0xFFE71D36),
      pathDashColor: Colors.white70,
      nodeBorderColor: Color(0xFFFF70A6),
      accentColor: Color(0xFFFF9770),
      decorationIcon: Icons.cake_rounded,
    ),
    // World 9: Volcano Isle
    WorldTheme(
      worldNumber: 9,
      name: 'Volcano Isle',
      iconEmoji: '🌋',
      bgGradient: [Color(0xFF2B2D42), Color(0xFF8D99AE), Color(0xFFD90429)],
      pathColor: Color(0xFFFF595E),
      pathDashColor: Colors.white70,
      nodeBorderColor: Color(0xFF9B5DE5),
      accentColor: Color(0xFFD90429),
      decorationIcon: Icons.local_fire_department_rounded,
    ),
    // World 10: Star Galaxy
    WorldTheme(
      worldNumber: 10,
      name: 'Star Galaxy',
      iconEmoji: '✨',
      bgGradient: [Color(0xFF0D1B2A), Color(0xFF1B263B), Color(0xFF415A77)],
      pathColor: Color(0xFFE0E1DD),
      pathDashColor: Color(0xFF778DA9),
      nodeBorderColor: Color(0xFF778DA9),
      accentColor: Color(0xFFE0E1DD),
      decorationIcon: Icons.auto_awesome_rounded,
    ),
  ];

  static WorldTheme getTheme(int worldNumber) {
    final idx = (worldNumber - 1).clamp(0, themes.length - 1);
    return themes[idx];
  }
}
