/* 
FileName: custom_nav_bar.dart
Authors: Yudum Yilmaz (UI), Hilal Cubukcu (navigate function)
Last Modified on: 04.01.2024
Description: This Dart file defines a CustomNavBar widget for a Flutter app, 
representing a custom navigation bar with icons for home, search, create post, 
notifications, and profile. 
*/

import 'package:bibcrush/pages/notification_inbox_page.dart';
import 'package:bibcrush/pages/create_post.dart';
import 'package:bibcrush/pages/home_page.dart';
import 'package:bibcrush/pages/profile_page.dart';
import 'package:bibcrush/pages/search_page.dart';
import 'package:flutter/material.dart';

class CustomNavBar extends StatelessWidget {
  final Function(int) onTabChange;
  final int? selectedIndex;
  final BuildContext context;

  const CustomNavBar({
    Key? key,
    required this.onTabChange,
    this.selectedIndex,
    required this.context,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Brightness iconColor = Theme.of(context).brightness == Brightness.light
        ? Brightness.dark
        : Brightness.light;

    return Container(
      color: Colors.transparent,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              buildNavItem(Icons.home, 0),
              buildNavItem(Icons.search, 1),
              buildNavItem(Icons.add_box, 2),
              buildNavItem(Icons.inbox, 3),
              buildNavItem(Icons.person_rounded, 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildNavItem(IconData icon, int index) {
    ThemeData theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        onTabChange(index);
        navigateToPage(context, index);
      },
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selectedIndex == index
                  ? Color(0xFFFF7A00)
                  : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Icon(
          icon,
          color: selectedIndex == index
              ? Color(0xFFFF7A00)
              : theme.colorScheme.onSurface,
        ),
      ),
    );
  }

  void navigateToPage(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => HomePage()),
          (route) => false,
        );
        break;
      case 1:
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => SearchPage()),
          (route) => false,
        );
        break;
      case 2:
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => CreatePostPage()),
          (route) => false,
        );
        break;
      case 3:
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => NotificationPage()),
          (route) => false,
        );
        break;
      case 4:
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => ProfilePage()),
          (route) => false,
        );
        break;
    }
  }
}
