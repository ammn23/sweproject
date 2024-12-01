import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      // Global text styles
      textTheme: TextTheme(
        bodyMedium: TextStyle(
          color: Color(0xFF3F3F44), // Default text color
          fontSize: 16,             // Default font size
        ),
      ),

      // Global button styles
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF3F3F44), // Button background color
          foregroundColor: Color(0xFFF7F7F7), // Button text color
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), // Rounded corners
          ),
        ),
      ),

    );
  }
}
