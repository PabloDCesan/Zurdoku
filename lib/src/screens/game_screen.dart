import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../models/sudoku.dart';
import '../models/theme.dart';
import '../providers/game_provider.dart';
import '../providers/progress_provider.dart';
import '../widgets/sudoku_grid.dart';
import '../widgets/game_timer.dart';
import '../widgets/victory_dialog.dart';
import '../widgets/number_buttons.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  late Timer _timer;
  late StreamController<Duration> _timerController;

  @override
  void initState() {
    super.initState();
    _timerController = StreamController<Duration>.broadcast();
    _startTimer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Escuchar cambios en el estado del juego para mostrar victoria
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final gameState = ref.read(gameProvider);
      if (gameState.isGameCompleted && gameState.selectedDifficulty != null) {
        _showVictoryDialog(gameState.elapsedTime, gameState.selectedDifficulty!);
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _timerController.close();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final gameState = ref.read(gameProvider);
      if (gameState.isGameActive && !gameState.isGameCompleted) {
        final elapsed = gameState.elapsedTime + const Duration(seconds: 1);
        ref.read(gameProvider.notifier).updateElapsedTime(elapsed);
        _timerController.add(elapsed);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gameState = ref.watch(gameProvider);
    final progress = ref.watch(progressProvider);
    
    if (gameState.currentBoard == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/main-menu'),
          ),
        ),
        body: const Center(
          child: Text('No hay juego activo'),
        ),
      );
    }

    final difficulty = gameState.selectedDifficulty!;
    final bestTime = progress.getBestTime(difficulty);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(_getDifficultyName(difficulty)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/main-menu'),
        ),
        // actions: [
        //  IconButton(
        //    icon: const Icon(Icons.palette),
        //    onPressed: () => _showThemeDrawer(context),
        //  ),
        //],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Información superior
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Mejor tiempo
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mejor tiempo',
                        style: theme.textTheme.bodySmall,
                      ),
                      Text(
                        bestTime != null 
                          ? _formatDuration(bestTime)
                          : '--:--',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  
                  // Cronómetro
                  GameTimer(
                    timerController: _timerController,
                    initialDuration: gameState.elapsedTime,
                  ),
                  
                  // Botón de tema
                  IconButton(
                    icon: const Icon(Icons.palette),
                    onPressed: () => _showThemeDrawer(context),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 25),

            // Grilla de Sudoku
            //Expanded(
            Container(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: SudokuGrid(
                    board: gameState.currentBoard!,
                    selectedRow: gameState.selectedRow,
                    selectedCol: gameState.selectedCol,
                    onCellSelected: (row, col) {
                      ref.read(gameProvider.notifier).selectCell(row, col);
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 25),
            // Botones numéricos
            NumberButtons(
              onNumberPressed: (number) {
                ref.read(gameProvider.notifier).fillCell(number);
              },
              onClearPressed: () {
                ref.read(gameProvider.notifier).clearCell();
              },
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }


  void _showThemeDrawer(BuildContext context) {
    final progress = ref.read(progressProvider);
    
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Seleccionar Tema',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            
            // Lista de temas
            ...AppThemes.allThemes.where((theme) => 
              progress.isThemeUnlocked(theme.name)
            ).map((theme) => RadioListTile<String>(
              title: Text(theme.displayName),
              value: theme.name,
              groupValue: progress.currentTheme,
              onChanged: (value) {
                if (value != null) {
                  ref.read(progressProvider.notifier).setCurrentTheme(value);
                  Navigator.of(context).pop();
                }
              },
            )),
          ],
        ),
      ),
    );
  }

  String _getDifficultyName(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.beginner:
        return 'PRINCIPIANTE';
      case Difficulty.medium:
        return 'MEDIO';
      case Difficulty.advanced:
        return 'AVANZADO';
      case Difficulty.expert:
        return 'EXPERTO';
      case Difficulty.master:
        return 'MAESTRO';
    }
  }

  void _showVictoryDialog(Duration completionTime, Difficulty difficulty) {
    // Actualizar el mejor tiempo si es necesario
    ref.read(progressProvider.notifier).updateBestTime(difficulty, completionTime);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => VictoryDialog(
        completionTime: completionTime,
        difficulty: difficulty,
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
