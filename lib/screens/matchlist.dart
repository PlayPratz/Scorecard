import 'package:flutter/material.dart';
import 'package:scorecard/models/cricketmatch.dart';
import 'package:scorecard/models/team.dart';
import 'package:scorecard/screens/widgets/matchtile.dart';

Team mi = Team("Mumbai Indians", "MI", []);
Team csk = Team("Chennai Super Kings", "CSK", []);

class MatchList extends StatelessWidget {
  final List<CricketMatch> matches = [
    CricketMatch(homeTeam: mi, awayTeam: csk, maxOvers: 2, maxWickets: 2),
  ];

  MatchList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: MatchTile(match: matches[index]),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      itemCount: matches.length,
    );
  }
}
