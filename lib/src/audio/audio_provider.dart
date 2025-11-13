import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'audio_controller.dart';

final audioControllerProvider = Provider<AudioController>((ref) {
  final c = AudioController(initialVolume: 0.7);
  // async para no bloquear nada
  unawaited(c.initialize());
  ref.onDispose(() {
    unawaited(c.dispose());
  });
  return c;
});