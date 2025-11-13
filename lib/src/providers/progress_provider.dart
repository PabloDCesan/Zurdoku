import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/sudoku.dart';

class ProgressStateNotifier extends Notifier<GameProgress> {
  @override
  GameProgress build() {
    _loadProgress();
    return GameProgress();
  }

  Future<void> _loadProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Cargar mejores tiempos
      final bestTimesJson = prefs.getString('best_times');
      Map<Difficulty, Duration> bestTimes = {};
      if (bestTimesJson != null) {
        final Map<String, dynamic> timesMap = json.decode(bestTimesJson);
        timesMap.forEach((key, value) {
          final difficulty = Difficulty.values.firstWhere(
            (d) => d.name == key,
            orElse: () => Difficulty.facil,
          );
          bestTimes[difficulty] = Duration(milliseconds: value);
        });
      }

      // Cargar temas desbloqueados
      final unlockedThemes = prefs.getStringList('unlocked_themes') ?? ['light', 'dark'];
      
      // Cargar configuraciones
      final musicEnabled = prefs.getBool('music_enabled') ?? true;
      final soundEffectsEnabled = prefs.getBool('sound_effects_enabled') ?? true;
      final currentTheme = prefs.getString('current_theme') ?? 'light';
      final musicVolume = (prefs.getDouble('music_volume') ?? 0.7).clamp(0.0, 1.0);

      state = GameProgress(
        bestTimes: bestTimes,
        unlockedThemes: unlockedThemes,
        musicEnabled: musicEnabled,
        soundEffectsEnabled: soundEffectsEnabled,
        currentTheme: currentTheme,
        musicVolume: musicVolume,
      );
    } catch (e) {
      // Si hay error, usar valores por defecto
      state = GameProgress();
    }
  }

  Future<void> _saveProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Guardar mejores tiempos
      final bestTimesMap = <String, int>{};
      state.bestTimes.forEach((difficulty, duration) {
        bestTimesMap[difficulty.name] = duration.inMilliseconds;
      });
      await prefs.setString('best_times', json.encode(bestTimesMap));
      
      // Guardar temas desbloqueados
      await prefs.setStringList('unlocked_themes', state.unlockedThemes);
      
      // Guardar configuraciones
      await prefs.setBool('music_enabled', state.musicEnabled);
      await prefs.setBool('sound_effects_enabled', state.soundEffectsEnabled);
      await prefs.setDouble('music_volume', state.musicVolume);
      await prefs.setString('current_theme', state.currentTheme);
    } catch (e) {
      // Manejar error de guardado
    }
  }

  Future<void> updateBestTime(Difficulty difficulty, Duration time) async {
    final currentBest = state.getBestTime(difficulty);
    if (currentBest == null || time < currentBest) {
      final newBestTimes = Map<Difficulty, Duration>.from(state.bestTimes);
      newBestTimes[difficulty] = time;
      
      state = state.copyWith(bestTimes: newBestTimes);
      await _saveProgress();
    }
  }

  Future<void> unlockTheme(String themeCode) async {
    // Verificar si el código es válido
    final validCodes = ['ORTORT', 'HELPME'];
    if (!validCodes.contains(themeCode)) {
      throw Exception('Código inexistente');
    }

    // Verificar si ya está desbloqueado
    String themeName = '';
    switch (themeCode) {
      case 'ORTORT':
        themeName = 'blue';
        break;
      case 'HELPME':
        themeName = 'red';
        break;
    }

    if (state.unlockedThemes.contains(themeName)) {
      throw Exception('Código ya usado');
    }

    final newUnlockedThemes = List<String>.from(state.unlockedThemes);
    newUnlockedThemes.add(themeName);
    
    state = state.copyWith(unlockedThemes: newUnlockedThemes);
    await _saveProgress();
  }

  Future<void> setMusicEnabled(bool enabled) async {
    state = state.copyWith(musicEnabled: enabled);
    await _saveProgress();
  }

  Future<void> setSoundEffectsEnabled(bool enabled) async {
    state = state.copyWith(soundEffectsEnabled: enabled);
    await _saveProgress();
  }

  Future<void> setCurrentTheme(String theme) async {
    state = state.copyWith(currentTheme: theme);
    await _saveProgress();
  }

  Future<void> setMusicVolume(double v) async {
    final vol = v.clamp(0.0, 1.0);
    state = state.copyWith(musicVolume: vol);
    await _saveProgress();
  }

  Future<void> resetProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      state = GameProgress();
    } catch (e) {
      // Manejar error de reset
    }
  }

  Future<void> unlockThemeById(String themeId) async {
    if (state.unlockedThemes.contains(themeId)) {
      throw Exception('Tema ya desbloqueado');
    }
    final updated = List<String>.from(state.unlockedThemes)..add(themeId);
    state = state.copyWith(unlockedThemes: updated);
    await _saveProgress();
  }
}

final progressProvider = NotifierProvider<ProgressStateNotifier, GameProgress>(() {
  return ProgressStateNotifier();
});