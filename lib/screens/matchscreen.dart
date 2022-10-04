import 'package:flutter/material.dart';
import 'package:scorecard/models/cricketmatch.dart';
import 'package:scorecard/screens/titledpage.dart';

class MatchScreen extends StatefulWidget {
  final CricketMatch match;

  const MatchScreen({Key? key, required this.match}) : super(key: key);

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  @override
  Widget build(BuildContext context) {
    String title = widget.match.homeTeam.shortName +
        " v " +
        widget.match.awayTeam.shortName;

    return TitledPage(
      title: title,
      child: Container(),
    );
  }
}
