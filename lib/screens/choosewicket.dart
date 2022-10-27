import 'package:flutter/material.dart';
import 'package:scorecard/screens/titledpage.dart';

class ChooseWicket extends StatefulWidget {
  const ChooseWicket({Key? key}) : super(key: key);

  @override
  State<ChooseWicket> createState() => _ChooseWicketState();
}

class _ChooseWicketState extends State<ChooseWicket> {
  @override
  Widget build(BuildContext context) {
    return TitledPage(
      title: "Choose a wicket",
      child: Column(
        children: [
          Text("Hello"),
        ],
      ),
    );
  }
}
