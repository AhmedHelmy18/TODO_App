import 'package:flutter/material.dart';
import 'package:todo_app/screen/home.dart';

void main() {
  runApp(const TODO_App());
}

class TODO_App extends StatelessWidget {
  const TODO_App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}
