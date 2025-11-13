// lib/src/audio/audio_controller.dart
import 'dart:async' show Completer, Timer, unawaited;
import 'dart:math';
import 'package:flutter/widgets.dart';
import 'package:flutter_soloud/flutter_soloud.dart';

class AudioController with WidgetsBindingObserver {
  AudioController({double initialVolume = 0.7})
      : _volume = _clamp01(initialVolume);

  // Engine (singleton)
  final SoLoud _soloud = SoLoud.instance;
  final _rng = Random();

  // Cache de assets cargados para evitar re-cargas
  final Map<String, AudioSource> _cache = {};

  // Manejo de qué suena ahora
  String? _currentAsset;
  SoundHandle? _currentHandle;

  // Volumen/mute
  double _volume; // 0..1
  bool _muted = false;

  // Rutas de audio
  static const String menuAsset = 'assets/audio/menu_ppal.mp3';
  static const List<String> gameAssets = [
    'assets/audio/game/fondo_01.mp3',
    'assets/audio/game/fondo_02.mp3',
    'assets/audio/game/fondo_03.mp3',
    'assets/audio/game/fondo_04.mp3',
    'assets/audio/game/fondo_05.mp3',
    'assets/audio/game/fondo_06.mp3',
    'assets/audio/game/fondo_07.mp3',
    'assets/audio/game/fondo_08.mp3',
    'assets/audio/game/fondo_09.mp3',
    'assets/audio/game/fondo_10.mp3',
    'assets/audio/game/fondo_11.mp3',
  ];

  bool _initialized = false;

  // ---------- Lifecycle de engine ----------
  Future<void>? _initFuture;

  Future<void> initialize() {
    // Si ya inicializó, devolvemos un Future completado.
    if (_initialized) return Future.value();

    // Si hay una init en curso, devolvemos ese mismo Future.
    final inFlight = _initFuture;
    if (inFlight != null) return inFlight;

    // Creamos y guardamos el Future de inicialización para compartirlo.
    final completer = Completer<void>();
    _initFuture = completer.future;

    () async {
      try {
        await _soloud.init();
        WidgetsBinding.instance.addObserver(this);

        // Volumen global inicial
        _soloud.setGlobalVolume(_effectiveVolume);

        // Precarga
        await _preload(menuAsset);
        for (final a in gameAssets) {
          // si tu SDK no tiene unawaited, podés hacer _preload(a);
          unawaited(_preload(a));
        }

        _initialized = true;
        completer.complete();
      } catch (e) {
        completer.completeError(e);
        rethrow;
      } finally {
        // Importante: si falló, permitimos reintentos
        if (!_initialized) {
          _initFuture = null;
        }
      }
    }();

    return _initFuture!;
  }

  Future<void> dispose() async {
    WidgetsBinding.instance.removeObserver(this);
    await fadeOutCurrent(const Duration(milliseconds: 150)); // detiene lo actual

    // Liberar fuentes cacheadas
    for (final s in _cache.values) {
      try {
        await _soloud.disposeSource(s);
      } catch (_) {}
    }
    _cache.clear();

    try {
      _soloud.deinit();
    } catch (_) {}
  }

