import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/sudoku.dart';
import '../providers/game_provider.dart';
import '../providers/progress_provider.dart';

class DifficultySelectionScreen extends ConsumerWidget {
  const DifficultySelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final progress = ref.watch(progressProvider);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Seleccionar Dificultad'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/main-menu'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Título
              Text(
                'Elige la dificultad',
                style: theme.textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 40),
              
              // Lista de dificultades
              Expanded(
                child: ListView(
                  children: [
                    _buildDifficultyCard(
                      context: context,
                      ref: ref,
                      difficulty: Difficulty.beginner,
                      title: 'Principiante',
                      description: 'Perfecto para empezar',
                      icon: Icons.child_care,
                      color: Colors.green,
                      progress: progress,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    _buildDifficultyCard(
                      context: context,
                      ref: ref,
                      difficulty: Difficulty.medium,
                      title: 'Medio',
                      description: 'Un desafío moderado',
                      icon: Icons.psychology,
                      color: Colors.orange,
                      progress: progress,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    _buildDifficultyCard(
                      context: context,
                      ref: ref,
                      difficulty: Difficulty.advanced,
                      title: 'Avanzado',
                      description: 'Para jugadores experimentados',
                      icon: Icons.smart_toy,
                      color: Colors.red,
                      progress: progress,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    _buildDifficultyCard(
                      context: context,
                      ref: ref,
                      difficulty: Difficulty.expert,
                      title: 'Experto',
                      description: 'Un verdadero desafío',
                      icon: Icons.emoji_events,
                      color: Colors.purple,
                      progress: progress,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    _buildDifficultyCard(
                      context: context,
                      ref: ref,
                      difficulty: Difficulty.master,
                      title: 'Maestro',
                      description: 'Solo para los mejores',
                      icon: Icons.diamond,
                      color: Colors.amber,
                      progress: progress,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyCard({
    required BuildContext context,
    required WidgetRef ref,
    required Difficulty difficulty,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required GameProgress progress,
  }) {
    final theme = Theme.of(context);
    final bestTime = progress.getBestTime(difficulty);
    
    return Card(
      elevation: 6,
      shadowColor: color.withValues(alpha:0.3),
      child: InkWell(
        onTap: () {
          ref.read(gameProvider.notifier).startNewGame(difficulty);
          context.go('/game');
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              // Icono
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 30,
                ),
              ),
              
              const SizedBox(width: 20),
              
              // Información
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color?..withValues(alpha:0.7),
                      ),
                    ),
                    if (bestTime != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.timer,
                            size: 16,
                            color: theme.primaryColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Mejor tiempo: ${_formatDuration(bestTime)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              
              // Flecha
              Icon(
                Icons.arrow_forward_ios,
                color: theme.primaryColor,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
