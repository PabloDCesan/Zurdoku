import 'dart:math';
import '../models/sudoku.dart';

class SudokuGenerator {
  static final Random _random = Random();

  static SudokuBoard generateBoard(Difficulty difficulty) {
    // Generar una solución completa
    final solution = _generateCompleteSolution();
    
    // Crear la grilla con celdas vacías según la dificultad
    final cells = _createBoardFromSolution(solution, difficulty);
    
    return SudokuBoard(
      cells: cells,
      difficulty: difficulty,
      startTime: DateTime.now(),
    );
  }

  static List<List<SudokuCell>> _generateCompleteSolution() {
    final grid = List.generate(9, (_) => List.generate(9, (_) => 0));
    
    // Llenar la diagonal principal primero (3 cuadros 3x3)
    _fillDiagonalBoxes(grid);
    
    // Resolver el resto del sudoku
    _solveSudoku(grid);
    
    return grid.asMap().entries.map((rowEntry) {
      final row = rowEntry.key;
      final rowData = rowEntry.value;
      return rowData.asMap().entries.map((colEntry) {
        final col = colEntry.key;
        final value = colEntry.value;
        return SudokuCell(
          row: row,
          col: col,
          value: value,
          state: CellState.given,
        );
      }).toList();
    }).toList();
  }

  static void _fillDiagonalBoxes(List<List<int>> grid) {
    for (int box = 0; box < 9; box += 3) {
      _fillBox(grid, box, box);
    }
  }

  static void _fillBox(List<List<int>> grid, int row, int col) {
    final numbers = List.generate(9, (index) => index + 1);
    numbers.shuffle(_random);
    
    int index = 0;
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        grid[row + i][col + j] = numbers[index++];
      }
    }
  }

  static bool _solveSudoku(List<List<int>> grid) {
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        if (grid[row][col] == 0) {
          final numbers = List.generate(9, (index) => index + 1);
          numbers.shuffle(_random);
          
          for (int num in numbers) {
            if (_isValidPlacement(grid, row, col, num)) {
              grid[row][col] = num;
              
              if (_solveSudoku(grid)) {
                return true;
              }
              
              grid[row][col] = 0;
            }
          }
          return false;
        }
      }
    }
    return true;
  }

  static bool _isValidPlacement(List<List<int>> grid, int row, int col, int num) {
    // Verificar fila
    for (int x = 0; x < 9; x++) {
      if (grid[row][x] == num) return false;
    }
    
    // Verificar columna
    for (int x = 0; x < 9; x++) {
      if (grid[x][col] == num) return false;
    }
    
    // Verificar cuadro 3x3
    final startRow = row - row % 3;
    final startCol = col - col % 3;
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (grid[i + startRow][j + startCol] == num) return false;
      }
    }
    
    return true;
  }

  static List<List<SudokuCell>> _createBoardFromSolution(
    List<List<SudokuCell>> solution, 
    Difficulty difficulty
  ) {
    final cells = solution.map((row) => 
      row.map((cell) => cell.copyWith()).toList()).toList();
    
    final cellsToRemove = _getCellsToRemove(difficulty);
    final positions = _generateRandomPositions(cellsToRemove);
    
    for (final position in positions) {
      final row = position['row'] as int;
      final col = position['col'] as int;
      cells[row][col] = cells[row][col].copyWith(
        value: null,
        state: CellState.empty,
      );
    }
    
    return cells;
  }

  static int _getCellsToRemove(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.facil:
        return 30; // 51 celdas llenas
      case Difficulty.medio:
        return 40; // 41 celdas llenas
      case Difficulty.avanzado:
        return 50; // 31 celdas llenas
      case Difficulty.experto:
        return 55; // 26 celdas llenas
      case Difficulty.maestro:
        return 60; // 21 celdas llenas
    }
  }

  static List<Map<String, int>> _generateRandomPositions(int count) {
    final positions = <Map<String, int>>[];
    final usedPositions = <String>{};
    
    while (positions.length < count) {
      final row = _random.nextInt(9);
      final col = _random.nextInt(9);
      final key = '$row-$col';
      
      if (!usedPositions.contains(key)) {
        usedPositions.add(key);
        positions.add({'row': row, 'col': col});
      }
    }
    
    return positions;
  }
}
