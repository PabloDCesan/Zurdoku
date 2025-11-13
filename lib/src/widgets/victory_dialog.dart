import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/sudoku.dart';
import '../providers/progress_provider.dart';
import 'package:flutter/services.dart';

import '../repos/providers.dart' show leaderboardRepoProvider;

class VictoryDialog extends ConsumerStatefulWidget {
  final Duration completionTime;
  final Difficulty difficulty;

  const VictoryDialog({
    super.key,
    required this.completionTime,
    required this.difficulty,
  });

  @override
  ConsumerState<VictoryDialog> createState() => _VictoryDialogState();
  }

  class _VictoryDialogState extends ConsumerState<VictoryDialog> {
    bool _submitted = false;

    @override
    void initState() {
      super.initState();

      // Ejecutamos una sola vez post-frame para no bloquear el build.
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (_submitted) return;
        _submitted = true;

        /*
        final time = widget.completionTime;
        final diff = widget.difficulty;
        final uid = FirebaseAuth.instance.currentUser?.uid;

        if (uid != null) {
          await ref.read(leaderboardRepoProvider).submit(
            difficulty: widget.difficulty,
            timeSec: widget.completionTime.inSeconds,
            uid: uid,
            name: null, // o tu displayName si después agregás login real
          );
        }
        
        await ref.read(progressProvider.notifier)
           .updateBestTime(widget.difficulty, widget.completionTime);
      });
    }
    */
        try {
        // 1) Subir score (el repo toma uid internamente)
        await ref.read(leaderboardRepoProvider).submit(
          difficulty: widget.difficulty,
          timeSec: widget.completionTime.inSeconds,
          name: null, // o tu displayName si luego querés mostrarlo
        );
      } catch (e) {
        // opcional: loguear o mostrar SnackBar si querés
        // debugPrint('submit leaderboard error: $e');
      }

      // 2) Actualizar best time local
      await ref
          .read(progressProvider.notifier)
          .updateBestTime(widget.difficulty, widget.completionTime);
    });
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = ref.watch(progressProvider);
    final bestTime = progress.getBestTime(widget.difficulty);
    final isNewRecord = bestTime == null || widget.completionTime < bestTime;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icono de victoria
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.emoji_events,
                size: 50,
                color: Colors.green.shade600,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Título
            Text(
              '¡Victoria!',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: Colors.green.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Tiempo de completado
            Text(
              'Tiempo: ${_formatDuration(widget.completionTime)}',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            // Mensaje de récord
            if (isNewRecord) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '¡NUEVO RÉCORD!',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.amber.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
            
            const SizedBox(height: 24),
            
            // Botones
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.go('/difficulty');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('JUEGO NUEVO'),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.go('/main-menu');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade600,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('MENÚ PRINCIPAL'),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Cerrar la aplicación
                  SystemNavigator.pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                ),
                child: const Text('SALIR'),
              ),
            ),
          ],
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
