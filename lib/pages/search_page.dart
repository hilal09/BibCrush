/* 
FileName: search_page.dart
Authors: Yudum Yilmaz (UI), Hilal Cubukcu (UI, Firebase connection)
Last Modified on: 04.01.2024
Description: This Dart file defines the SearchPage class, representing a search 
page in a Flutter app. It includes a search bar to look for users based on their 
usernames or document IDs stored in Firebase Firestore. The search results are 
displayed in a list, and users can navigate to individual profiles by tapping on
the search results.
*/

import 'package:bibcrush/pages/others_profile_page.dart';
import 'package:bibcrush/read%20data/get_user_and_first_name.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../components/custom_nav_bar.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  int _selectedIndex = 1;
  TextEditingController _searchController = TextEditingController();
  List<String> docIDs = [];
  List<String> filteredDocIDs = [];

  @override
  void initState() {
    super.initState();
    getDocId();
  }

  Future getDocId() async {
    docIDs.clear();
    await FirebaseFirestore.instance.collection('users').get().then(
          (snapshot) => snapshot.docs.forEach(
            (document) {
              print(document.reference);
              docIDs.add(document.reference.id);
            },
          ),
        );
    setState(() {
      filteredDocIDs = docIDs;
    });
  }

  void _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        filteredDocIDs = docIDs;
      });
    } else {
      List<String> results = [];

      for (String docID in docIDs) {
        final username = await _getUsernameFromDocId(docID);
        if (docID.toLowerCase().contains(query.toLowerCase()) ||
            username.toLowerCase().contains(query.toLowerCase())) {
          results.add(docID);
        }
      }

      setState(() {
        filteredDocIDs = results;
      });
    }
  }

  Future<String> _getUsernameFromDocId(String docID) async {
    final document =
        await FirebaseFirestore.instance.collection('users').doc(docID).get();
    if (document.exists) {
      return document.data()?['Username'] ?? '';
    } else {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Stack(
                children: [
                  Row(
                    children: [
                      Icon(Icons.search, color: Color(0xFFFF7A00)),
                      SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (query) {
                            _performSearch(query);
                          },
                          decoration: InputDecoration(
                            hintText: 'Who are you looking for?',
                            border: InputBorder.none,
                          ),
                          cursorColor: Color(0xFFFF7A00),
                        ),
                      ),
                      SizedBox(width: 8),
                    ],
                  ),
                  if (_searchController.text.isNotEmpty)
                    Positioned(
                      right: 8,
                      top: (_searchController.text.isNotEmpty) ? 14.0 : 0.0,
                      child: GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          _performSearch('');
                        },
                        child: Icon(Icons.clear, color: Color(0xFFFF7A00)),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: filteredDocIDs.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _navigateToAccount(filteredDocIDs[index]),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        color: Theme.of(context).colorScheme.primary,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.person,
                              ),
                              SizedBox(width: 16),
                              GetUserAndFirstName(
                                documentId: filteredDocIDs[index],
                                textStyle: TextStyle(
                                  fontSize: 19,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomNavBar(
        selectedIndex: _selectedIndex,
        onTabChange: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        context: context,
      ),
    );
  }

  void _navigateToAccount(String documentId) {
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (context) => OthersProfilePage(documentId: documentId)),
    );
  }
}
