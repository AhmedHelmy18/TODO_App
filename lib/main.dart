import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/authentication/auth_page/login_page.dart';
// import 'package:todo_app/authentication/auth_page/sign_up_page.dart';
// import 'package:todo_app/screen/home.dart';

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

class TODO_App extends StatelessWidget {
  const TODO_App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}
