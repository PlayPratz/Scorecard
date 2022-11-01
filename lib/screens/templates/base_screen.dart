import 'package:flutter/material.dart';
import '../../styles/color_styles.dart';

class BaseScreen extends StatelessWidget {
  final Widget child;

  const BaseScreen({required this.child, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Material(
        color: ColorStyles.background,
        child: child,
      ),
    );
  }
}
