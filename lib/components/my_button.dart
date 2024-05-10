/*
FileName: my_button.dart
Authors: Arkan Kadir (All)
Last Modified on: 01.01.2024
Description: A custom Flutter widget named 'MyButton' designed to display a clickable button.
It includes properties for the button text and the onTap function, allowing customization of
the button's appearance and behavior. This widget creates a GestureDetector with a styled Container
containing the provided text.

*/

import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final String text;
  final void Function()? onTap;

  const MyButton({
    Key? key,
    required this.text,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () {},
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFFFF7A00),
          borderRadius: BorderRadius.circular(10.0),
          shape: BoxShape.rectangle,
        ),
        padding: const EdgeInsets.all(10.0),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
