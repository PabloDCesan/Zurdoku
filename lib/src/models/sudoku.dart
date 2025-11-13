enum Difficulty {
  facil,
  medio,
  avanzado,
  experto,
  maestro,
}

enum CellState {
  empty,
  given,
  filled,
  error,
}

class SudokuCell {
  final int row;
  final int col;
  int? value;
  CellState state;
  bool isSelected;
  bool isHighlighted;

  // Sentinel privado para detectar “parámetro no pasado”
  static const Object _unset = Object();

  SudokuCell({
    required this.row,
    required this.col,
    this.value,
    this.state = CellState.empty,
    this.isSelected = false,
    this.isHighlighted = false,
  });

  SudokuCell copyWith({
    Object? value = _unset, //era un int, pero uso esto como centinel, asi borra lo q deberia estar vacio
    CellState? state,
    bool? isSelected,
    bool? isHighlighted,
  }) {
    return SudokuCell(
      row: row,
      col: col,
      value: identical(value, _unset) ? this.value : value as int?,
      state: state ?? this.state,
      isSelected: isSelected ?? this.isSelected,
      isHighlighted: isHighlighted ?? this.isHighlighted,
    );
  }

  bool get isEmpty => value == null;
  bool get isGiven => state == CellState.given;
  bool get hasError => state == CellState.error;
}

class SudokuBoard {
  final List<List<SudokuCell>> cells;
  final Difficulty difficulty;
  final DateTime startTime;
  final bool isCompleted;

  SudokuBoard({
    required this.cells,
    required this.difficulty,
    required this.startTime,
    this.isCompleted = false,
  });

  SudokuBoard copyWith({
    List<List<SudokuCell>>? cells,
    Difficulty? difficulty,
    DateTime? startTime,
    bool? isCompleted,
  }) {
    return SudokuBoard(
      cells: cells ?? this.cells,
      difficulty: difficulty ?? this.difficulty,
      startTime: startTime ?? this.startTime,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  bool get isValid {
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        if (cells[i][j].hasError) return false;
      }
    }
    return true;
  }

  bool get isFull {
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        if (cells[i][j].isEmpty) return false;
      }
    }
    return true;
  }
}

class GameProgress {
  final Map<Difficulty, Duration> bestTimes;
  final List<String> unlockedThemes;
  final bool musicEnabled;
  final bool soundEffectsEnabled;
  final String currentTheme;
  final double musicVolume;

  GameProgress({
    this.bestTimes = const {},
    this.unlockedThemes = const ['light', 'dark'],
    this.musicEnabled = true,
    this.soundEffectsEnabled = true,
    this.currentTheme = 'light',
    this.musicVolume = 0.7,
  });

  GameProgress copyWith({
    Map<Difficulty, Duration>? bestTimes,
    List<String>? unlockedThemes,
    bool? musicEnabled,
    bool? soundEffectsEnabled,
    String? currentTheme,
    double? musicVolume,
  }) {
    return GameProgress(
      bestTimes: bestTimes ?? this.bestTimes,
      unlockedThemes: unlockedThemes ?? this.unlockedThemes,
      musicEnabled: musicEnabled ?? this.musicEnabled,
      soundEffectsEnabled: soundEffectsEnabled ?? this.soundEffectsEnabled,
      currentTheme: currentTheme ?? this.currentTheme,
      musicVolume: musicVolume ?? this.musicVolume,
    );
  }

  Duration? getBestTime(Difficulty difficulty) {
    return bestTimes[difficulty];
  }

  bool isThemeUnlocked(String theme) {
    return unlockedThemes.contains(theme);
  }


}
