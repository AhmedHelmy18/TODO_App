import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/authentication/auth_page/login_page.dart';
import 'package:todo_app/screen/home.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    const TODO_App(),
  );
}

class TODO_App extends StatefulWidget {
  const TODO_App({super.key});

  @override
  State<TODO_App> createState() => _TODO_AppState();
}

class _TODO_AppState extends State<TODO_App> {
  bool isLoggedIn = false;

  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen(
      (User? user) {
        if (user != null) {
          setState(
            () {
              isLoggedIn = user != null;
            },
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: !isLoggedIn ? LoginPage() : Home(),
    );
  }
}
