/*
FileName: my_textfield.dart
Authors: Arkan Kadir (All)
Last Modified on: 01.01.2024
Description: A custom Flutter widget named 'MyTextField' designed to display a text input field.
It includes properties for the hint text, whether the text should be obscured (e.g., for passwords),
and a TextEditingController. This widget creates a TextField with specified configurations,
such as borderless design and the provided hint text.
*/

import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final String hintText;
  final bool obscureText;
  final TextEditingController controller;

  const MyTextField({
    super.key,
    required this.hintText,
    required this.obscureText,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: hintText,
      ),
      obscureText: obscureText,
    );
  }
}
