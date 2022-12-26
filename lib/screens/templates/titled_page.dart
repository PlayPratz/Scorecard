import 'package:flutter/material.dart';
import 'package:scorecard/screens/templates/base_screen.dart';
import 'package:scorecard/styles/color_styles.dart';
import 'package:scorecard/util/utils.dart';

class TitledPage extends StatelessWidget {
  final String title;
  final Widget child;

  final bool showBackButton;

  const TitledPage(
      {Key? key,
      required this.title,
      required this.child,
      this.showBackButton = true})
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
          leading: showBackButton
              ? InkWell(
                  child: const Icon(Icons.chevron_left),
                  onTap: () => Utils.goBack(context),
                )
              : null,
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
