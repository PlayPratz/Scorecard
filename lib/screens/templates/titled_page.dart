import 'package:flutter/material.dart';
import 'package:scorecard/screens/templates/base_screen.dart';
import 'package:scorecard/util/utils.dart';

class TitledPage extends StatelessWidget {
  final String? title;
  final Widget child;
  final Widget? headerWidget;
  final double toolbarHeight;

  final bool showBackButton;

  final Color? backgroundColor;
  final Color? appBarColor;

  const TitledPage(
      {Key? key,
      this.title,
      this.headerWidget,
      this.toolbarHeight = kToolbarHeight,
      required this.child,
      this.showBackButton = true,
      this.backgroundColor,
      this.appBarColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      background: backgroundColor,
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          title: title != null ? Text(title!) : null,
          leading: showBackButton
              ? InkWell(
                  child: const Icon(Icons.chevron_left),
                  onTap: () => Utils.goBack(context),
                )
              : null,
          elevation: 0,
          flexibleSpace: headerWidget,
          toolbarHeight: toolbarHeight,
          backgroundColor: appBarColor,
        ),
        body: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          child: child,
        ),
      ),
    );
  }
}
