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
    displayName: 'Cruz Roja',
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

  static const matrix = AppTheme(
    name: 'matrix',
    displayName: 'Matrix',
    code: 'MATRIX',
    colors: {
      'primary': Color(0xFF00FF41),                     // verde neón
      'secondary': Color(0xFF00C853),                   // verde secundario
      'background': Color(0xFF000000),                  // negro total
      'background2': Color(0xFF050B06),                 // casi negro
      'surface': Color(0xFF0A1410),                     // panel oscuro
      'text': Color(0xFFA0F2B0),                        // verde claro legible
      'grid': Color(0xFF00C853),                        // líneas de grilla
      'selected': Color(0xFF003B1F),                    // celda seleccionada
      'given': Color(0xFF00FF41),                       // números dados
      'filled': Color(0xFF0AFF66),                      // números jugador
      'error': Color(0xFFFF1744),                       // error (igual que blue)
    },
  );

  static const bocajr = AppTheme(
    name: 'bocajr',
    displayName: 'BOCA JR',
    code: 'BOCAJR',
    colors: {
      'primary': Color(0xFFFFCB05),                     // amarillo dorado
      'secondary': Color(0xFF002561),                   // azul profundo
      'background': Color(0xFF002561),                  // fondo azul
      'background2': Color(0xFF003A8C),                 // azul algo más claro
      'surface': Color(0xFF0A2F73),                     // paneles
      'text': Color(0xFFFFEE58),                        // texto amarillo claro
      'grid': Color(0xFFFFCB05),                        // líneas de grilla
      'selected': Color(0xFFFFE082),                    // celda seleccionada
      'given': Color(0xFFFFCB05),                       // números dados
      'filled': Color(0xFFFFE082),                      // números jugador
      'error': Color(0xFFFF1744),
    },
  );

  static const wololo = AppTheme(
    name: 'wololo',
    displayName: 'Age Of Empires',
    code: 'WOLOLO',
    colors: {
      'primary': Color(0xFF0045A0),                     // azul equipo
      'secondary': Color(0xFFA00000),                   // rojo equipo
      'background': Color(0xFFF0E0C0),                  // papiro
      'background2': Color(0xFFF8EDDA),                 // papiro claro
      'surface': Color(0xFFFDF4E3),                     // paneles
      'text': Color(0xFF4A2B15),                        // marrón tinta
      'grid': Color(0xFF7B4B26),                        // líneas pergamino
      'selected': Color(0xFFFFF2D5),                    // celda seleccionada
      'given': Color(0xFF0045A0),                       // números dados (azul)
      'filled': Color(0xFFA00000),                      // números jugador (rojo)
      'error': Color(0xFFC62828),
    },
  );

  static const gameboy = AppTheme(
    name: 'gameboy',
    displayName: 'GAME BOY',
    code: 'GBDMG1',
    colors: {
      'primary': Color(0xFF4A6B3F),                     // verde oscuro
      'secondary': Color(0xFF8BAE67),                   // verde medio
      'background': Color(0xFFCADFA4),                  // verde claro (fondo)
      'background2': Color(0xFFA8C27C),                 // verde intermedio
      'surface': Color(0xFFDCE8B8),                     // paneles
      'text': Color(0xFF2E4728),                        // texto/num oscuro
      'grid': Color(0xFF8BAE67),                        // líneas de grilla
      'selected': Color(0xFFE8F3C8),                    // celda seleccionada
      'given': Color(0xFF4A6B3F),                       // números dados
      'filled': Color(0xFF2E4728),                      // números jugador
      'error': Color(0xFFB71C1C),
    },
  );

  static const List<AppTheme> allThemes = [light, dark, blue, red, matrix, bocajr, wololo, gameboy];

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
