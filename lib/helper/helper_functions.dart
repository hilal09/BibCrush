/*
FileName: helper_functions.dart
Authors: Arkan Kadir (All)
Last Modified on: 01.01.2024
Description: Flutter code containing helper functions.
Currently includes a function named 'displayMessageToUser' that shows a
simple alert dialog with a specified message. This function is designed to display
messages to the user in a pop-up dialog box.
*/

import 'package:flutter/material.dart';

void displayMessageToUser(String message, BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(message),
  ),);
}
