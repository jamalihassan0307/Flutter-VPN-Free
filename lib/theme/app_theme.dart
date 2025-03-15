import 'package:flutter/material.dart';
import '../helpers/pref.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Color(0xFF2196F3),
    scaffoldBackgroundColor: Color(0xFFF8F9FA),
    cardColor: Colors.white,
    shadowColor: Colors.black.withOpacity(0.1),
    colorScheme: ColorScheme.light(
      primary: Color(0xFF2196F3),
      secondary: Color(0xFF1976D2),
      surface: Colors.white,
      background: Color(0xFFF8F9FA),
      onPrimary: Colors.white,
      onSurface: Color(0xFF424242),
    ),
    textTheme: TextTheme(
      titleLarge: TextStyle(
        color: Color(0xFF1F1F1F),
        fontWeight: FontWeight.bold,
        fontSize: 24,
      ),
      bodyLarge: TextStyle(
        color: Color(0xFF424242),
        fontSize: 16,
      ),
      bodyMedium: TextStyle(
        color: Color(0xFF757575),
        fontSize: 14,
      ),
    ),
  );

  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.blue,
    scaffoldBackgroundColor: Color(0xFF2A2D3E),
    cardColor: Color(0xFF1F1F1F),
    shadowColor: Colors.black.withOpacity(0.3),
    colorScheme: ColorScheme.dark(
      primary: Colors.blue,
      secondary: Colors.blueAccent,
      surface: Color(0xFF1F1F1F),
      background: Color(0xFF2A2D3E),
    ),
    textTheme: TextTheme(
      titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white70),
    ),
  );
}

extension ThemeDataExtension on ThemeData {
  Color get lightText => Pref.isDarkMode ? Colors.white70 : Colors.black54;
  Color get bottomNav => Pref.isDarkMode ? Colors.white12 : Colors.blue;
} 