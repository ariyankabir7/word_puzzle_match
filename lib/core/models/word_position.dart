class WordPosition {
  final String word;
  final int startRow;
  final int startCol;
  final String direction; // 'LR', 'TB', 'RL', 'BT', etc.

  const WordPosition({
    required this.word,
    required this.startRow,
    required this.startCol,
    required this.direction,
  });

  factory WordPosition.fromJson(Map<String, dynamic> json) {
    return WordPosition(
      word: json['word'] as String,
      startRow: json['startRow'] as int,
      startCol: json['startCol'] as int,
      direction: json['direction'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'word': word,
      'startRow': startRow,
      'startCol': startCol,
      'direction': direction,
    };
  }

  /// Returns all [row, col] pairs that this word occupies in the grid.
  List<List<int>> get cells {
    final result = <List<int>>[];
    int dr = 0, dc = 0;
    switch (direction) {
      case 'LR':
        dr = 0;
        dc = 1;
        break;
      case 'RL':
        dr = 0;
        dc = -1;
        break;
      case 'TB':
        dr = 1;
        dc = 0;
        break;
      case 'BT':
        dr = -1;
        dc = 0;
        break;
      case 'DIAG_DOWN':
        dr = 1;
        dc = 1;
        break;
      case 'DIAG_UP':
        dr = -1;
        dc = 1;
        break;
      case 'DIAG_DOWN_REV':
        dr = 1;
        dc = -1;
        break;
      case 'DIAG_UP_REV':
        dr = -1;
        dc = -1;
        break;
    }
    for (int i = 0; i < word.length; i++) {
      result.add([startRow + dr * i, startCol + dc * i]);
    }
    return result;
  }
}
