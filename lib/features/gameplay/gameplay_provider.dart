import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/models/level_model.dart';
import '../../core/models/word_position.dart';
import '../../core/providers/app_providers.dart';
import '../../core/services/haptics_service.dart';
import '../../core/services/level_service.dart';

// ── Game State ────────────────────────────────────────────────────────────────

enum GameStatus { loading, playing, paused, won, lost, frozen }

class CellCoord {
  final int row;
  final int col;
  const CellCoord(this.row, this.col);

  @override
  bool operator ==(Object other) =>
      other is CellCoord && other.row == row && other.col == col;

  @override
  int get hashCode => row * 100 + col;
}

class GameState {
  final LevelModel? level;
  final GameStatus status;
  final int timeRemaining; // seconds
  final int moves;
  final int wrongSwipes;
  final Set<String> foundWords;
  final List<CellCoord> currentSelection;
  final Map<String, int> wordColorIndices; // word -> color index
  final Map<String, List<CellCoord>> foundWordCells; // word -> cells
  final int hintsRemaining;
  final int shufflesRemaining;
  final int freezesRemaining;
  final List<CellCoord> hintCells; // cells highlighted by hint
  final List<List<String>> currentGrid; // may be shuffled
  final bool showWrongFeedback;

  const GameState({
    this.level,
    this.status = GameStatus.loading,
    this.timeRemaining = 180,
    this.moves = 0,
    this.wrongSwipes = 0,
    this.foundWords = const {},
    this.currentSelection = const [],
    this.wordColorIndices = const {},
    this.foundWordCells = const {},
    this.hintsRemaining = AppConstants.defaultHints,
    this.shufflesRemaining = AppConstants.defaultShuffles,
    this.freezesRemaining = AppConstants.defaultFreezes,
    this.hintCells = const [],
    this.currentGrid = const [],
    this.showWrongFeedback = false,
  });

  bool get isSelecting => currentSelection.isNotEmpty;
  bool get allWordsFound =>
      level != null && foundWords.length == level!.words.length;

  int get starsEarned {
    if (level == null) return 0;
    final timePct = timeRemaining / level!.timeLimit;
    if (timePct > AppConstants.threeStarTimeThreshold &&
        wrongSwipes <= AppConstants.threeStarMaxWrongSwipes) {
      return 3;
    }
    if (timePct > AppConstants.twoStarTimeThreshold ||
        wrongSwipes <= AppConstants.twoStarMaxWrongSwipes) {
      return 2;
    }
    return 1;
  }

  int get coinsEarned {
    return (AppConstants.coinBaseReward +
            (starsEarned * 20) +
            (moves < 10 ? 10 : 0))
        .clamp(AppConstants.coinBaseReward, AppConstants.coinMaxReward);
  }

