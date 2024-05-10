/* 
FileName: forgot_password_page.dart
Authors: Hilal Cubukcu (UI fixes), Arkan Kadir (Firebase)
Last Modified on: 01.01.2024
Description: This Dart file defines a ForgotPasswordPage with a form for users 
to enter their email address and receive a password reset link via Firebase Authentication.
*/

import 'package:bibcrush/components/my_button.dart';
import 'package:bibcrush/components/my_textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future passwordReset() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _emailController.text.trim());
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text("Passwort reset link sent"),
          );
        },
      );
    } on FirebaseAuthException catch (e) {
      print(e);
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text(e.message.toString()),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Enter your email address, and we will send you a link to reset your password.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    const Icon(Icons.mail, color: Colors.grey),
                    const SizedBox(width: 10),
                    Expanded(
                      child: MyTextField(
                        hintText: "Type in e-mail address",
                        obscureText: false,
                        controller: _emailController,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            MyButton(text: "Verify", onTap: passwordReset),
          ],
        ),
      ),
    );
  }
}
