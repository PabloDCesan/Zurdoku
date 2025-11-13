import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/sudoku.dart';
import '../models/theme.dart';
import '../providers/game_provider.dart';
import '../providers/progress_provider.dart';
import '../widgets/sudoku_grid.dart';
import '../widgets/game_timer.dart';
import '../widgets/victory_dialog.dart';
import '../widgets/number_buttons.dart';
import '../audio/audio_provider.dart';
import '../audio/audio_controller.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});
  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  late Timer _timer;
  late final StreamController<Duration> _timerController =
      StreamController<Duration>.broadcast();

  late final AudioController _audio; // cache del controller
  ProviderSubscription<bool>? _solvedSub;
  bool _victoryShown = false;

  @override
  void initState() {
    super.initState();

    _audio = ref.read(audioControllerProvider);
    _startTimer();

    // Música de juego (no bloqueante)
    Future.microtask(() => _audio.playRandomGameMusic());

    // Suscripción lifecycle-friendly al flag de victoria
    _solvedSub = ref.listenManual<bool>(
      gameProvider.select((g) => g.isGameCompleted),
      (prev, isSolved) {
        if (isSolved == true && !_victoryShown) {
          _victoryShown = true;
          _timer.cancel();
          // fundido suave opcional
          _audio.fadeOutCurrent(const Duration(milliseconds: 200));

          WidgetsBinding.instance.addPostFrameCallback((_) async {
            if (!context.mounted) return;
            final game = ref.read(gameProvider);
            final diff = game.selectedDifficulty;
            if (diff == null) return; // seguridad

            // Actualiza best-time antes de mostrar el diálogo
            await ref
                .read(progressProvider.notifier)
                .updateBestTime(diff, game.elapsedTime);

            if (!mounted) return; // chequeo x las dudas...

            
            await showDialog( 
              context: context, // ignore: use_build_context_synchronously
              barrierDismissible: false,
              builder: (_) => VictoryDialog(
                completionTime: game.elapsedTime,
                difficulty: diff,
              ),
            );

            if (!context.mounted) return;
            // otra partida?:
            _victoryShown = false;
          });
        }
      },
      fireImmediately: false, // no dispares al montar
    );

    // Si por algún motivo entrás con juego ya resuelto, mostralo una vez
    Future.microtask(() {
      final g = ref.read(gameProvider);
      if (g.isGameCompleted && g.selectedDifficulty != null && !_victoryShown) {
        _solvedSub?.read(); // forzar chequeo inmediato
        // o directamente trigger manual como arriba si preferís
      }
    });
  }

  @override
  void dispose() {
    // Cerrar subs y recursos sin usar ref aquí
    _solvedSub?.close();
    _timer.cancel();
    _timerController.close();

    // Volver a música de menú
    _audio.playMenuMusic();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final game = ref.read(gameProvider);
      if (game.isGameActive && !game.isGameCompleted) {
        final next = game.elapsedTime + const Duration(seconds: 1);
        ref.read(gameProvider.notifier).updateElapsedTime(next);
        _timerController.add(next);
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
        body: const Center(child: Text('No hay juego activo')),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.palette),
            onPressed: () => _showThemeDrawer(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header: mejor tiempo / cronómetro / tema
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Mejor tiempo', style: theme.textTheme.bodySmall),
                      Text(
                        bestTime != null ? _formatDuration(bestTime) : '--:--',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  GameTimer(
                    timerController: _timerController,
                    initialDuration: gameState.elapsedTime,
                  ),
                  IconButton(
                    icon: const Icon(Icons.palette),
                    onPressed: () => _showThemeDrawer(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // Grilla
            Padding(
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
            const SizedBox(height: 25),

            // Botonera
            NumberButtons(
              onNumberPressed: (n) {
                ref.read(gameProvider.notifier).fillCell(n);
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
    final unlockedThemes = AppThemes.allThemes
        .where((t) => progress.isThemeUnlocked(t.name)).toList();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Seleccionar Tema',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 20),
            /* eliminado por deprecado:
            ...AppThemes.allThemes
                .where((t) => progress.isThemeUnlocked(t.name))
                .map((t) => RadioListTile<String>(
                      title: Text(t.displayName),
                      value: t.name,
                      groupValue: progress.currentTheme,
                      onChanged: (v) {
                        if (v != null) {
                          ref
                              .read(progressProvider.notifier)
                              .setCurrentTheme(v);
                          Navigator.of(context).pop();
                        }
                      },
                    )
                    */
          // no deprecado: RadioGroup
          RadioGroup<String>(
            groupValue: progress.currentTheme,
            onChanged: (value) {
              if (value != null) {
                ref
                    .read(progressProvider.notifier)
                    .setCurrentTheme(value);
                Navigator.of(context).pop();
              }
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final t in unlockedThemes)
                  RadioListTile<String>(
                    title: Text(t.displayName),
                    value: t.name,    
              
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

  String _getDifficultyName(Difficulty d) {
    switch (d) {
      case Difficulty.facil:
        return 'PRINCIPIANTE';
      case Difficulty.medio:
        return 'MEDIO';
      case Difficulty.avanzado:
        return 'AVANZADO';
      case Difficulty.experto:
        return 'EXPERTO';
      case Difficulty.maestro:
        return 'MAESTRO';
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:'
           '${seconds.toString().padLeft(2, '0')}';
  }
}
