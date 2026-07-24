import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/models/level_model.dart';
import '../../core/providers/app_providers.dart';
import '../../core/router/app_router.dart';
import '../shop/shop_screen.dart';
import 'gameplay_provider.dart';
import 'widgets/great_job_overlay.dart';
import 'widgets/letter_grid_widget.dart';
import 'widgets/power_up_bar.dart';
import 'widgets/timer_widget.dart';
import 'widgets/word_list_panel.dart';

class GameplayScreen extends ConsumerStatefulWidget {
  final int levelId;

  const GameplayScreen({super.key, required this.levelId});

  @override
  ConsumerState<GameplayScreen> createState() => _GameplayScreenState();
}

class _GameplayScreenState extends ConsumerState<GameplayScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLivesAndLoadLevel();
    });
  }

  void _checkLivesAndLoadLevel() {
    final notifier = ref.read(playerProgressProvider.notifier);
    final hasLife = notifier.spendLife();
    if (!hasLife) {
      _showNoLivesDialog();
    } else {
      ref.read(gameplayProvider.notifier).loadLevel(widget.levelId);
    }
  }

  void _showNoLivesDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Out of Lives! ❤️'),
        content: const Text(
          'You have 0 hearts remaining. Refill your lives in the shop or wait for the 30-minute timer!',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.go(AppRoutes.worldMap);
            },
            child: const Text('Back to Map'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.lushGreen),
            onPressed: () {
              Navigator.of(ctx).pop();
              ShopScreen.show(context);
            },
            child: const Text('Go to Shop', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _navigateToLevelComplete(GameState state) {
    if (!mounted) return;
    context.push(
      AppRoutes.levelComplete,
      extra: {
        'levelId': widget.levelId,
        'starsEarned': state.starsEarned,
        'coinsEarned': state.coinsEarned,
        'gemsEarned': (widget.levelId % 10 == 0) ? 5 : 0,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameplayProvider);
    final notifier = ref.read(gameplayProvider.notifier);

    ref.listen<GameState>(gameplayProvider, (prev, next) {
      if (prev?.status != GameStatus.won && next.status == GameStatus.won) {
        Future.delayed(const Duration(milliseconds: 1800), () {
          _navigateToLevelComplete(next);
        });
      }
    });

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF87CEEB), Color(0xFFEEF5FF)],
          ),
        ),
        child: SafeArea(
          child: switch (state.status) {
            GameStatus.loading => _buildLoading(),
            _ => _buildGameplay(context, state, notifier),
          },
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.skyBlue),
    );
  }

  Widget _buildGameplay(
    BuildContext context,
    GameState state,
    GameplayNotifier notifier,
  ) {
    final level = state.level;
    if (level == null) return _buildLoading();
    final isFrozen = state.status == GameStatus.frozen;
    final adsService = ref.watch(adsServiceProvider);

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              // ── Header ───────────────────────────────────────────────
              _buildHeader(context, state, level),

              const SizedBox(height: 10),

              // ── Word list panel ──────────────────────────────────────
              WordListPanel(
                words: level.words,
                foundWords: state.foundWords,
                wordColorIndices: state.wordColorIndices,
              ).animate().fadeIn(delay: 100.ms),

              const SizedBox(height: 12),

              // ── Letter grid ──────────────────────────────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: LetterGridWidget(
                    grid: state.currentGrid,
                    currentSelection: state.currentSelection,
                    foundWordCells: state.foundWordCells,
                    wordColorIndices: state.wordColorIndices,
                    hintCells: state.hintCells,
                    showWrongFeedback: state.showWrongFeedback,
                    onDragStart: notifier.onDragStart,
                    onDragUpdate: notifier.onDragUpdate,
                    onDragEnd: notifier.onDragEnd,
                  ).animate().fadeIn(delay: 150.ms),
                ),
              ),

              const SizedBox(height: 16),

              // ── Power-up bar ─────────────────────────────────────────
              PowerUpBar(
                hintsRemaining: state.hintsRemaining,
                shufflesRemaining: state.shufflesRemaining,
                freezesRemaining: state.freezesRemaining,
                isFrozen: isFrozen,
                onHint: notifier.useHint,
                onShuffle: notifier.useShuffle,
                onFreeze: notifier.useFreeze,
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 12),

              adsService.buildBannerAdWidget(),

              const SizedBox(height: 12),
            ],
          ),
        ),

        // ── Overlays ─────────────────────────────────────────────────
        if (state.status == GameStatus.won) const GreatJobOverlay(),
        if (state.status == GameStatus.lost)
          TimeUpOverlay(onRetry: notifier.retry),

        if (isFrozen) _buildFreezeBar(),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, GameState state, LevelModel level) {
    final progress = ref.watch(playerProgressProvider);

    return Row(
      children: [
        // Back button
        GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4),
              ],
            ),
            child: const Icon(Icons.arrow_back_ios_rounded, size: 16, color: AppColors.textDark),
          ),
        ),

        const SizedBox(width: 8),

        // Timer
        TimerWidget(
          timeRemaining: state.timeRemaining,
          status: state.status,
        ),

        const Spacer(),

        // Moves
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Moves', style: AppTextStyles.bodySmall.copyWith(fontSize: 10)),
              Text(
                state.moves.toString(),
                style: AppTextStyles.headingMedium.copyWith(fontSize: 16),
              ),
            ],
          ),
        ),

        const SizedBox(width: 8),

        // Coins (Tap to open shop)
        GestureDetector(
          onTap: () => ShopScreen.show(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Text('🪙', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 4),
                Text(
                  progress.coins > 999 ? '${(progress.coins / 1000).toStringAsFixed(1)}K' : progress.coins.toString(),
                  style: AppTextStyles.coinCount.copyWith(fontSize: 14),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.add_circle, size: 14, color: AppColors.lushGreen),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFreezeBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 4,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.skyBlue, Colors.white, AppColors.skyBlue],
          ),
        ),
      )
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .shimmer(duration: 1000.ms, color: Colors.white),
    );
  }
}