  GameState copyWith({
    LevelModel? level,
    GameStatus? status,
    int? timeRemaining,
    int? moves,
    int? wrongSwipes,
    Set<String>? foundWords,
    List<CellCoord>? currentSelection,
    Map<String, int>? wordColorIndices,
    Map<String, List<CellCoord>>? foundWordCells,
    int? hintsRemaining,
    int? shufflesRemaining,
    int? freezesRemaining,
    List<CellCoord>? hintCells,
    List<List<String>>? currentGrid,
    bool? showWrongFeedback,
  }) {
    return GameState(
      level: level ?? this.level,
      status: status ?? this.status,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      moves: moves ?? this.moves,
      wrongSwipes: wrongSwipes ?? this.wrongSwipes,
      foundWords: foundWords ?? this.foundWords,
      currentSelection: currentSelection ?? this.currentSelection,
      wordColorIndices: wordColorIndices ?? this.wordColorIndices,
      foundWordCells: foundWordCells ?? this.foundWordCells,
      hintsRemaining: hintsRemaining ?? this.hintsRemaining,
      shufflesRemaining: shufflesRemaining ?? this.shufflesRemaining,
      freezesRemaining: freezesRemaining ?? this.freezesRemaining,
      hintCells: hintCells ?? this.hintCells,
      currentGrid: currentGrid ?? this.currentGrid,
      showWrongFeedback: showWrongFeedback ?? this.showWrongFeedback,
    );
  }
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class GameplayNotifier extends StateNotifier<GameState> {
  final LevelService _levelService;
  final HapticsService _haptics;
  final PlayerProgressNotifier _progressNotifier;

  Timer? _timer;
  Timer? _wrongFeedbackTimer;
  Timer? _hintClearTimer;

  GameplayNotifier(
    this._levelService,
    this._haptics,
    this._progressNotifier,
  ) : super(const GameState());

  Future<void> loadLevel(int levelId) async {
    state = const GameState(status: GameStatus.loading);
    try {
      final level = await _levelService.loadLevel(levelId);
      final progress = _progressNotifier.state;

      state = GameState(
        level: level,
        status: GameStatus.playing,
        timeRemaining: level.timeLimit,
        currentGrid: level.grid.map((row) => List<String>.from(row)).toList(),
        hintsRemaining: progress.hints,
        shufflesRemaining: progress.shuffles,
        freezesRemaining: progress.freezes,
        foundWords: {},
        wordColorIndices: {},
        foundWordCells: {},
        currentSelection: [],
        hintCells: [],
        moves: 0,
        wrongSwipes: 0,
      );
      _startTimer();
    } catch (e) {
      state = state.copyWith(status: GameStatus.lost);
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.status != GameStatus.playing) return;
      final newTime = state.timeRemaining - 1;
      if (newTime <= 0) {
        state = state.copyWith(timeRemaining: 0, status: GameStatus.lost);
        _timer?.cancel();
      } else {
        state = state.copyWith(timeRemaining: newTime);
      }
    });
  }

  // ── Gesture Handling ───────────────────────────────────────────────────────

  void onDragStart(int row, int col) {
    if (state.status != GameStatus.playing && state.status != GameStatus.frozen) return;
    _haptics.selectionClick();
    state = state.copyWith(currentSelection: [CellCoord(row, col)]);
  }

  void onDragUpdate(int row, int col) {
    if (state.status != GameStatus.playing && state.status != GameStatus.frozen) return;
    if (state.currentSelection.isEmpty) {
      state = state.copyWith(currentSelection: [CellCoord(row, col)]);
      return;
    }

    final start = state.currentSelection.first;
    final current = CellCoord(row, col);

    final line = _calculateStraightLine(start, current);
    if (line != null && line.length != state.currentSelection.length) {
      _haptics.selectionClick();
      state = state.copyWith(currentSelection: line);
    }
  }

  List<CellCoord>? _calculateStraightLine(CellCoord start, CellCoord current) {
    if (start == current) return [start];

    final dr = current.row - start.row;
    final dc = current.col - start.col;

    final absDr = dr.abs();
    final absDc = dc.abs();

    if (dr == 0 || dc == 0 || absDr == absDc) {
      final stepR = dr.sign;
      final stepC = dc.sign;
      final steps = absDr > absDc ? absDr : absDc;

      final line = <CellCoord>[];
      for (int i = 0; i <= steps; i++) {
        line.add(CellCoord(start.row + stepR * i, start.col + stepC * i));
      }
      return line;
    }

    return null;
  }

  void onDragEnd() {
    if (state.status != GameStatus.playing && state.status != GameStatus.frozen) return;
    _evaluateSelection();
  }

  void _evaluateSelection() {
    final sel = state.currentSelection;
    if (sel.isEmpty) return;

    final level = state.level;
    if (level == null) {
      state = state.copyWith(currentSelection: []);
      return;
    }

    String? matchedWord;
    WordPosition? matchedPos;

    for (final pos in level.wordPositions) {
      if (state.foundWords.contains(pos.word)) continue;
      final wordCells = pos.cells.map((c) => CellCoord(c[0], c[1])).toList();
      if (_selectionMatchesCells(sel, wordCells) ||
          _selectionMatchesCells(sel, wordCells.reversed.toList())) {
        matchedWord = pos.word;
        matchedPos = pos;
        break;
      }
    }

    if (matchedWord != null && matchedPos != null) {
      _haptics.wordMatched();
      _progressNotifier.recordWordFound();

      final colorIdx = state.foundWords.length % 8;
      final updatedFound = Set<String>.from(state.foundWords)..add(matchedWord);
      final updatedColorIndices = Map<String, int>.from(state.wordColorIndices)
        ..[matchedWord] = colorIdx;
      final updatedFoundCells = Map<String, List<CellCoord>>.from(state.foundWordCells)
        ..[matchedWord] = sel;

      final newState = state.copyWith(
        foundWords: updatedFound,
        wordColorIndices: updatedColorIndices,
        foundWordCells: updatedFoundCells,
        currentSelection: [],
        moves: state.moves + 1,
        hintCells: [],
      );

      if (newState.allWordsFound) {
        _haptics.levelComplete();
        state = newState.copyWith(status: GameStatus.won);
        _timer?.cancel();
      } else {
        state = newState;
      }
    } else {
      _haptics.wrongSwipe();
      _progressNotifier.recordWrongSwipe();

      final newMoves = state.moves + 1;
      final newWrong = state.wrongSwipes + 1;
      state = state.copyWith(
        currentSelection: [],
        moves: newMoves,
        wrongSwipes: newWrong,
        showWrongFeedback: true,
      );
      _wrongFeedbackTimer?.cancel();
      _wrongFeedbackTimer = Timer(const Duration(milliseconds: 500), () {
        if (mounted) state = state.copyWith(showWrongFeedback: false);
      });
    }
  }

  bool _selectionMatchesCells(List<CellCoord> sel, List<CellCoord> expected) {
    if (sel.length != expected.length) return false;
    for (int i = 0; i < sel.length; i++) {
      if (sel[i] != expected[i]) return false;
    }
    return true;
  }

  // ── Power-ups ──────────────────────────────────────────────────────────────

  void useHint() {
    if (state.hintsRemaining <= 0 ||
        (state.status != GameStatus.playing && state.status != GameStatus.frozen)) {
      return;
    }
    final level = state.level;
    if (level == null) return;

    for (final pos in level.wordPositions) {
      if (!state.foundWords.contains(pos.word)) {
        final cells = pos.cells.map((c) => CellCoord(c[0], c[1])).take(1).toList();
        _progressNotifier.useHint();
        state = state.copyWith(
          hintsRemaining: state.hintsRemaining - 1,
          hintCells: cells,
        );
        _hintClearTimer?.cancel();
        _hintClearTimer = Timer(const Duration(seconds: 3), () {
          if (mounted) state = state.copyWith(hintCells: []);
        });
        return;
      }
    }
  }

  void useShuffle() {
    if (state.shufflesRemaining <= 0 ||
        (state.status != GameStatus.playing && state.status != GameStatus.frozen)) {
      return;
    }
    if (state.level == null) return;

    final grid = state.currentGrid.map((row) => List<String>.from(row)).toList();
    final foundCells = <CellCoord>{};
    for (final cells in state.foundWordCells.values) {
      foundCells.addAll(cells);
    }

    final letters = <String>[];
    final emptyCoords = <CellCoord>[];
    for (int r = 0; r < grid.length; r++) {
      for (int c = 0; c < grid[r].length; c++) {
        if (!foundCells.contains(CellCoord(r, c))) {
          letters.add(grid[r][c]);
          emptyCoords.add(CellCoord(r, c));
        }
      }
    }

    letters.shuffle();
    for (int i = 0; i < emptyCoords.length; i++) {
      grid[emptyCoords[i].row][emptyCoords[i].col] = letters[i];
    }

    for (final pos in state.level!.wordPositions) {
      if (!state.foundWords.contains(pos.word)) {
        final cells = pos.cells;
        for (int i = 0; i < pos.word.length; i++) {
          grid[cells[i][0]][cells[i][1]] = pos.word[i];
        }
      }
    }

    _progressNotifier.useShuffle();
    state = state.copyWith(
      currentGrid: grid,
      shufflesRemaining: state.shufflesRemaining - 1,
      currentSelection: [],
    );
  }

  void useFreeze() {
    if (state.freezesRemaining <= 0 || state.status != GameStatus.playing) return;
    _timer?.cancel();
    _progressNotifier.useFreeze();
    state = state.copyWith(
      freezesRemaining: state.freezesRemaining - 1,
      status: GameStatus.frozen,
    );
    Timer(Duration(seconds: AppConstants.freezeDurationSeconds), () {
      if (mounted && state.status == GameStatus.frozen) {
        state = state.copyWith(status: GameStatus.playing);
        _startTimer();
      }
    });
  }

  void retry() {
    final levelId = state.level?.id;
    if (levelId != null) loadLevel(levelId);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _wrongFeedbackTimer?.cancel();
    _hintClearTimer?.cancel();
    super.dispose();
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────

final gameplayProvider =
    StateNotifierProvider.autoDispose<GameplayNotifier, GameState>((ref) {
  final levelService = ref.watch(levelServiceProvider);
  final haptics = ref.watch(hapticsServiceProvider);
  final progressNotifier = ref.watch(playerProgressProvider.notifier);
  return GameplayNotifier(levelService, haptics, progressNotifier);
});
