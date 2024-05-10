/* 
FileName: login_page.dart
Authors: Yudum Yilmaz(UI), Hilal Cubukcu (email verification), Arkan Kadir (Firebaase)
Last Modified on: 04.01.2024
Description: This Dart file defines the `LoginPage` class, which presents a user
interface for logging in, including input fields for email and password, 
a "Forgot password?" link, and a "Sign In" button. Upon successful login, 
it navigates to the `HomePage`, and if the email is not verified, 
it prompts the user to verify their email.
*/

import 'package:bibcrush/components/my_button.dart';
import 'package:bibcrush/components/my_textfield.dart';
import 'package:bibcrush/pages/start_page.dart';
import 'package:bibcrush/pages/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'forgot_pw_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key, required void Function() showStartPage})
      : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future signIn() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (FirebaseAuth.instance.currentUser!.emailVerified) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => HomePage()),
          (route) => false,
        );
      } else {
        print("Login error: not verified yet.");
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text('Please verify your email before logging in.'),
            );
          },
        );
      }
    } catch (e) {
      print("Login error: $e");
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text("Login failed: $e"),
          );
        },
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StartPage(
                    showRegisterPage: () {},
                  ),
                ),
              );
            },
          ),
        ),
        title: const Text(
          'Login',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                          hintText: "Enter email",
                          obscureText: false,
                          controller: _emailController),
                    ),
                  ],
                ),
              ),
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
                    const Icon(Icons.lock, color: Colors.grey),
                    const SizedBox(width: 10),
                    Expanded(
                        child: MyTextField(
                            hintText: 'Enter password',
                            obscureText: true,
                            controller: _passwordController)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return const ForgotPasswordPage();
                    },
                  ),
                );
              },
              child: const SizedBox(
                width: double.infinity,
                child: Text(
                  'Forgot password?',
                  style: TextStyle(color: Color(0xFFFF7A00)),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 20),
            MyButton(text: "Sign In", onTap: signIn)
          ],
        ),
      ),
    );
  }
}
