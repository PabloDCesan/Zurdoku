import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/sudoku.dart';
import '../services/sudoku_generator.dart';

class GameState {
  final SudokuBoard? currentBoard;
  final Difficulty? selectedDifficulty;
  final Duration elapsedTime;
  final bool isGameActive;
  final bool isGameCompleted;
  final int? selectedRow;
  final int? selectedCol;

  const GameState({
    this.currentBoard,
    this.selectedDifficulty,
    this.elapsedTime = Duration.zero,
    this.isGameActive = false,
    this.isGameCompleted = false,
    this.selectedRow,
    this.selectedCol,
  });

  GameState copyWith({
    SudokuBoard? currentBoard,
    Difficulty? selectedDifficulty,
    Duration? elapsedTime,
    bool? isGameActive,
    bool? isGameCompleted,
    int? selectedRow,
    int? selectedCol,
  }) {
    return GameState(
      currentBoard: currentBoard ?? this.currentBoard,
      selectedDifficulty: selectedDifficulty ?? this.selectedDifficulty,
      elapsedTime: elapsedTime ?? this.elapsedTime,
      isGameActive: isGameActive ?? this.isGameActive,
      isGameCompleted: isGameCompleted ?? this.isGameCompleted,
      selectedRow: selectedRow ?? this.selectedRow,
      selectedCol: selectedCol ?? this.selectedCol,
    );
  }
}

class GameStateNotifier extends Notifier<GameState> {
  @override
  GameState build() => const GameState();

  void startNewGame(Difficulty difficulty) {
    final board = SudokuGenerator.generateBoard(difficulty);
    state = GameState(
      currentBoard: board,
      selectedDifficulty: difficulty,
      elapsedTime: Duration.zero,
      isGameActive: true,
      isGameCompleted: false,
    );
  }

  void selectCell(int row, int col) {
    if (state.currentBoard == null) 
    {
      return;
    }

    state = state.copyWith(
      selectedRow: row,
      selectedCol: col,
    );
  }

  void fillCell(int value) { {
      
    }
    if (state.currentBoard == null || 
        state.selectedRow == null || 
        state.selectedCol == null) 
        {
          return;
        }

    final board = state.currentBoard!;
    final row = state.selectedRow!;
    final col = state.selectedCol!;

    if (board.cells[row][col].isGiven) 
    {
      return;
    }

    // Crear nueva grilla con el valor actualizado
    final newCells = board.cells.map((rowCells) => 
      rowCells.map((cell) => cell.copyWith()).toList()).toList();

    newCells[row][col] = newCells[row][col].copyWith(
      value: value,
      state: CellState.filled,
    );

    // Verificar si hay errores
    _validateBoard(newCells);

    final newBoard = board.copyWith(cells: newCells);
    
    // Verificar si el juego está completo
    final isCompleted = _isBoardComplete(newCells);

    state = state.copyWith( 
      currentBoard: newBoard,
      isGameCompleted: isCompleted,
    );
  }

  void clearCell() {
    if (state.currentBoard == null || 
        state.selectedRow == null || 
        state.selectedCol == null) 
        {
          return;
        }

    final board = state.currentBoard!;
    final row = state.selectedRow!;
    final col = state.selectedCol!;

    if (board.cells[row][col].isGiven) 
    {
      return;
    }

    final newCells = board.cells.map((rowCells) => 
      rowCells.map((cell) => cell.copyWith()).toList()).toList();

    newCells[row][col] = newCells[row][col].copyWith(
      value: null,
      state: CellState.empty,
    );

    final newBoard = board.copyWith(cells: newCells);

    state = state.copyWith(currentBoard: newBoard);
  }

  void updateElapsedTime(Duration elapsed) {
    state = state.copyWith(elapsedTime: elapsed);
  }

  void pauseGame() {
    state = state.copyWith(isGameActive: false);
  }

  void resumeGame() {
    state = state.copyWith(isGameActive: true);
  }

  void resetGame() {
    state = const GameState();
  }

  void _validateBoard(List<List<SudokuCell>> cells) {
    // Resetear todos los errores
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        if (cells[i][j].state == CellState.error) {
          cells[i][j] = cells[i][j].copyWith(state: CellState.filled);
        }
      }
    }

    // Verificar filas
    for (int row = 0; row < 9; row++) {
      _validateGroup(cells, _getRowCells(cells, row));
    }

    // Verificar columnas
    for (int col = 0; col < 9; col++) {
      _validateGroup(cells, _getColCells(cells, col));
    }

    // Verificar cuadros 3x3
    for (int box = 0; box < 9; box++) {
      _validateGroup(cells, _getBoxCells(cells, box));
    }
  }

  void _validateGroup(List<List<SudokuCell>> cells, List<SudokuCell> group) {
    final values = group.where((cell) => cell.value != null).map((cell) => cell.value!).toList();
    final duplicates = <int>[];

    for (int i = 0; i < values.length; i++) {
      for (int j = i + 1; j < values.length; j++) {
        if (values[i] == values[j] && !duplicates.contains(values[i])) {
          duplicates.add(values[i]);
        }
      }
    }

    // Marcar celdas con errores
    for (final cell in group) {
      if (cell.value != null && duplicates.contains(cell.value)) {
        final row = cell.row;
        final col = cell.col;
        cells[row][col] = cells[row][col].copyWith(state: CellState.error);
      }
    }
  }

  List<SudokuCell> _getRowCells(List<List<SudokuCell>> cells, int row) {
    return cells[row];
  }

  List<SudokuCell> _getColCells(List<List<SudokuCell>> cells, int col) {
    return cells.map((row) => row[col]).toList();
  }

  List<SudokuCell> _getBoxCells(List<List<SudokuCell>> cells, int box) {
    final startRow = (box ~/ 3) * 3;
    final startCol = (box % 3) * 3;
    final boxCells = <SudokuCell>[];

    for (int i = startRow; i < startRow + 3; i++) {
      for (int j = startCol; j < startCol + 3; j++) {
        boxCells.add(cells[i][j]);
      }
    }
    return boxCells;
  }

  bool _isBoardComplete(List<List<SudokuCell>> cells) {
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        if (cells[i][j].isEmpty || cells[i][j].hasError) {
          return false;
        }
      }
    }
    return true;
  }
}

final gameProvider = NotifierProvider<GameStateNotifier, GameState>(() {
  return GameStateNotifier();
});