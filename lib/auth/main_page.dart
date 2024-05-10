/*
FileName: main_page.dart
Authors: Arkan Kadir (All)
Last Modified on: 01.01.2024
Description: A Flutter widget named 'MainPage' that serves as the main entry point for the application.
It utilizes a stream from Firebase Authentication to determine whether a user is authenticated or not.
If a user is authenticated, it navigates to the 'HomePage'; otherwise, it directs to the 'AuthPage'.
*/


import 'package:bibcrush/auth/auth_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../pages/home_page.dart';

class MainPage extends StatelessWidget {
  const MainPage({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return HomePage();
          } else {
            return AuthPage();
          }
        },
      ),
    );
  }
}
