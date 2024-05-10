/* 
FileName: theme_provider.dart
Author: Hilal Cubukcu (all)
Last Modified on: 01.01.2024
Description: This Dart file defines a ThemeProvider class that manages 
the theme data for a Flutter app, allowing the toggling between light and dark modes.
*/

import 'package:bibcrush/theme/theme.dart';
import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _themeData = lightMode;

  ThemeData get themeData => _themeData;

  set themeData(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }

  void toggleTheme() {
    if (_themeData == lightMode) {
      themeData = darkMode;
    } else {
      themeData = lightMode;
    }
  }
}
