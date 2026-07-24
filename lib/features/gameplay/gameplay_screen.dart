import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_images.dart';
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
        title: Text(
          'Out of Lives! ❤️',
          style: GoogleFonts.fredoka(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'You have 0 hearts remaining. Refill your lives in the shop!',
          style: GoogleFonts.fredoka(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.go(AppRoutes.worldMap);
            },
            child: Text('Back to Map', style: GoogleFonts.fredoka()),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8CE62C)),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ShopScreen.show(context);
              if (mounted) {
                _checkLivesAndLoadLevel();
              }
            },
            child: Text('Go to Shop', style: GoogleFonts.fredoka(color: Colors.white)),
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

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.go(AppRoutes.worldMap);
        }
      },
      child: Scaffold(
        body: SizedBox.expand(
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Gameplay Background Image
              Positioned.fill(
                child: Image.asset(
                  AppImages.bgGameplay,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  alignment: Alignment.center,
                ),
              ),

              SafeArea(
                child: switch (state.status) {
                  GameStatus.loading => _buildLoading(),
                  _ => _buildGameplay(context, state, notifier),
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(color: Color(0xFF0288D1)),
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

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 6),

              // Header Bar (Back button, Timer, Moves, Coins)
              _buildHeader(context, state),

              const SizedBox(height: 10),

              // Word List Panel ("FIND THESE WORDS")
              WordListPanel(
                words: level.words,
                foundWords: state.foundWords,
                wordColorIndices: state.wordColorIndices,
              ).animate().fadeIn(delay: 100.ms),

              const SizedBox(height: 12),

              // Letter Grid
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
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
              ),

              const SizedBox(height: 16),

              // Power-up Boosters Bar
              PowerUpBar(
                hintsRemaining: state.hintsRemaining,
                shufflesRemaining: state.shufflesRemaining,
                freezesRemaining: state.freezesRemaining,
                isFrozen: isFrozen,
                onHint: notifier.useHint,
                onShuffle: notifier.useShuffle,
                onFreeze: notifier.useFreeze,
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 16),
            ],
          ),
        ),

        // Overlays
        if (state.status == GameStatus.won) const GreatJobOverlay(),
        if (state.status == GameStatus.lost)
          TimeUpOverlay(onRetry: notifier.retry),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, GameState state) {
    final progress = ref.watch(playerProgressProvider);

    return SizedBox(
      height: 52,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Center: Moves Counter Badge
          Container(
            width: 52,
            height: 50,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AppImages.movesLeftBg),
                fit: BoxFit.contain,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Moves',
                  style: GoogleFonts.fredoka(
                    fontSize: 10,
                    color: const Color(0xFF8D6E63),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${state.moves}',
                  style: GoogleFonts.fredoka(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFE65100),
                  ),
                ),
              ],
            ),
          ),

          // Left (Back button & Timer) & Right (Coins)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Back to Map Button
                  GestureDetector(
                    onTap: () => context.go(AppRoutes.worldMap),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFF263238).withValues(alpha: 0.85),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white38, width: 1.5),
                        boxShadow: const [
                          BoxShadow(color: Color(0x33000000), blurRadius: 4, offset: Offset(0, 2)),
                        ],
                      ),
                      child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                  const SizedBox(width: 6),

                  // Timer Pill
                  TimerWidget(
                    timeRemaining: state.timeRemaining,
                    status: state.status,
                  ),
                ],
              ),

              // Coins Pill
              GestureDetector(
                onTap: () => ShopScreen.show(context),
                child: Container(
                  width: 109,
                  height: 42,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(AppImages.coinsBalanceBg),
                      fit: BoxFit.fill,
                    ),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 28, right: 28),
                      child: Text(
                        '${progress.coins}',
                        style: GoogleFonts.fredoka(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: const [
                            Shadow(color: Colors.black45, blurRadius: 2, offset: Offset(0, 1)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
