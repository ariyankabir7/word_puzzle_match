import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_images.dart';
import '../../core/models/player_progress.dart';
import '../../core/providers/app_providers.dart';
import '../../core/router/app_router.dart';
import '../daily_rewards/daily_rewards_dialog.dart';
import '../shop/shop_screen.dart';
import 'widgets/level_node_widget.dart';
import 'widgets/path_painter.dart';
import 'world_map_provider.dart';

class WorldMapScreen extends ConsumerStatefulWidget {
  final int worldNumber;

  const WorldMapScreen({super.key, this.worldNumber = 1});

  @override
  ConsumerState<WorldMapScreen> createState() => _WorldMapScreenState();
}

class _WorldMapScreenState extends ConsumerState<WorldMapScreen> {
  late ScrollController _scrollController;
  late int _activeWorldNumber;
  static const int levelsPerWorld = 50;

  static const double canvasWidth = 360;
  static const double nodeSpacingY = 110.0;
  static const double canvasHeight = levelsPerWorld * nodeSpacingY + 200;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _activeWorldNumber = widget.worldNumber;
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToCurrentLevel());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToCurrentLevel() {
    final progress = ref.read(playerProgressProvider);
    final currentWorldOfPlayer = ((progress.currentLevel - 1) ~/ levelsPerWorld) + 1;

    if (_activeWorldNumber == currentWorldOfPlayer) {
      final currentLevelInWorld = ((progress.currentLevel - 1) % levelsPerWorld);
      final targetY = canvasHeight - (currentLevelInWorld + 1) * nodeSpacingY - 200;
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          targetY.clamp(0, _scrollController.position.maxScrollExtent),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  List<Offset> _computeNodePositions() {
    const leftX = 70.0;
    const rightX = canvasWidth - 70.0;
    const centerX = canvasWidth / 2;

    final positions = <Offset>[];
    for (int i = 0; i < levelsPerWorld; i++) {
      final y = canvasHeight - 90 - i * nodeSpacingY;
      double x;
      switch (i % 6) {
        case 0: x = leftX; break;
        case 1: x = centerX - 30; break;
        case 2: x = rightX; break;
        case 3: x = rightX - 20; break;
        case 4: x = centerX + 20; break;
        case 5: x = leftX + 10; break;
        default: x = centerX;
      }
      positions.add(Offset(x, y));
    }
    return positions;
  }

  @override
  Widget build(BuildContext context) {
    final worldState = ref.watch(worldMapProvider(_activeWorldNumber));
    final progress = worldState.progress;
    final nodePositions = _computeNodePositions();
    final startLevel = (_activeWorldNumber - 1) * levelsPerWorld + 1;
    final unlockedCount = (progress.currentLevel - startLevel).clamp(0, levelsPerWorld);

    return Scaffold(
      body: Stack(
        children: [
          // Map Background
          Positioned.fill(
            child: Image.asset(
              AppImages.bgMap,
              fit: BoxFit.cover,
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top Resources Header (Lives, Coins, Gems)
                _buildTopResourcesBar(progress, context),

                // Level Progress Card
                _buildLevelProgressBar(progress),

                // Map Path and Level Nodes
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    child: SizedBox(
                      width: double.infinity,
                      height: canvasHeight,
                      child: Stack(
                        children: [
                          // Path Line
                          Positioned.fill(
                            child: CustomPaint(
                              painter: PathPainter(
                                nodePositions: nodePositions,
                                unlockedUpTo: unlockedCount,
                                pathColor: const Color(0xFFD7CCC8),
                                pathDashColor: const Color(0xFF8D6E63),
                              ),
                            ),
                          ),

                          // Floating Chests & Trophy Decors
                          ..._buildDecorations(nodePositions),

                          // Level Nodes
                          ...List.generate(levelsPerWorld, (index) {
                            final lvlNumber = startLevel + index;
                            final pos = nodePositions[index];
                            final state = worldState.nodeStateForLevel(lvlNumber);

                            return Positioned(
                              left: pos.dx - 27,
                              top: pos.dy - 27,
                              child: LevelNodeWidget(
                                levelNumber: lvlNumber,
                                state: state,
                                onTap: () => context.push('${AppRoutes.gameplay}?level=$lvlNumber'),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ),

                // Bottom Tab Bar
                _buildBottomTabBar(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopResourcesBar(PlayerProgress progress, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Lives Pill
          _ResourcePill(
            icon: const Icon(Icons.favorite_rounded, color: Colors.white, size: 16),
            badgeColor: const Color(0xFFE91E63),
            label: '${progress.lives} Full',
          ),
          // Coins Pill
          _ResourcePill(
            imagePath: AppImages.iconCoin,
            badgeColor: const Color(0xFFFFB300),
            label: '${progress.coins}',
            showAdd: true,
            onAdd: () => ShopScreen.show(context),
          ),
          // Gems Pill
          _ResourcePill(
            imagePath: AppImages.iconGem,
            badgeColor: const Color(0xFFAB47BC),
            label: '${progress.gems}',
            showAdd: true,
            onAdd: () => ShopScreen.show(context),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelProgressBar(PlayerProgress progress) {
    final double ratio = (progress.currentLevel / 500).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEA),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFFD54F), width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Image.asset(AppImages.iconStar, width: 24, height: 24),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Level Progress',
                      style: GoogleFonts.fredoka(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF5D4037),
                      ),
                    ),
                    Text(
                      '${progress.currentLevel}/500',
                      style: GoogleFonts.fredoka(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF8D6E63),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: ratio,
                    minHeight: 10,
                    backgroundColor: const Color(0xFFE0E0E0),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFB300)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Image.asset(AppImages.iconChest, width: 28, height: 28),
        ],
      ),
    );
  }

  List<Widget> _buildDecorations(List<Offset> nodePositions) {
    if (nodePositions.length < 20) return [];
    return [
      // Floating Chest at node 10
      Positioned(
        left: nodePositions[9].dx + 30,
        top: nodePositions[9].dy - 10,
        child: Image.asset(AppImages.iconChest, width: 36, height: 36),
      ),
      // Floating Chest at node 25
      Positioned(
        left: nodePositions[24].dx - 45,
        top: nodePositions[24].dy - 10,
        child: Image.asset(AppImages.iconChest, width: 36, height: 36),
      ),
    ];
  }

  Widget _buildBottomTabBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -3)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _TabItem(
            icon: Icons.map_rounded,
            label: 'Map',
            isSelected: true,
            onTap: () {},
          ),
          _TabItem(
            icon: Icons.card_giftcard_rounded,
            label: 'Events',
            isSelected: false,
            onTap: () => DailyRewardsDialog.show(context),
          ),
          _TabItem(
            icon: Icons.shopping_basket_rounded,
            label: 'Store',
            isSelected: false,
            onTap: () => ShopScreen.show(context),
          ),
        ],
      ),
    );
  }
}

class _ResourcePill extends StatelessWidget {
  final Widget? icon;
  final String? imagePath;
  final Color badgeColor;
  final String label;
  final bool showAdd;
  final VoidCallback? onAdd;

  const _ResourcePill({
    this.icon,
    this.imagePath,
    required this.badgeColor,
    required this.label,
    this.showAdd = false,
    this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF263238).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (imagePath != null)
            Image.asset(imagePath!, width: 20, height: 20)
          else if (icon != null)
            icon!,
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.fredoka(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          if (showAdd) ...[
            const SizedBox(width: 6),
            GestureDetector(
              onTap: onAdd,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Color(0xFF8CE62C),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 14),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        decoration: isSelected
            ? BoxDecoration(
                color: const Color(0xFFAB47BC).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFFAB47BC) : const Color(0xFF90A4AE),
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.fredoka(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? const Color(0xFFAB47BC) : const Color(0xFF90A4AE),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
