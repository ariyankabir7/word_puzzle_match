import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../gameplay_provider.dart';

class LetterGridWidget extends StatefulWidget {
  final List<List<String>> grid;
  final List<CellCoord> currentSelection;
  final Map<String, List<CellCoord>> foundWordCells;
  final Map<String, int> wordColorIndices;
  final List<CellCoord> hintCells;
  final bool showWrongFeedback;
  final Function(int row, int col) onDragStart;
  final Function(int row, int col) onDragUpdate;
  final VoidCallback onDragEnd;

  const LetterGridWidget({
    super.key,
    required this.grid,
    required this.currentSelection,
    required this.foundWordCells,
    required this.wordColorIndices,
    required this.hintCells,
    required this.showWrongFeedback,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
  });

  @override
  State<LetterGridWidget> createState() => _LetterGridWidgetState();
}

class _LetterGridWidgetState extends State<LetterGridWidget> {
  Map<CellCoord, int> _buildFoundCellColorMap() {
    final map = <CellCoord, int>{};
    widget.foundWordCells.forEach((word, cells) {
      final colorIdx = widget.wordColorIndices[word] ?? 0;
      for (final c in cells) {
        map[c] = colorIdx;
      }
    });
    return map;
  }

  CellCoord? _getCellAtPosition(Offset localPos, double cellSize, int gridSize) {
    final col = (localPos.dx / cellSize).floor();
    final row = (localPos.dy / cellSize).floor();
    if (row >= 0 && row < gridSize && col >= 0 && col < gridSize) {
      return CellCoord(row, col);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final gridSize = widget.grid.length;
    if (gridSize == 0) return const SizedBox.shrink();
    final foundColorMap = _buildFoundCellColorMap();

    final double fontSize = switch (gridSize) {
      6 => 22.0,
      7 => 19.0,
      8 => 16.0,
      _ => 14.0,
    };

    final double borderRadius = switch (gridSize) {
      6 => 8.0,
      7 => 7.0,
      8 => 6.0,
      _ => 5.0,
    };

    return LayoutBuilder(
      builder: (context, constraints) {
        final outerWidth = constraints.maxWidth;
        const double paddingAmount = 6.0;
        final innerSize = outerWidth - (paddingAmount * 2);
        final cellSize = innerSize / gridSize;

        return Container(
          width: outerWidth,
          height: outerWidth,
          padding: const EdgeInsets.all(paddingAmount + 4),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBEA),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFFB300), width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
            child: GestureDetector(
              onPanStart: (details) {
                final cell = _getCellAtPosition(details.localPosition, cellSize, gridSize);
                if (cell != null) widget.onDragStart(cell.row, cell.col);
              },
              onPanUpdate: (details) {
                final cell = _getCellAtPosition(details.localPosition, cellSize, gridSize);
                if (cell != null) widget.onDragUpdate(cell.row, cell.col);
              },
              onPanEnd: (_) => widget.onDragEnd(),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: gridSize,
                  childAspectRatio: 1,
                ),
                itemCount: gridSize * gridSize,
                itemBuilder: (context, idx) {
                  final row = idx ~/ gridSize;
                  final col = idx % gridSize;
                  final cell = CellCoord(row, col);
                  final letter = widget.grid[row][col];

                  final isSelected = widget.currentSelection.contains(cell);
                  final isHinted = widget.hintCells.contains(cell);
                  final foundColorIdx = foundColorMap[cell];
                  final isFound = foundColorIdx != null;

                  return _GridCell(
                    letter: letter,
                    isSelected: isSelected,
                    isFound: isFound,
                    isHinted: isHinted,
                    fontSize: fontSize,
                    borderRadius: borderRadius,
                    foundColor: isFound
                        ? AppColors.wordFoundColors[foundColorIdx % AppColors.wordFoundColors.length]
                        : null,
                    showWrongFeedback: widget.showWrongFeedback && isSelected,
                  );
                },
              ),
            ),
          );
        },
      );
  }
}

class _GridCell extends StatelessWidget {
  final String letter;
  final bool isSelected;
  final bool isFound;
  final bool isHinted;
  final double fontSize;
  final double borderRadius;
  final Color? foundColor;
  final bool showWrongFeedback;

  const _GridCell({
    required this.letter,
    required this.isSelected,
    required this.isFound,
    required this.isHinted,
    required this.fontSize,
    required this.borderRadius,
    this.foundColor,
    this.showWrongFeedback = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;

    if (showWrongFeedback) {
      bgColor = AppColors.wrongSelection;
      textColor = AppColors.timerWarning;
    } else if (isFound && foundColor != null) {
      bgColor = foundColor!;
      textColor = Colors.white;
    } else if (isSelected) {
      bgColor = AppColors.cellSelecting;
      textColor = AppColors.textDark;
    } else if (isHinted) {
      bgColor = AppColors.sunshineYellow.withValues(alpha: 0.6);
      textColor = AppColors.textDark;
    } else {
      bgColor = AppColors.cellDefault;
      textColor = AppColors.textDark;
    }

    Widget cell = Container(
      margin: const EdgeInsets.all(1.5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: (isSelected || isFound)
            ? [
                BoxShadow(
                  color: (isFound ? foundColor! : AppColors.skyBlue).withValues(alpha: 0.4),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
              ]
            : null,
      ),
      child: Center(
        child: Text(
          letter,
          style: isFound
              ? AppTextStyles.gridLetterFound.copyWith(fontSize: fontSize)
              : AppTextStyles.gridLetter.copyWith(color: textColor, fontSize: fontSize),
        ),
      ),
    );

    if (isFound) {
      cell = cell
          .animate()
          .scale(
            begin: const Offset(1.2, 1.2),
            end: const Offset(1, 1),
            duration: 300.ms,
            curve: Curves.elasticOut,
          );
    }

    if (showWrongFeedback) {
      cell = cell
          .animate()
          .shake(hz: 4, offset: const Offset(3, 0), duration: 400.ms);
    }

    if (isHinted) {
      cell = cell
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 600.ms);
    }

    return cell;
  }
}
