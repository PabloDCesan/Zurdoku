import 'package:flutter/material.dart';
import 'dart:async';

class GameTimer extends StatefulWidget {
  final StreamController<Duration> timerController;
  final Duration initialDuration;

  const GameTimer({
    super.key,
    required this.timerController,
    required this.initialDuration,
  });

  @override
  State<GameTimer> createState() => _GameTimerState();
}

class _GameTimerState extends State<GameTimer> {
  late Duration _currentDuration;
  late StreamSubscription<Duration> _timerSubscription;

  @override
  void initState() {
    super.initState();
    _currentDuration = widget.initialDuration;
    
    _timerSubscription = widget.timerController.stream.listen((duration) {
      if (mounted) {
        setState(() {
          _currentDuration = duration;
        });
      }
    });
  }

  @override
  void dispose() {
    _timerSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Tiempo',
          style: theme.textTheme.bodySmall,
        ),
        Text(
          _formatDuration(_currentDuration),
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.primaryColor,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
