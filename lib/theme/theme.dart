/* 
FileName: theme.dart
Authors: Hilal Cubukcu (all)
Last Modified on: 02.01.2024
Description: This Dart file defines light and dark mode theme data configurations 
using the `ThemeData` class from Flutter, including color schemes, text themes from 
the Google Fonts package, and input decoration themes for both modes.
*/

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    background: Colors.white,
    primary: Colors.grey.shade200,
  ),
  textTheme: GoogleFonts.dmSansTextTheme().apply(
    bodyColor: Colors.black,
    displayColor: Colors.black,
  ),
  inputDecorationTheme: InputDecorationTheme(
    labelStyle: TextStyle(
      color: Colors.black,
    ),
  ),
);

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    background: Colors.grey.shade900,
    primary: Colors.grey.shade800,
  ),
  textTheme: GoogleFonts.dmSansTextTheme().apply(
    bodyColor: Colors.white,
    displayColor: Colors.white,
  ),
  inputDecorationTheme: InputDecorationTheme(
    labelStyle: TextStyle(
      color: Colors.white,
    ),
  ),
);