  // ---------- App lifecycle (pausar/reanudar) ----------
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_initialized) return;

    const pausedStates = {
      AppLifecycleState.paused,
      AppLifecycleState.inactive,
      AppLifecycleState.detached,
      AppLifecycleState.hidden, // web/desktop
    };

    if (pausedStates.contains(state)) {
      if (_currentHandle != null) {
        try {
          _soloud.setPause(_currentHandle!, true);
        } catch (_) {}
      }
      return;
    }

    if (state == AppLifecycleState.resumed) {
      if (!_muted && _currentHandle != null) {
        try {
          _soloud.setPause(_currentHandle!, false);
        } catch (_) {}
      }
      return;
    }
  }

  // ---------- API pública ----------
  /// Reproduce el tema del menú (loop), con crossfade suave.
  Future<void> playMenuMusic({
    Duration crossfade = const Duration(milliseconds: 350),
  }) async {
    await initialize();
    await _playLoop(menuAsset, crossfade: crossfade);
  }

  /// Elige al azar un tema de juego y lo reproduce en loop (crossfade suave).
  Future<void> playRandomGameMusic({
    Duration crossfade = const Duration(milliseconds: 350),
  }) async {
    await initialize();
    if (gameAssets.isEmpty) return;

    String pick;
    if (gameAssets.length >= 2 && _currentAsset != null) {
      final candidates =
          gameAssets.where((a) => a != _currentAsset).toList(growable: false);
      pick = candidates[_rng.nextInt(candidates.length)];
    } else {
      pick = gameAssets[_rng.nextInt(gameAssets.length)];
    }
    await _playLoop(pick, crossfade: crossfade);
  }

  Future<void> pause() async {
    await initialize();
    if (_currentHandle != null) {
      try {
        _soloud.setPause(_currentHandle!, true);
      } catch (_) {}
    }
  }

  Future<void> resume() async {
    await initialize();
    if (!_muted && _currentHandle != null) {
      try {
        _soloud.setPause(_currentHandle!, false);
      } catch (_) {}
    }
  }

  Future<void> stop() async {
    await initialize();
    if (_currentHandle != null) {
      try {
        _soloud.stop(_currentHandle!);
      } catch (_) {}
      _currentHandle = null;
    }
    _currentAsset = null;
  }

  Future<void> setVolume(double v) async {
    _volume = _clamp01(v);
    if (_currentHandle != null) {
      try {
        _soloud.setVolume(_currentHandle!, _effectiveVolume);
      } catch (_) {}
    } else {
      _soloud.setGlobalVolume(_effectiveVolume);
    }
  }

  Future<void> mute(bool on) async {
    _muted = on;
    if (_currentHandle != null) {
      try {
        _soloud.setVolume(_currentHandle!, _effectiveVolume);
      } catch (_) {}
    } else {
      _soloud.setGlobalVolume(_effectiveVolume);
    }
    // Pausar/reanudar según mute
    if (_muted) {
      if (_currentHandle != null) {
        try {
          _soloud.setPause(_currentHandle!, true);
        } catch (_) {}
      }
    } else {
      if (_currentHandle != null) {
        try {
          _soloud.setPause(_currentHandle!, false);
        } catch (_) {}
      }
    }
  }

  // ---------- Internos ----------
  static double _clamp01(double v) => v < 0 ? 0 : (v > 1 ? 1 : v);
  double get _effectiveVolume => _muted ? 0.0 : _volume;

  Future<AudioSource> _preload(String asset) async {
    if (_cache.containsKey(asset)) return _cache[asset]!;
    final src = await _soloud.loadAsset(asset);
    _cache[asset] = src;
    return src;
  }

  Future<void> _playLoop(
    String asset, {
    Duration crossfade = const Duration(milliseconds: 350),
  }) async {
    if (_currentAsset == asset && _currentHandle != null) {
      // Ya está sonando
      return;
    }

    final newSrc = await _preload(asset);

    // Arrancamos el nuevo con volumen 0 para poder hacer crossfade
    final newHandle = await _soloud.play(newSrc, looping: true);
    _soloud.setVolume(newHandle, 0.0);

    final oldHandle = _currentHandle;
    _currentHandle = newHandle;
    _currentAsset = asset;

    // Crossfade manual (lineal)
    const int steps = 10;
    final int intervalMs =
        (crossfade.inMilliseconds / steps).clamp(16, 250).toInt();

    double t = 0;
    final timer = Timer.periodic(Duration(milliseconds: intervalMs), (tmr) {
      t += 1 / steps;
      final up = (_effectiveVolume * t).clamp(0.0, _effectiveVolume);
      final down = (_effectiveVolume * (1 - t)).clamp(0.0, _effectiveVolume);
      try {
        _soloud.setVolume(newHandle, up);
        if (oldHandle != null) _soloud.setVolume(oldHandle, down);
      } catch (_) {}
      if (t >= 1.0) {
        tmr.cancel();
        try {
          _soloud.setVolume(newHandle, _effectiveVolume);
          if (oldHandle != null) _soloud.stop(oldHandle);
        } catch (_) {}
      }
    });

    // Por seguridad auto-cancel si algo raro pasa
    Future.delayed(crossfade + const Duration(milliseconds: 200)).then((_) {
      if (timer.isActive) timer.cancel();
    });
  }

  Future<void> fadeOutCurrent(Duration d) async {
    if (_currentHandle == null) return;
    final handle = _currentHandle!;

    const int steps = 10;
    final int intervalMs = (d.inMilliseconds / steps).clamp(16, 250).toInt();
    double t = 1.0;
    final c = Completer<void>();

    final timer = Timer.periodic(Duration(milliseconds: intervalMs), (tmr) {
      t -= 1 / steps;
      final v = (_effectiveVolume * t).clamp(0.0, _effectiveVolume);
      try {
        _soloud.setVolume(handle, v);
      } catch (_) {}
      if (t <= 0) {
        tmr.cancel();
        try {
          _soloud.stop(handle);
        } catch (_) {}
        if (_currentHandle == handle) {
          _currentHandle = null;
          _currentAsset = null;
        }
        c.complete();
      }
    });

    Future.delayed(d + const Duration(milliseconds: 200)).then((_) {
      if (timer.isActive) timer.cancel();
      if (!c.isCompleted) c.complete();
    });
    return c.future;
  }
}
