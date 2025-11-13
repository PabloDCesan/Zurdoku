import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../audio/audio_provider.dart';

class AppAudioBootstrap extends ConsumerStatefulWidget {
  final Widget child;
  const AppAudioBootstrap({super.key, required this.child});

  @override
  ConsumerState<AppAudioBootstrap> createState() => _AppAudioBootstrapState();
}

class _AppAudioBootstrapState extends ConsumerState<AppAudioBootstrap> {
  @override
  void initState() {
    super.initState();
    // Dispara inicialización temprana
    Future.microtask(() => ref.read(audioControllerProvider).initialize());
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
