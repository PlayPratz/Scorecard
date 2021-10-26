import 'package:flutter/material.dart';
import 'package:scorecard/models/ball.dart';
import 'package:scorecard/models/cricketmatch.dart';
import 'package:scorecard/models/player.dart';
import 'package:scorecard/models/team.dart';
import 'package:scorecard/models/wicket.dart';
import 'package:scorecard/screens/widgets/matchtile.dart';

Team mi = Team("Mumbai Indians", "MI", []);
Team csk = Team("Chennai Super Kings", "CSK", []);

class MatchList extends StatefulWidget {
  MatchList({Key? key}) : super(key: key);

  @override
  State<MatchList> createState() => _MatchListState();
}

class _MatchListState extends State<MatchList> {
  final List<CricketMatch> matches = [
    CricketMatch(mi, csk, 2),
  ];

  @override
  Widget build(BuildContext context) {
    Player zack = Player(1, "Zack");
    Player max = Player(2, "Max");
    Player nick = Player(3, "Nick");
    matches[0].startMatch(Toss(mi, TossChoice.bowl));
    matches[0].currentInnings.addOver(Over(zack));
    matches[0].currentInnings.addBall(Ball(1));
    matches[0].currentInnings.addBall(Ball(1));
    matches[0].currentInnings.addBall(Ball(4));
    matches[0].currentInnings.addBall(Ball(1));
    matches[0].currentInnings.addBall(Ball.wicket(0, BowledWicket(max, zack)));
    matches[0].currentInnings.addBall(Ball(5));

    matches[0].currentInnings.addOver(Over(nick));
    matches[0].currentInnings.addBall(Ball(2));
    matches[0].currentInnings.addBall(Ball(1));
    matches[0].currentInnings.addBall(Ball(3));
    matches[0].currentInnings.addBall(Ball(6));
    matches[0].currentInnings.addBall(Ball(4));
    matches[0].currentInnings.addBall(Ball(4));

    matches[0].finishInnings();

    matches[0].currentInnings.addOver(Over(max));
    matches[0].currentInnings.addBall(Ball(2));
    matches[0].currentInnings.addBall(Ball(1));
    matches[0].currentInnings.addBall(Ball(3));
    matches[0].currentInnings.addBall(Ball(6));
    matches[0].currentInnings.addBall(Ball(4));
    matches[0].currentInnings.addBall(Ball(4));

    // matches[0].currentInnings.addOver(Over(Player(4, "gg")));

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
