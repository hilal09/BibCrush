/* 
FileName: start_page.dart
Authors: Yudum Yilmaz (UI),
Last Modified on: 04.01.2024
Description: This Dart file defines the StartPage class, representing the 
initial screen of a Flutter app. It displays the app's logo, provides a 
"Sign in" button to navigate to the login page, and offers an option to register
by tapping on "Sign up here!" which leads to the registration page.
*/

import 'package:bibcrush/components/my_button.dart';
import 'package:flutter/material.dart';
import 'register_page.dart';
import 'login_page.dart';

class StartPage extends StatefulWidget {
  final VoidCallback showRegisterPage;
  const StartPage({Key? key, required this.showRegisterPage}) : super(key: key);

  @override
  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/bibcrush_logo_orange.png',
              width: 100,
              height: 100,
            ),
            const SizedBox(height: 20),
            MyButton(
              text: 'Sign in',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => LoginPage(
                            showStartPage: () {},
                          )),
                );
              },
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "No account? ",
                  style: TextStyle(color: Color(0xFFFF7A00)),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RegistrationPage(
                                showLoginPage: widget.showRegisterPage,
                              )),
                    );
                  },
                  child: const Text(
                    "Sign up here!",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF7A00),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
