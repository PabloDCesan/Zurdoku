import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/theme.dart';
import '../providers/progress_provider.dart';

class AppThemeData {
  final ThemeData lightTheme;
  final ThemeData darkTheme;
  final ThemeMode themeMode;

  AppThemeData({
    required this.lightTheme,
    required this.darkTheme,
    required this.themeMode,
  });
}

final currentThemeProvider = Provider<AppThemeData>((ref) {
  final progress = ref.watch(progressProvider);
  final currentTheme = AppThemes.getThemeByName(progress.currentTheme);
  
  return AppThemeData(
    lightTheme: _buildTheme(currentTheme, Brightness.light),
    darkTheme: _buildTheme(currentTheme, Brightness.dark),
    themeMode: progress.currentTheme == 'dark' ? ThemeMode.dark : ThemeMode.light,
  );
});

ThemeData _buildTheme(AppTheme appTheme, Brightness brightness) {
  
  return ThemeData(
    brightness: brightness,
    useMaterial3: true,
    
    // Colores principales
    colorScheme: ColorScheme.fromSeed(
      seedColor: appTheme.primaryColor,
      brightness: brightness,
      primary: appTheme.primaryColor,
      secondary: appTheme.secondaryColor,
      surface: appTheme.surfaceColor,
      //background: appTheme.backgroundColor,
    ),
    
    // Scaffold
    scaffoldBackgroundColor: appTheme.backgroundColor,
    
    // AppBar
    appBarTheme: AppBarTheme(
      backgroundColor: appTheme.surfaceColor,
      foregroundColor: appTheme.textColor,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: appTheme.textColor,
      ),
    ),
    
    // Botones elevados
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: appTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        shadowColor: appTheme.primaryColor.withValues(alpha:0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    // Botones de texto
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: appTheme.primaryColor,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    // Botones con iconos
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: appTheme.primaryColor,
      ),
    ),
    
    // Texto
    textTheme: TextTheme(
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: appTheme.textColor,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: appTheme.textColor,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: appTheme.textColor,
      ),
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: appTheme.textColor,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: appTheme.textColor,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: appTheme.textColor,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: appTheme.textColor,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        color: appTheme.textColor,
      ),
    ),
    
    // Drawer
    drawerTheme: DrawerThemeData(
      backgroundColor: appTheme.surfaceColor,
      elevation: 8,
    ),
    
    // Cards
    cardTheme: CardThemeData(
      color: appTheme.surfaceColor,
      elevation: 4,
      shadowColor: appTheme.primaryColor.withValues(alpha:0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    
    // Divider
    dividerTheme: DividerThemeData(
      color: appTheme.secondaryColor.withValues(alpha:0.3),
      thickness: 1,
    ),
    
    // Input decoration
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: appTheme.surfaceColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: appTheme.primaryColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: appTheme.secondaryColor.withValues(alpha:0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: appTheme.primaryColor, width: 2),
      ),
      labelStyle: TextStyle(color: appTheme.textColor),
      hintStyle: TextStyle(color: appTheme.secondaryColor),
    ),
    
    // Snackbar
    snackBarTheme: SnackBarThemeData(
      backgroundColor: appTheme.primaryColor,
      contentTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 14,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );
}
