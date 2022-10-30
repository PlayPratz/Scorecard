import 'package:flutter/material.dart';
import 'package:scorecard/util/elements.dart';
import '../../models/cricketmatch.dart';
import '../../models/innings.dart';
import '../../models/wicket.dart';
import '../titledpage.dart';
import '../widgets/genericitem.dart';
import '../widgets/matchtile.dart';

class Scorecard extends StatelessWidget {
  final CricketMatch match;
  const Scorecard({Key? key, required this.match}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String title = match.homeTeam.shortName + " v " + match.awayTeam.shortName;
    return TitledPage(
        title: title,
        child: SingleChildScrollView(
          child: Column(
            children: [
              MatchTile(match: match),
              Text("FIRST INNINGS"),
              Text("Batting"),
              ..._wbBattingPanel(match.firstInnings),
              Text("Bowling"),
              ..._wBowlingPanel(match.firstInnings),
              Text("SECOND INNINGS"),
              Text("Batting"),
              ..._wbBattingPanel(match.secondInnings),
              Text("Bowling"),
              ..._wBowlingPanel(match.secondInnings)
            ],
          ),
        ));
  }

  List<Widget> _wbBattingPanel(Innings innings) {
    return [
      ...innings.allBattingInnings.map(
        (battingInnings) => GenericItem(
          leading: Elements.getPlayerIcon(battingInnings.batter, 36),
          primaryHint: battingInnings.batter.name,
          secondaryHint: _getWicket(battingInnings.wicket),
          trailing: Text(battingInnings.score),
        ),
      )
    ];
  }

  List<Widget> _wBowlingPanel(Innings innings) {
    return [
      ...innings.allBowlingInnings.map(
        (bowlingInnings) => GenericItem(
          leading: Elements.getPlayerIcon(bowlingInnings.bowler, 36),
          primaryHint: bowlingInnings.bowler.name,
          secondaryHint:
              "Economy: " + bowlingInnings.economy.toStringAsFixed(2),
          trailing: Text(bowlingInnings.score),
        ),
      )
    ];
  }

  String _getWicket(Wicket? wicket) {
    if (wicket == null) {
      return "not out";
    }
    return "out";
  }
}
