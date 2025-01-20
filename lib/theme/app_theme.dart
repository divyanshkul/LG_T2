import 'package:flutter/material.dart';

class AppTheme {
  static const primaryColor = Color(0xFF1A237E);
  static const secondaryColor = Color(0xFF303F9F);
  static const backgroundColor = Color(0xFF0A1929);
  static const surfaceColor = Color(0xFF162033);
  static const accentColor = Color(0xFF64B5F6);

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      background: backgroundColor,
      surface: surfaceColor,
    ),
    scaffoldBackgroundColor: backgroundColor,
    cardTheme: CardTheme(
      color: surfaceColor,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: surfaceColor,
      elevation: 0,
    ),
  );
}
