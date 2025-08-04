import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  
  ThemeMode _themeMode = ThemeMode.light;
  
  ThemeMode get themeMode => _themeMode;
  
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  
  ThemeProvider() {
    _loadThemeFromPrefs();
  }
  
  // Load saved theme preference
  Future<void> _loadThemeFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeString = prefs.getString(_themeKey);
      
      if (themeString != null) {
        _themeMode = themeString == 'dark' ? ThemeMode.dark : ThemeMode.light;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading theme: $e');
    }
  }
  
  // Save theme preference
  Future<void> _saveThemeToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, _themeMode == ThemeMode.dark ? 'dark' : 'light');
    } catch (e) {
      debugPrint('Error saving theme: $e');
    }
  }
  
  // Toggle theme
  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await _saveThemeToPrefs();
    notifyListeners();
  }
  
  // Set specific theme
  Future<void> setTheme(ThemeMode themeMode) async {
    _themeMode = themeMode;
    await _saveThemeToPrefs();
    notifyListeners();
  }
  
  // Get light theme
  ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.blue,
      primaryColor: const Color(0xFFFFC107), // Yellow
      scaffoldBackgroundColor: Colors.grey[100],
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.black87, fontFamily: 'Cairo'),
        bodyMedium: TextStyle(color: Colors.black87, fontFamily: 'Cairo'),
        titleLarge: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600),
        headlineMedium: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
      ),
      fontFamily: 'Cairo',
    );
  }
  
  // Get dark theme
  ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primarySwatch: Colors.blue,
      primaryColor: const Color(0xFFFFC107), // Yellow
      scaffoldBackgroundColor: const Color(0xFF121212),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        elevation: 1,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF2C2C2C),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.black, fontFamily: 'Cairo'),
        bodyMedium: TextStyle(color: Colors.black, fontFamily: 'Cairo'),
        titleLarge: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600),
        headlineMedium: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
      ),
      fontFamily: 'Cairo',
    );
  }
} 