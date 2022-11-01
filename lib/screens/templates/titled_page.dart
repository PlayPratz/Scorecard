import 'package:flutter/material.dart';
import 'package:scorecard/screens/templates/base_screen.dart';
import 'package:scorecard/styles/color_styles.dart';
import 'package:scorecard/util/utils.dart';

class TitledPage extends StatelessWidget {
  final String title;
  final Widget child;

  const TitledPage({Key? key, required this.title, required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      child: Scaffold(
        backgroundColor: ColorStyles.background,
        appBar: AppBar(
          title: Text(
            title,
          ),
          leading: InkWell(
            child: const Icon(Icons.chevron_left),
            onTap: () => Utils.goBack(context),
          ),
          elevation: 0,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: child,
        ),
      ),
    );
  }
}
