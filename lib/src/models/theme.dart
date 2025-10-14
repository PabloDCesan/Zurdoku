import 'package:flutter/material.dart';

class AppTheme {
  final String name;
  final String displayName;
  final String code;
  final Map<String, Color> colors;

  const AppTheme({
    required this.name,
    required this.displayName,
    required this.code,
    required this.colors,
  });

  Color get primaryColor => colors['primary'] ?? Colors.blue;
  Color get secondaryColor => colors['secondary'] ?? Colors.grey;
  Color get backgroundColor => colors['background'] ?? Colors.white;
  Color get backgroundColor2 => colors['secondaryBackground'] ?? const Color.fromARGB(255, 138, 130, 130);
  Color get surfaceColor => colors['surface'] ?? Colors.white;
  Color get textColor => colors['text'] ?? Colors.black;
  Color get sudokuGridColor => colors['grid'] ?? Colors.black;
  Color get selectedCellColor => colors['selected'] ?? Colors.blue.shade200;
  Color get givenCellColor => colors['given'] ?? Colors.black;
  Color get filledCellColor => colors['filled'] ?? Colors.blue;
  Color get errorCellColor => colors['error'] ?? Colors.red;
}

// Temas predefinidos
class AppThemes {
  static const light = AppTheme(
    name: 'light',
    displayName: 'Claro',
    code: '',
    colors: {
      'primary': Color(0xFF2196F3),
      'secondary': Color(0xFF757575),
      'background': Color(0xFFFFFFFF),
      'background2': Color.fromARGB(255, 156, 147, 147),
      'surface': Color(0xFFFFFFFF),
      'text': Color(0xFF000000),
      'grid': Color(0xFF000000),
      'selected': Color.fromARGB(255, 239, 241, 89),
      'given': Color(0xFF000000),
      'filled': Color(0xFF2196F3),
      'error': Color(0xFFFF5722),
    },
  );

  static const dark = AppTheme(
    name: 'dark',
    displayName: 'Oscuro',
    code: '',
    colors: {
      'primary': Color(0xFF90CAF9),
      'secondary': Color(0xFFBDBDBD),
      'background': Color(0xFF121212),
      'background2': Color.fromARGB(255, 54, 53, 53),
      'surface': Color.fromARGB(255, 160, 147, 147),
      'text': Color(0xFFFFFFFF),
      'grid': Color(0xFFFFFFFF),
      'selected': Color.fromARGB(255, 140, 151, 180),
      'given': Color(0xFFFFFFFF),
      'filled': Color(0xFF90CAF9),
      'error': Color(0xFFFF6B6B),
    },
  );

  static const blue = AppTheme(
    name: 'blue',
    displayName: 'ORT!',
    code: 'ORTORT',
    colors: {
      'primary': Color(0xFF1976D2),
      'secondary': Color(0xFF424242),
      'background': Color.fromARGB(255, 131, 194, 243),
      'background2': Color.fromARGB(255, 187, 223, 230),
      'surface': Color(0xFFF5F9FF),
      'text': Color(0xFF0D47A1),
      'grid': Color(0xFF1565C0),
      'selected': Color(0xFFBBDEFB),
      'given': Color(0xFF0D47A1),
      'filled': Color(0xFF1976D2),
      'error': Color(0xFFFF1744),
    },
  );

  static const red = AppTheme(
    name: 'red',
    displayName: '<3',
    code: 'HELPME',
    colors: {
      'primary': Color(0xFFD32F2F),
      'secondary': Color(0xFF424242),
      'background': Color(0xFFFFF5F5),
      'background2': Color.fromARGB(255, 238, 152, 152),
      'surface': Color(0xFFFFFFFF),
      'text': Color.fromARGB(255, 0, 0, 0),
      'grid': Color(0xFFD32F2F),
      'selected': Color(0xFFFFCDD2),
      'given': Color.fromARGB(255, 255, 0, 0),
      'filled': Color(0xFFD32F2F),
      'error': Color(0xFFFF5722),
    },
  );

  static const List<AppTheme> allThemes = [light, dark, blue, red];

  static AppTheme getThemeByName(String name) {
    return allThemes.firstWhere(
      (theme) => theme.name == name,
      orElse: () => light,
    );
  }

  static AppTheme? getThemeByCode(String code) {
    try {
      return allThemes.firstWhere((theme) => theme.code == code);
    } catch (e) {
      return null;
    }
  }
}
