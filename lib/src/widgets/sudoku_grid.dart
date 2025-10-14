import 'package:flutter/material.dart';
import '../models/sudoku.dart';
import '../models/theme.dart';
import '../providers/progress_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SudokuGrid extends ConsumerWidget {
  final SudokuBoard board;
  final int? selectedRow;
  final int? selectedCol;
  final Function(int row, int col) onCellSelected;

  const SudokuGrid({
    super.key,
    required this.board,
    this.selectedRow,
    this.selectedCol,
    required this.onCellSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressProvider);
    final appTheme = AppThemes.getThemeByName(progress.currentTheme);
    
    // En el widget que contiene la cuadrícula (ej. SudokuBoard)
     final screenWidth = MediaQuery.of(context).size.width;
    // Reservamos un pequeño espacio para el padding/márgenes (ej. 20.0)
     final availableWidth = screenWidth - 20.0;
    // El tamaño de la celda es el ancho disponible dividido por 9
     final cellSize = availableWidth / 9.5; 


    return Container(
        decoration: BoxDecoration(
        border: Border.all(
          color: appTheme.sudokuGridColor,
          width: 4,
        ),
      ),
      child: Column(
          children: List.generate(9, (row) {
          return Expanded(
            child: Row(
              children: List.generate(9, (col) {
                final cell = board.cells[row][col];
                final isSelected = selectedRow == row && selectedCol == col;
                final isInSameRow = selectedRow == row;
                final isInSameCol = selectedCol == col;
                final isInSameBox = _isInSameBox(row, col, selectedRow, selectedCol);
                final isHighlighted = isSelected || isInSameRow || isInSameCol || isInSameBox;
                
                 
                return SizedBox(
                  width: cellSize,
                  child: _buildCell(
                    context,
                    cell,
                    isSelected,
                    isHighlighted,
                    appTheme,
                    () => onCellSelected(row, col),
                  ),
                );
            

              }),
            ),
          );
        }),
      ),
    );
  }
  
  Widget _buildCell(
    BuildContext context,
    SudokuCell cell,
    bool isSelected,
    bool isHighlighted,
    AppTheme appTheme,
    VoidCallback onTap,
  ) {
    
    Color backgroundColor = appTheme.backgroundColor;
    Color textColor = appTheme.textColor;

    // Logica para pintar los cuadrantes 3x3
    // Calcula la posición del cuadrante (0-8)
    final quadRow = cell.row ~/ 3;
    final quadCol = cell.col ~/ 3;
    // Calcula el índice del cuadrante (1-9)
    final quadrantIndex = (quadRow * 3) + quadCol + 1;
    // Lista de cuadrantes que deben tener el color alterno (2, 4, 6, 8)
    const bandedQuadrants = [2, 4, 6, 8];

    if (bandedQuadrants.contains(quadrantIndex)) {
        // Asigna el color alterno para estos cuadrantes
         backgroundColor = appTheme.backgroundColor2; 
    }

    
    if (isSelected) {
      backgroundColor = appTheme.selectedCellColor;
    } else if (isHighlighted) {
      backgroundColor = appTheme.selectedCellColor.withValues(alpha:0.3);
    }
    
    switch (cell.state) {
      case CellState.given:
        textColor = appTheme.givenCellColor;
        break;
      case CellState.filled:
        textColor = appTheme.filledCellColor;
        break;
      case CellState.error:
        textColor = appTheme.errorCellColor;
        backgroundColor = appTheme.errorCellColor.withValues(alpha:0.1);
        break;
      case CellState.empty:
        textColor = appTheme.textColor;
        break;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(
            color: appTheme.sudokuGridColor,
            // width: _getBorderWidth(cell.row, cell.col),
            width: 0.5,
          ),
        ),
        child: Center(
          child: Text(
            cell.value?.toString() ?? '',
            style: TextStyle(
              fontSize: 24,
              fontWeight: cell.isGiven ? FontWeight.bold : FontWeight.normal,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }

  /*double _getBorderWidth(int row, int col) {
    double width = 0.5;
    
    // Bordes más gruesos para los cuadros 3x3
    if (row % 3 == 0) width = 5.0;
    if (col % 3 == 0) width = 5.0;
    
    return width;
  }*/

  bool _isInSameBox(int row1, int col1, int? row2, int? col2) {
    if (row2 == null || col2 == null) return false;
    
    final box1StartRow = (row1 ~/ 3) * 3;
    final box1StartCol = (col1 ~/ 3) * 3;
    final box2StartRow = (row2 ~/ 3) * 3;
    final box2StartCol = (col2 ~/ 3) * 3;
    
    return box1StartRow == box2StartRow && box1StartCol == box2StartCol;
  }
}
