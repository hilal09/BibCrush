/* 
FileName: profile_page.dart
Authors: Hilal Cubukcu (UI, widgets, delete-, changepassword- and dialog functions),
Arkan Kadir (Firebase, Loading Posts, edit InfoTabs)
Last Modified on: 04.01.2024
Description:

Flutter code for a social media app's ProfilePage, managing user profile, posts,
and interactions. Features include async post retrieval, deletion, info dialogs,
account actions, and Firebase integration for storage.

Key Features:
- Async post retrieval with FutureBuilder.
- Post deletion with comments removal.
- Dialogs for user info and profile edits.
- Info dialog for credits, packages, widgets.
- Account deletion and password change.
- Helper methods for text fields, errors, user updates.
- Firebase Storage for profile image upload.

Comprehensive Flutter-Firebase implementation for profile management in a social app.
*/

import 'package:bibcrush/pages/start_page.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:bibcrush/theme/theme_provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../components/custom_nav_bar.dart';
import 'comment_page.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final String? uid = FirebaseAuth.instance.currentUser?.uid;
  int _postLikes = 0;

  int _selectedIndex = 0;
  bool _lightDarkModeEnabled = true;
  bool _notificationsEnabled = true;
  File? _selectedImage;

  final _currentPasswordController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _passwordsMatch = true;

  int _posts = 0;
  int _follower = 0;
  int _following = 0;
  int _crushes = 0;
  String _first_name = '';
  String _username = '';
  String _caption = '';
  String _courseOfStudy = '';
  int? _semester;
  int? _faculty;

  List<String> docIDs = [];
  User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    getDocs();
  }

  Future<void> getDocs() async {
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .where('UID', isEqualTo: user?.uid ?? '')
          .get()
          .then((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          final document = snapshot.docs[0];
          print("User Document: ${document.data()}");

          if (document.reference != null &&
              document.reference.path.isNotEmpty) {
            print(document.reference);
            docIDs.add(document.reference.id);

            setState(() {
              _first_name = document['First Name'] ?? '';
              _username = document['Username'] ?? '';
              _caption = document['Caption'] ?? '';
              _courseOfStudy = document['Course of Study'] ?? '';

              _semester = document['Semester'] as int?;
              _faculty = document['Faculty'] as int?;

              _fetchUserStatistics();
            });
          } else {
            print("Error: Document reference is null or empty");
            // Handle the error accordingly
          }
        }
      });
    } catch (e) {
      print("Error fetching user details: $e");
    }
  }

  Future<void> _fetchUserStatistics() async {
    final userStatsDoc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user?.uid)
        .get();

    if (userStatsDoc.exists) {
      setState(() {
        var posts = userStatsDoc['Posts'];
        _posts = posts is List ? posts.length : 0;

        var followers = userStatsDoc['Follower'];
        _follower = followers is List ? followers.length : 0;

        var following = userStatsDoc['Following'];
        _following = following is List ? following.length : 0;

        var crushes = userStatsDoc['Crushes'];
        _crushes = crushes is List ? crushes.length : 0;
      });
    }
  }

  String _formatTimestamp(Timestamp timestamp) {
    var postTime = timestamp.toDate();
    return timeago.format(postTime, locale: 'en_short');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
      ),
      endDrawer: Drawer(
        child: Container(
          color: Theme.of(context).colorScheme.primary,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 50.0),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.sunny),
                      title: Text("Light/Dark Mode"),
                      trailing: Switch(
                        onChanged: (bool? value) {
                          setState(() {
                            _lightDarkModeEnabled = value!;
                          });
                          Provider.of<ThemeProvider>(context, listen: false)
                              .toggleTheme();
                        },
                        value: _lightDarkModeEnabled,
                        activeTrackColor: Color(0xFFFF7A00),
                        activeColor: Colors.white,
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.notifications),
                      title: Text(
                        "Notifications",
                      ),
                      trailing: Switch(
                        onChanged: (bool? value) {
                          setState(() {
                            _notificationsEnabled = value!;
                          });
                        },
                        value: _notificationsEnabled,
                        activeTrackColor: Color(0xFFFF7A00),
                        activeColor: Colors.white,
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.key),
                      title: Text("Change password"),
                      onTap: () {
                        _showChangePasswordDialog();
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.info_outline_rounded),
                        title: Text("Info"),
                        onTap: () {
                          _showInfoDialog();
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.delete_rounded),
                        title: Text("Delete account"),
                        onTap: () {
                          _showDeleteAccountDialog();
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.logout),
                        title: Text("Log out"),
                        onTap: () {
                          _signOut();
                        },
                      ),
                    ],
                  )),
            ],
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          _selectedImage != null
              ? CircleAvatar(
                  radius: 36,
                  backgroundImage: FileImage(_selectedImage!),
                )
              : CircleAvatar(
                  radius: 36,
                  backgroundColor: Color(0xFFFF7A00),
                  child: IconButton(
                    icon: Icon(Icons.camera_alt),
                    onPressed: () async {
                      final image = await ImagePicker()
                          .pickImage(source: ImageSource.gallery);
                      if (image != null) {
                        setState(() {
                          _selectedImage = File(image.path);
                        });
                        await _uploadImageToFirebaseStorage();
                      }
                    },
                  ),
                ),
          const SizedBox(height: 20),
          RichText(
            text: TextSpan(
              text: _first_name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),
              children: [
                TextSpan(
                  text: ' @' + _username,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
          Container(
            child: Text(
              _caption,
              textAlign: TextAlign.center,
            ),
            margin: EdgeInsets.symmetric(horizontal: 80.0),
            padding: EdgeInsets.all(10.0),
          ),
          TextButton(
            onPressed: () {
              _showEditProfileDialog(context);
            },
            style: ButtonStyle(
              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              )),
              side: MaterialStateProperty.all(BorderSide(
                color: Colors.grey,
                width: 0.5,
              )),
            ),
            child: Text(
              "Edit Profile",
              style: TextStyle(
                color: Colors.blue,
              ),
            ),
          ),
          SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey, width: 0.5),
                bottom: BorderSide(color: Colors.grey, width: 0.5),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatisticColumn("Posts", _posts.toString()),
                  _buildStatisticColumn("Follower", _follower.toString()),
                  _buildStatisticColumn("Following", _following.toString()),
                  _buildStatisticColumn("Crushes", _crushes.toString()),
                ],
              ),
            ),
          ),
          Expanded(
            child: DefaultTabController(
              length: 2,
              initialIndex: 0,
              child: Column(
                children: [
                  TabBar(
                    labelColor: Color(0xFFFF7A00),
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Color(0xFFFF7A00),
                    tabs: [
                      Tab(text: "My Posts"),
                      Tab(text: "My Info"),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildMyPostsTab(),
                        _buildMyInfosTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomNavBar(
        selectedIndex: 4,
        onTabChange: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        context: context,
      ),
    );
  }

  Widget _buildStatisticColumn(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildMyPostWidget(DocumentSnapshot postDoc) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(postDoc['users']['UID'])
          .get(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        if (userSnapshot.hasError) {
          print('Error fetching user data: ${userSnapshot.error}');
          return Text('Error: ${userSnapshot.error}');
        }

        var post = postDoc.data() as Map<String, dynamic>;
        var userData = userSnapshot.data?.data() as Map<String, dynamic>? ?? {};

        if (userData == null) {
          print('Error: userData is null');
          return Container();
        }

        bool isCurrentUserOwner =
            post['users']['UID'] == FirebaseAuth.instance.currentUser?.uid;

        print("User Document: ${userSnapshot.data}");

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            elevation: 3,
            color: Theme.of(context).colorScheme.primary,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: CircleAvatar(
                    radius: 25,
                    backgroundColor: Color(0xFFFF7A00),
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(userData?['First Name'] ?? 'Unknown',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(width: 4),
                          Text('@${userData?['Username'] ?? 'Unknown'}'),
                        ],
                      ),
                      PopupMenuButton<String>(
                        itemBuilder: (BuildContext context) {
                          List<PopupMenuEntry<String>> menuItems = [];

                          if (isCurrentUserOwner) {
                            menuItems.add(
                              PopupMenuItem<String>(
                                value: 'Delete',
                                child: Text('Delete'),
                              ),
                            );
                          } else if (!isCurrentUserOwner) {
                            menuItems.add(
                              PopupMenuItem<String>(
                                value: 'Report',
                                child: Text('Report'),
                              ),
                            );
                          }
                          return menuItems;
                        },
                        onSelected: (String value) async {
                          if (value == 'Delete') {
                            await _deletePost(postDoc.id);
                          } else if (value == 'Report') {}
                        },
                      ),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 0),
                    child: Text(_formatTimestamp(post['timestamp'])),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: post['imageUrl'] != null
                      ? Image.network(
                          post['imageUrl'],
                          width: 400,
                          height: 550,
                          fit: BoxFit.cover,
                        )
                      : Container(),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    post['text'] ?? '',
                    style: TextStyle(fontSize: 16.0),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      icon: Icon(Icons.comment),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                CommentPage(postId: postDoc.id),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        post['likes'] != null && post['likes']! > 0
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: post['likes'] != null && post['likes']! > 0
                            ? Colors.red
                            : null,
                      ),
                      onPressed: () async {
                        int newLikes =
                            post['likes'] != null && post['likes']! > 0
                                ? post['likes']! - 1
                                : post['likes']! + 1;
                        await FirebaseFirestore.instance
                            .collection('posts')
                            .doc(postDoc.id)
                            .update({'likes': newLikes});
                        setState(() {
                          post['likes'] = newLikes;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMyInfosTab() {
    return ListView(
      padding: EdgeInsets.all(16.0),
      children: [
        _buildInfoSection("Course of Study", _courseOfStudy),
        _buildInfoSection("Semester", _semester?.toString() ?? ""),
        _buildInfoSection("Faculty", _faculty?.toString() ?? ""),
      ],
    );
  }

  Widget _buildInfoSection(String title, String? caption) {
    return Column(
      children: [
        ListTile(
          title: Text(
            title,
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            caption ?? "N/A",
            style: TextStyle(fontSize: 16.0),
          ),
          trailing: IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              _showEditInfoDialog(context, title, caption ?? "");
            },
          ),
        ),
        Divider(
          color: Colors.grey,
          thickness: 0.5,
        ),
      ],
    );
  }

  Widget _buildMyPostsTab() {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('posts')
          .where('users.UID', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        var posts = snapshot.data!.docs;

        if (posts.isEmpty) {
          return Center(
            child: Text(
              'No posts yet.',
              style: TextStyle(fontSize: 15.0),
            ),
          );
        }

        return ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            return _buildMyPostWidget(posts[index]);
          },
        );
      },
    );
  }

  Future<void> _deletePost(String postId) async {
    try {
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .get()
          .then((commentSnapshot) async {
        for (var commentDoc in commentSnapshot.docs) {
          await commentDoc.reference.delete();
        }
      });

      await FirebaseFirestore.instance.collection('posts').doc(postId).delete();

      print('Post deleted successfully');
    } catch (e) {
      print('Error deleting post: $e');
    }
  }

  void _showEditInfoDialog(
      BuildContext context, String title, String initialValue) {
    String newValue = initialValue;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Edit $title"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                onChanged: (value) {
                  newValue = value;
                },
                initialValue: initialValue,
                decoration: InputDecoration(labelText: title),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "Cancel",
                style: TextStyle(color: Color(0xFFFF7A00)),
              ),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await _updateEditInfoInFirestore(title, newValue);

                  setState(() {
                    switch (title) {
                      case "Course of Study":
                        _courseOfStudy = newValue;
                        break;
                      case "Semester":
                        if (int.tryParse(newValue) != null) {
                          _semester = int.parse(newValue);
                        } else {
                          print("Invalid integer for Semester: $newValue");
                        }
                        break;
                      case "Faculty":
                        if (int.tryParse(newValue) != null) {
                          _faculty = int.parse(newValue);
                        } else {
                          print("Invalid integer for Faculty: $newValue");
                        }
                        break;
                    }
                  });

                  Navigator.of(context).pop();
                } catch (e) {
                  print("Error saving edited information: $e");
                }
              },
              child: Text(
                "Save",
                style: TextStyle(color: Color(0xFFFF7A00)),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    String newFirstName = _first_name;
    String newCaption = _caption;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Edit Profile"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                onChanged: (value) {
                  newFirstName = value;
                },
                initialValue: _first_name,
                decoration: InputDecoration(
                  labelText: "First Name",
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFFF7A00)),
                  ),
                ),
              ),
              TextFormField(
                readOnly: true,
                initialValue: _username,
                decoration: InputDecoration(labelText: "Username"),
              ),
              TextFormField(
                onChanged: (value) {
                  newCaption = value;
                },
                initialValue: _caption,
                decoration: InputDecoration(
                  labelText: "Caption",
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFFF7A00)),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "Cancel",
                style: TextStyle(color: Color(0xFFFF7A00)),
              ),
            ),
            TextButton(
              onPressed: () async {
                await _updateEditProfileInFirestore(newFirstName, newCaption);

                setState(() {
                  _first_name = newFirstName;
                  _caption = newCaption;
                });

                Navigator.of(context).pop();
              },
              child: Text(
                "Save",
                style: TextStyle(color: Color(0xFFFF7A00)),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(
              child: Text(
            'Info',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          )),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'Credits',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 8),
                _buildSubheading('Hilal Cubukcu:', 'Frontend, Backend'),
                _buildSubheading('Arkan Kadir:', 'Backend'),
                _buildSubheading(
                    'Melisa Rosic Emira:', 'UI (Figma), Frontend, Backend'),
                _buildSubheading('Yudum Yilmaz:', 'Frontend/UI'),
                SizedBox(height: 16),
                Center(
                  child: Text(
                    'Packages',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 8),
                _buildPackageDescription('cupertino_icons',
                    'Bietet den Cupertino-Icon-Satz für iOS-artige Symbole in Flutter-Apps.'),
                _buildPackageDescription('firebase_core',
                    'Das Kernpaket für Firebase, erforderlich für die Initialisierung und Konfiguration von Firebase-Diensten in einer Flutter-App.'),
                _buildPackageDescription('firebase_auth',
                    'Flutter-Plugin für die Firebase-Authentifizierung, mit der Benutzer sich mit verschiedenen Authentifizierungsanbietern anmelden können.'),
                _buildPackageDescription('cloud_firestore',
                    'Flutter-Plugin für Cloud Firestore, eine NoSQL-Datenbank, die Daten in Echtzeit zwischen Geräten synchronisiert.'),
                _buildPackageDescription('flutter_native_splash',
                    'Ermöglicht eine einfache Möglichkeit, einen nativen Splash-Screen zu einer Flutter-App hinzuzufügen.'),
                _buildPackageDescription('image_picker',
                    'Ermöglicht Benutzern das Auswählen von Bildern aus der Galerie ihres Geräts oder das Aufnehmen von Fotos mit der Kamera.'),
                _buildPackageDescription('provider',
                    'Eine Bibliothek für das Zustandsmanagement, die es einfach macht, Daten zwischen Widgets in Ihrer Flutter-App zu teilen.'),
                _buildPackageDescription('google_fonts',
                    'Bietet die Möglichkeit, Google Fonts in Flutter-Apps zu verwenden.'),
                _buildPackageDescription('firebase_storage',
                    'Flutter-Plugin für Firebase Cloud Storage, mit dem man Dateien in der Cloud speichern und abrufen kann.'),
                _buildPackageDescription('timeago',
                    'Eine Bibliothek zum Formatieren von Zeitstempeln in ein "vor kurzem" Format, um relative Zeit in der App anzuzeigen.'),
                _buildPackageDescription('intl',
                    'Das intl-Paket in der pubspec.yaml-Datei in Flutter ermöglicht die Internationalisierung und Lokalisierung, um Formatierung und Übersetzung von Nachrichten basierend auf verschiedenen Ländercodes zu unterstützen.'),
                SizedBox(height: 16),
                Center(
                  child: Text(
                    'Widgets',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 8),
                _buildWidgetDescription("Scaffold()",
                    "Das Haupt-Widget für die App-Oberfläche. Enthält die AppBar, das EndDrawer, den Body und die BottomNavigationBar."),
                _buildWidgetDescription("AppBar()",
                    "Die obere Leiste der App, die häufig für die Anzeige des App-Titels und anderer wichtiger Informationen verwendet wird."),
                _buildWidgetDescription("EndDrawer()",
                    "Ein seitliches Menü, das durch Wischen vom rechten Bildschirmrand oder durch Tippen auf das Menüsymbol in der AppBar geöffnet wird. Enthält Optionen für Themenänderung, Benachrichtigungen, Passwortänderung und Kontoaktionen."),
                _buildWidgetDescription("Column()",
                    "Ein Widget, das seine Kinder in einer vertikalen Abfolge anordnet. Hier wird es verwendet, um mehrere Widgets vertikal in der Spalte anzuzeigen."),
                _buildWidgetDescription("CircleAvatar()",
                    "Zeigt das Profilbild des Benutzers an. Wird auch für das Hinzufügen von Profilbildern und die Auswahl von Bildern aus der Galerie verwendet."),
                _buildWidgetDescription("RichText()",
                    "Erlaubt die Anzeige von Text mit verschiedenen Stilen. Hier verwendet, um den Benutzernamen und den Vornamen des Benutzers mit unterschiedlichen Stilen anzuzeigen."),
                _buildWidgetDescription(
                    "TextButton()",
                    "Ein flacher Button mit Text, der für die Schaltfläche "
                        "Edit Profile"
                        " und andere Schaltflächen im Dialog verwendet wird."),
                _buildWidgetDescription("Container()",
                    "Ein unsichtbares Widget, das zum Zentrieren und Stylen von Texten im Profilbereich verwendet wird."),
                _buildWidgetDescription(
                    "DefaultTabController()",
                    "Ein Controller für ein TabBar und TabBarView, der hier für die Registerkarten "
                        "My Posts"
                        " und "
                        "My Info"
                        " verwendet wird."),
                _buildWidgetDescription("TabBar und TabBarView()",
                    "Ein TabBar zeigt Registerkarten an, während TabBarView den Inhalt der ausgewählten Registerkarte anzeigt."),
                _buildWidgetDescription("ListView und ListView.builder()",
                    "Widgets, die eine scrollbare Liste von Widgets bereitstellen. Wird verwendet, um Benutzerposts und Benutzerinformationen in Registerkarten anzuzeigen."),
                _buildWidgetDescription("Card()",
                    "Ein Material Design-Karten-Widget für die Anzeige von Benutzerposts mit Kommentaren, Likes und Bildern."),
                _buildWidgetDescription("FutureBuilder()",
                    "Ein Widget, das asynchrone Daten in Echtzeit aktualisiert. Hier verwendet, um Benutzerposts asynchron abzurufen und anzuzeigen."),
                _buildWidgetDescription("AlertDialog()",
                    "Ein Popup-Dialog, der für verschiedene Benutzerinteraktionen wie Profilbearbeitung, Passwortänderung und Kontoaktionen verwendet wird."),
                _buildWidgetDescription("TextFormField()",
                    "Ein Texteingabefeld für Benutzerinteraktionen wie die Eingabe neuer Informationen für das Benutzerprofil oder das Ändern von Passwörtern."),
                _buildWidgetDescription("Switch()",
                    "Ein Schiebeschalter zum Ein- und Ausschalten von Einstellungen wie Licht-/Dunkelmodus und Benachrichtigungen."),
                _buildWidgetDescription("IconButton()",
                    "Ein Button mit nur einem Icon, der hier für Aktionen wie Kommentieren, Liken und Profilbild ändern verwendet wird."),
                _buildWidgetDescription("ImagePicker()",
                    "Ein Flutter-Plugin, das Benutzern das Auswählen von Bildern aus der Galerie oder das Aufnehmen von Fotos mit der Kamera ermöglicht."),
                _buildWidgetDescription("_buildActionItem()",
                    "Erstellt interaktive Bedienelemente wie Buttons oder Menüpunkte."),
                _buildWidgetDescription("_buildTabButton()",
                    "Generiert Tab-Schaltflächen für die Navigation innerhalb der App."),
                _buildWidgetDescription("_buildMessagesList()",
                    "Zeigt eine Liste von Nachrichten, sortiert nach neuesten Nachrichten."),
                _buildWidgetDescription("_buildNotificationsList()",
                    "Stellt eine Liste von Benachrichtigungen für den Benutzer dar."),
                _buildWidgetDescription("_buildSubheading()",
                    "Das Widget erstellt eine Spalte mit einem fett gedruckten Namen in orangener Farbe, gefolgt von einem zugehörigen Aufgabenbereich und einem vertikalen Freiraum."),
                _buildWidgetDescription("_buildPackageDescription()",
                    "Das Widget erstellt eine Spalte mit dem Paketnamen in orangener Farbe und einer dazugehörigen Beschreibung mit vertikalem Freiraum."),
                _buildWidgetDescription("_buildWidgetDescription()",
                    "Das Widget erstellt eine Spalte mit dem Widgetnamen in orangener Farbe und einer dazugehörigen Beschreibung mit vertikalem Freiraum."),
                _buildWidgetDescription("_buildMyInfosTab()",
                    "Das Widget erstellt eine ListView mit verschiedenen Abschnitten zu den persönlichen Informationen des Benutzers, darunter Studiengang, Semester und Fakultät."),
                _buildWidgetDescription("_buildInfoSection()",
                    "Das Widget erstellt eine Spalte mit einem ListTile, das einen Abschnitt für eine bestimmte Information und den zugehörigen Text enthält, sowie eine Bearbeitungsoption."),
                _buildWidgetDescription("_buildMyPostsTab()",
                    "Das Widget erstellt eine FutureBuilder-Liste, die die vom Benutzer erstellten Posts aus der Firestore-Datenbank abruft und darstellt, oder eine Ladeanzeige bzw. Fehlermeldung, wenn erforderlich."),
                _buildWidgetDescription("_buildPostImage()",
                    "Das Widget erstellt ein Bild-Widget basierend auf einer Bild-URL (imageUrl), das entweder das Bild lädt und anzeigt oder ein leeres SizedBox, wenn keine URL vorhanden ist."),
                _buildWidgetDescription("_buildCommentWidget()",
                    "Das Widget erstellt ein ListTile mit Benutzerkommentaren, die aus Firestore abgerufen werden, und zeigt den Benutzernamen, den Kommentartext sowie Optionen wie Melden und Entfolgen an. Falls der Benutzer nicht vorhanden ist, wird 'No username' angezeigt."),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubheading(String name, String task) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style:
              TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFF7A00)),
        ),
        Text(task),
        SizedBox(height: 8),
      ],
    );
  }

  Widget _buildPackageDescription(String packageName, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          packageName,
          style:
              TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFF7A00)),
        ),
        Text(description),
        SizedBox(height: 8),
      ],
    );
  }

  Widget _buildWidgetDescription(String packageName, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          packageName,
          style:
              TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFF7A00)),
        ),
        Text(description),
        SizedBox(height: 8),
      ],
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete your Account?'),
          content: const Text(
            '''If you select Delete we will delete your account on our server.

Your app data will also be deleted and you won't be able to retrieve it.''',
          ),
          actions: [
            TextButton(
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xFFFF7A00)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                'Delete',
                style: TextStyle(color: Color(0xFFFF7A00)),
              ),
              onPressed: () {
                _deleteAccount();
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
          ],
        );
      },
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Change Password'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  TextFormField(
                    controller: _currentPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Current password',
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFFF7A00)),
                      ),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'You need to type in your current password';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'New Password',
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFFF7A00)),
                      ),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'You need to type in a password';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      errorText:
                          _passwordsMatch ? null : 'Passwords do not match',
                      errorStyle: TextStyle(color: Colors.red),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFFF7A00)),
                      ),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (_passwordController.text.isNotEmpty &&
                          value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _clearTextFields();
              },
              child: Text('Cancel', style: TextStyle(color: Color(0xFFFF7A00))),
            ),
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _changePassword(_currentPasswordController.text,
                      _passwordController.text);
                  Navigator.of(context).pop();
                  _clearTextFields();
                }
              },
              child: Text('Save', style: TextStyle(color: Color(0xFFFF7A00))),
            ),
          ],
        );
      },
    );
  }

  void _clearTextFields() {
    _currentPasswordController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
  }

  void _showErrorPopup(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK', style: TextStyle(color: Color(0xFFFF7A00))),
            ),
          ],
        );
      },
    );
  }

  Future<String?> _changePassword(
      String oldPassword, String newPassword) async {
    User user = FirebaseAuth.instance.currentUser!;
    AuthCredential credential =
        EmailAuthProvider.credential(email: user.email!, password: oldPassword);

    Map<String, String?> codeResponses = {
      "user-mismatch": null,
      "user-not-found": null,
      "invalid-credential": null,
      "invalid-email": null,
      "wrong-password": null,
      "invalid-verification-code": null,
      "invalid-verification-id": null,
      "weak-password": null,
      "requires-recent-login": null
    };

    try {
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
      await _signOut();
    } on FirebaseAuthException catch (error) {
      String errorMessage =
          codeResponses[error.code] ?? "Wrong current password";
      _showErrorPopup(errorMessage);
    }
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StartPage(
            showRegisterPage: () {},
          ),
        ));
  }

  Future<void> _deleteAccount() async {
    try {
      final postQuerySnapshot = await FirebaseFirestore.instance
          .collection('posts')
          .where('users.UID', isEqualTo: uid)
          .get();

      for (var postDoc in postQuerySnapshot.docs) {
        final commentQuerySnapshot = await FirebaseFirestore.instance
            .collection('posts')
            .doc(postDoc.id)
            .collection('comments')
            .get();

        for (var commentDoc in commentQuerySnapshot.docs) {
          await commentDoc.reference.delete();
        }

        await postDoc.reference.delete();
      }

      await FirebaseFirestore.instance.collection('users').doc(uid).delete();

      await currentUser.delete();
    } catch (e) {
      print('Error deleting account: $e');
    }
  }

  Future<void> _updateEditInfoInFirestore(String title, String newValue) async {
    try {
      String userId = FirebaseAuth.instance.currentUser?.uid ?? "";
      print("Current User UID: $userId");

      DocumentSnapshot<Map<String, dynamic>> userDocument =
          await FirebaseFirestore.instance
              .collection("users")
              .doc(userId)
              .get();

      Map<String, dynamic> currentData = userDocument.data() ?? {};

      switch (title) {
        case "Course of Study":
          currentData["Course of Study"] = newValue;
          break;
        case "Semester":
          if (int.tryParse(newValue) != null) {
            currentData["Semester"] = int.parse(newValue);
          } else {
            print("Invalid integer for Semester: $newValue");
          }
          break;
        case "Faculty":
          if (int.tryParse(newValue) != null) {
            currentData["Faculty"] = int.parse(newValue);
          } else {
            print("Invalid integer for Faculty: $newValue");
          }
          break;
      }

      await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .set(currentData);

      print("$title updated in Firestore");
    } catch (e) {
      print("Error updating $title in Firestore: $e");
    }
  }

  Future<void> _updateEditProfileInFirestore(
      String newFirstName, String newCaption) async {
    try {
      String userId = FirebaseAuth.instance.currentUser?.uid ?? "";

      await FirebaseFirestore.instance.collection("users").doc(userId).update({
        "First Name": newFirstName,
        "Caption": newCaption,
      });

      print("User information updated in Firestore");
    } catch (e) {
      print("Error updating user information in Firestore: $e");
    }
  }

  Future<void> _uploadImageToFirebaseStorage() async {
    try {
      final Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('profile_images/${DateTime.now().millisecondsSinceEpoch}');
      await storageReference.putFile(_selectedImage!);
    } catch (e) {
      print('Error uploading image to Firebase Storage: $e');
    }
  }
}
