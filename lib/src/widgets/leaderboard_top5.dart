import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/sudoku.dart';
import '../repos/providers.dart'; // leaderboardRepoProvider

/// Muestra el Top-5 de una dificultad usando la subcolección
/// leaderboards/{difficulty}/scores ordenada por timeSec asc.
class LeaderboardTop5 extends ConsumerWidget {
  const LeaderboardTop5({
    super.key,
    required this.difficulty,
    this.showHeader = true,
    this.compact = false,
  });

  final Difficulty difficulty;
  final bool showHeader;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stream =
        ref.read(leaderboardRepoProvider).top5Stream(difficulty);

    final theme = Theme.of(context);
    final title = 'Top 5 - ${_label(difficulty)}';

    final content = StreamBuilder<List<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return _SkeletonList(compact: compact);
        }
        if (snap.hasError) {
          return _ErrorBox(message: 'No se pudo cargar el ranking');
        }
        final data = snap.data ?? const [];
        if (data.isEmpty) {
          return _EmptyBox(message: 'Aún no hay récords');
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: data.length,
          separatorBuilder: (_, _) =>
              Divider(height: 12, color: theme.dividerColor.withValues(alpha:0.4)),
          itemBuilder: (context, index) {
            final row = data[index];
            final timeSec = (row['timeSec'] as num?)?.toInt() ?? 0;
            final name = (row['name'] as String?)?.trim();
            final uid = (row['uid'] as String?) ?? '';
            final display = (name != null && name.isNotEmpty)
                ? name
                : _shortUid(uid);

            return _RankTile(
              rank: index + 1,
              title: display,
              timeText: _fmtTime(timeSec),
              compact: compact,
            );
          },
        );
      },
    );

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(compact ? 10 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showHeader)
              Padding(
                padding: EdgeInsets.only(bottom: compact ? 8 : 12),
                child: Text(title, style: theme.textTheme.titleMedium),
              ),
            content,
          ],
        ),
      ),
    );
  }

  String _label(Difficulty d) {
    switch (d) {
      case Difficulty.facil:     return 'Fácil';
      case Difficulty.medio:     return 'Medio';
      case Difficulty.avanzado:  return 'Avanzado';
      case Difficulty.experto:   return 'Experto';
      case Difficulty.maestro:   return 'Maestro';
    }
  }

  static String _fmtTime(int totalSeconds) {
    final m = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  static String _shortUid(String uid) {
    if (uid.isEmpty) return 'Anónimo';
    if (uid.length <= 6) return uid;
    return '${uid.substring(0, 3)}…${uid.substring(uid.length - 2)}';
  }
}

class _RankTile extends StatelessWidget {
  const _RankTile({
    required this.rank,
    required this.title,
    required this.timeText,
    required this.compact,
  });

  final int rank;
  final String title;
  final String timeText;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final medal = switch (rank) {
      1 => '🥇',
      2 => '🥈',
      3 => '🥉',
      _ => rank.toString(),
    };

    return Row(
      children: [
        SizedBox(
          width: compact ? 28 : 34,
          child: Text(
            medal,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          timeText,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontFeatures: const [FontFeature.tabularFigures()],
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _SkeletonList extends StatelessWidget {
  const _SkeletonList({required this.compact});
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final base = Container(
      height: compact ? 14 : 18,
      decoration: BoxDecoration(
        color: Theme.of(context).dividerColor.withValues(alpha:0.25),
        borderRadius: BorderRadius.circular(4),
      ),
    );

    return Column(
      children: List.generate(5, (i) => i).map((_) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: compact ? 6 : 8),
          child: Row(
            children: [
              SizedBox(width: compact ? 28 : 34),
              const SizedBox(width: 8),
              Expanded(child: base),
              const SizedBox(width: 8),
              SizedBox(width: 48, child: base),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _EmptyBox extends StatelessWidget {
  const _EmptyBox({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text(
        message,
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(color: Colors.black.withValues(alpha:0.6)),
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: Theme.of(context)
          .textTheme
          .bodyMedium
          ?.copyWith(color: Colors.redAccent),
    );
  }
}
