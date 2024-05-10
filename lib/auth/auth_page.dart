/*
FileName: auth_page.dart
Authors: Arkan Kadir (All)
Last Modified on: 01.01.2024
Description: A Flutter widget named 'AuthPage' that serves as the entry point for the authentication process.
It includes the functionality to toggle between the login and registration screens.
This widget utilizes the 'StartPage' and 'LoginPage' widgets for the respective authentication processes.
*/


import 'package:bibcrush/pages/login_page.dart';
import 'package:bibcrush/pages/start_page.dart';
import 'package:flutter/material.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);


  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool showLoginPage = true;
  bool showStartPage = true;

  void toggleScreens() {
    if (mounted) {
      setState(() {
        showLoginPage = !showLoginPage;
      });
    }
  }

  void showStarterPage() {
    if (mounted) {
      setState(() {
        showStartPage = !showStartPage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return StartPage(showRegisterPage: toggleScreens);
    } else {
      return LoginPage(showStartPage: showStarterPage);
    }
  }
}
