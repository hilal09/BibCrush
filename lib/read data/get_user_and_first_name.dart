/*
FileName: get_user_and_first_name.dart
Author: Arkan Kadir (Firebase)
Last Modified on: 02.01.2024
Description: This Flutter code defines a stateless widget called GetUserAndFirstName.
This widget takes a documentId as a parameter, retrieves corresponding user data from
Firestore using the provided ID, and displays the user's first name and username.
The widget includes some error handling and allows customization of the text style.
To improve the code, you can add a comment header at the top with details like
file name, author, last modification date, and a brief description.
*/

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GetUserAndFirstName extends StatelessWidget {
  final String documentId;
  final TextStyle? textStyle;

  GetUserAndFirstName({
    required this.documentId,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    if (documentId.isEmpty) {
      return Text("Error: Document ID is empty");
    }

    CollectionReference users = FirebaseFirestore.instance.collection('users');

    return FutureBuilder<DocumentSnapshot>(
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}");
          }

          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;
          return Text(
            "${data["First Name"]}" + " @${data["Username"]}",
            style: textStyle
                ?.merge(TextStyle(fontSize: textStyle?.fontSize ?? 14)),
          );
        }
        return Text("Loading...");
      },
      future: users.doc(documentId).get(),
    );
  }
}
