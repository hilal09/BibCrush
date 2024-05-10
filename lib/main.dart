/* 
FileName: main.dart
Author: Hilal Cubukcu(ThemeProvider), Arkan Kadir(Firebase)
Last Modified on: 01.01.2024
Description: This file initializes and runs the Flutter app, ensuring Firebase is 
initialized, providing a ThemeProvider using the ChangeNotifierProvider from the 
provider package, and setting up the main application with a MaterialApp widget.
*/

import 'package:bibcrush/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'auth/main_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(ChangeNotifierProvider(
    create: (context) => ThemeProvider(),
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData appTheme = Provider.of<ThemeProvider>(context).themeData;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const MainPage(),
      theme: appTheme,
    );
  }
}
