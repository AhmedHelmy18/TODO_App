import 'package:flutter/material.dart';
import 'package:todo_app/constants/colors.dart';

class Appbar extends StatelessWidget {
  const Appbar({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildAppBar(context);
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
    );
  }
}
