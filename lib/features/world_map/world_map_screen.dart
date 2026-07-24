import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/world_themes.dart';
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
    } else {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    }
  }

  void _changeWorld(int newWorldNumber) {
    if (newWorldNumber < 1 || newWorldNumber > 10) return;
    setState(() {
      _activeWorldNumber = newWorldNumber;
    });
    _scrollToCurrentLevel();
  }

  List<Offset> _computeNodePositions() {
    const leftX = 60.0;
    const rightX = canvasWidth - 60.0;
    const centerX = canvasWidth / 2;

    final positions = <Offset>[];
    for (int i = 0; i < levelsPerWorld; i++) {
      final y = canvasHeight - 80 - i * nodeSpacingY;
      double x;
      switch (i % 5) {
        case 0: x = centerX - 20; break;
        case 1: x = rightX; break;
        case 2: x = rightX - 30; break;
        case 3: x = leftX + 10; break;
        case 4: x = leftX; break;
        default: x = centerX;
      }
      positions.add(Offset(x, y));
    }
    return positions;
  }

  @override
  Widget build(BuildContext context) {
    final worldTheme = WorldTheme.getTheme(_activeWorldNumber);
    final worldState = ref.watch(worldMapProvider(_activeWorldNumber));
    final adsService = ref.watch(adsServiceProvider);
    final progress = worldState.progress;
    final nodePositions = _computeNodePositions();
    final startLevel = (_activeWorldNumber - 1) * levelsPerWorld + 1;
    final unlockedCount = (progress.currentLevel - startLevel).clamp(0, levelsPerWorld);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: worldTheme.bgGradient,
            stops: const [0, 0.5, 1],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── Header ─────────────────────────────────────────────────
              _buildHeader(progress, context),

              // ── World Switcher Bar ─────────────────────────────────────
              _buildWorldSwitcher(worldTheme),

              // ── Map area ───────────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  reverse: false,
                  physics: const BouncingScrollPhysics(),
                  child: SizedBox(
                    width: double.infinity,
                    height: canvasHeight,
                    child: Stack(
                      children: [
                        // Background elements
                        ..._buildBackgroundElements(worldTheme),

                        // Path
                        Positioned.fill(
                          child: CustomPaint(
                            painter: PathPainter(
                              nodePositions: nodePositions,
                              unlockedUpTo: unlockedCount,
                              pathColor: worldTheme.pathColor,
                              pathDashColor: worldTheme.pathDashColor,
                            ),
                          ),
                        ),

                        // Level nodes
                        ...List.generate(levelsPerWorld, (i) {
                          final levelId = startLevel + i;
                          final pos = nodePositions[i];
                          final nodeState = worldState.nodeStateForLevel(levelId);

                          Widget? marker;
                          if (i == 9 || i == 24 || i == 49) {
                            marker = _buildMilestoneMarker(i == 49, worldTheme);
                          }

                          return Positioned(
                            left: pos.dx - (nodeState == NodeState.current ? 31 : 27),
                            top: pos.dy - (nodeState == NodeState.current ? 31 : 27),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (marker != null) ...[marker, const SizedBox(height: 4)],
                                LevelNodeWidget(
                                  levelNumber: levelId,
                                  state: nodeState,
                                  onTap: () => context.push(
                                    '${AppRoutes.gameplay}?level=$levelId',
                                  ),
                                ).animate().fadeIn(
                                      delay: Duration(milliseconds: (i % 10) * 20),
                                      duration: 250.ms,
                                    ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),

              // Banner Ad Container
              adsService.buildBannerAdWidget(),

              // ── Bottom Nav ─────────────────────────────────────────────
              _buildBottomNav(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(PlayerProgress progress, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              // Back button
              GestureDetector(
                onTap: () => context.go(AppRoutes.home),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 18),
                ),
              ),
              const SizedBox(width: 10),

              // Level progress bar
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: AppColors.sunshineYellow, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'Overall Progress',
                          style: AppTextStyles.bodySmall.copyWith(color: Colors.white),
                        ),
                        const Spacer(),
                        Text(
                          '${progress.currentLevel}/500',
                          style: AppTextStyles.bodySmall.copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: (progress.currentLevel - 1) / 500.0,
                        backgroundColor: Colors.white.withValues(alpha: 0.3),
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.sunshineYellow),
                        minHeight: 10,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              // Daily Reward chest icon
              GestureDetector(
                onTap: () => DailyRewardsDialog.show(context),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.card_giftcard_rounded, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWorldSwitcher(WorldTheme worldTheme) {
    final canPrev = _activeWorldNumber > 1;
    final canNext = _activeWorldNumber < 10;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              icon: Icon(
                Icons.arrow_back_ios_rounded,
                color: canPrev ? Colors.white : Colors.white30,
                size: 18,
              ),
              onPressed: canPrev ? () => _changeWorld(_activeWorldNumber - 1) : null,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  worldTheme.iconEmoji,
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(width: 6),
                Text(
                  'World $_activeWorldNumber: ${worldTheme.name}',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              icon: Icon(
                Icons.arrow_forward_ios_rounded,
                color: canNext ? Colors.white : Colors.white30,
                size: 18,
              ),
              onPressed: canNext ? () => _changeWorld(_activeWorldNumber + 1) : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMilestoneMarker(bool isGold, WorldTheme worldTheme) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isGold ? AppColors.sunshineYellow : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: isGold ? AppColors.sunshineYellowDark : worldTheme.accentColor,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Icon(
        isGold ? Icons.emoji_events_rounded : Icons.card_giftcard_rounded,
        size: 18,
        color: isGold ? Colors.white : worldTheme.accentColor,
      ),
    );
  }

  List<Widget> _buildBackgroundElements(WorldTheme worldTheme) {
    return [
      Positioned(
        bottom: 40,
        left: 20,
        child: Icon(
          worldTheme.decorationIcon,
          size: 48,
          color: Colors.white.withValues(alpha: 0.35),
        ),
      ),
      Positioned(
        top: 120,
        right: 25,
        child: Icon(
          worldTheme.decorationIcon,
          size: 56,
          color: Colors.white.withValues(alpha: 0.35),
        ).animate(onPlay: (c) => c.repeat(reverse: true)).moveY(begin: 0, end: -15, duration: 4000.ms),
      ),
      Positioned(
        top: 40,
        left: 10,
        child: CustomPaint(
          size: const Size(90, 42),
          painter: const _CloudPainter(),
        ).animate(onPlay: (c) => c.repeat(reverse: true)).moveX(begin: 0, end: 10, duration: 5000.ms),
      ),
    ];
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Color(0x22000000), blurRadius: 10, offset: Offset(0, -3)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.map_rounded,
                label: 'Map',
                isActive: true,
                onTap: () {},
              ),
              _NavItem(
                icon: Icons.celebration_rounded,
                label: 'Events',
                isActive: false,
                onTap: () => DailyRewardsDialog.show(context),
              ),
              _NavItem(
                icon: Icons.storefront_rounded,
                label: 'Store',
                isActive: false,
                onTap: () => ShopScreen.show(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? AppColors.navActive : AppColors.navInactive,
            size: 26,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: isActive ? AppTextStyles.navLabelActive : AppTextStyles.navLabel,
          ),
        ],
      ),
    );
  }
}

class _CloudPainter extends CustomPainter {
  const _CloudPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.45);
    canvas.drawCircle(Offset(size.width * 0.3, size.height * 0.6), size.height * 0.42, paint);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.42), size.height * 0.5, paint);
    canvas.drawCircle(Offset(size.width * 0.72, size.height * 0.6), size.height * 0.36, paint);
    canvas.drawRect(
        Rect.fromLTRB(size.width * 0.1, size.height * 0.6, size.width * 0.9, size.height), paint);
  }

  @override
  bool shouldRepaint(_) => false;
}
