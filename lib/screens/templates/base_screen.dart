import 'package:flutter/material.dart';

class BaseScreen extends StatelessWidget {
  final Widget child;

  final Color? background;

  const BaseScreen({super.key, required this.child, this.background});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      child: SafeArea(
        child: child,
      ),
    );
  }
}
