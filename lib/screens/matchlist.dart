import 'package:flutter/material.dart';
import 'package:scorecard/models/ball.dart';
import 'package:scorecard/models/cricketmatch.dart';
import 'package:scorecard/models/team.dart';
import 'package:scorecard/screens/creatematch.dart';
import 'package:scorecard/screens/widgets/itemlist.dart';
import 'package:scorecard/screens/widgets/matchtile.dart';
import 'package:scorecard/styles/strings.dart';
import 'package:scorecard/util/utils.dart';

Team mi = Team("Mumbai Indians", "MI", []);
Team csk = Team("Chennai Super Kings", "CSK", []);

class MatchList extends StatelessWidget {
  final List<CricketMatch> matchList = [
    CricketMatch(homeTeam: mi, awayTeam: csk, maxOvers: 1, maxWickets: 2),
  ];

  MatchList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    matchList[0].startMatch(Toss(csk, TossChoice.bowl));
    matchList[0].startFirstInnings();
    matchList[0].currentInnings.addOver(Over(Utils.getAllPlayers()[1]));
    matchList[0].currentInnings.addBall(Ball(1));
    matchList[0].currentInnings.addBall(Ball(2));
    matchList[0].currentInnings.addBall(Ball(6));
    matchList[0].currentInnings.addBall(Ball(6));
    matchList[0].currentInnings.addBall(Ball(6));
    matchList[0].currentInnings.addBall(Ball(2));
    matchList[0].finishFirstInnings();
    matchList[0].currentInnings.addOver(Over(Utils.getAllPlayers()[2]));
    matchList[0].currentInnings.addBall(Ball(2));
    matchList[0].currentInnings.addBall(Ball(6));
    matchList[0].currentInnings.addBall(Ball(6));
    matchList[0].currentInnings.addBall(Ball(6));
    matchList[0].currentInnings.addBall(Ball(6));
    // matchList[0].currentInnings.addBall(Ball(1));
    matchList[0].generateResult();

    return ItemList(
      itemList: getMatchList(),
      createItemPage: CreateMatchForm(),
      createItemString: Strings.matchlistCreateNewMatch,
    );
  }

  List<Widget> getMatchList() {
    List<MatchTile> matchTiles = [];
    for (CricketMatch match in matchList) {
      matchTiles.add(MatchTile(match: match));
    }
    return matchTiles;
  }
}
