import 'package:flutter/material.dart';
import 'package:scorecard/models/cricketmatch.dart';
import 'package:scorecard/models/innings.dart';
import 'package:scorecard/models/wicket.dart';
import 'package:scorecard/screens/titledpage.dart';
import 'package:scorecard/screens/widgets/genericitem.dart';
import 'package:scorecard/screens/widgets/matchtile.dart';

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
              ..._wBowlingPanel(match.secondInnings),
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
          leading: SizedBox(
            height: 48,
            width: 48,
            child: battingInnings.batter.imagePath != null
                ? CircleAvatar(
                    foregroundImage:
                        AssetImage(battingInnings.batter.imagePath!),
                    radius: 24,
                  )
                : const Icon(Icons.person_outline),
          ),
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
          leading: SizedBox(
            height: 48,
            width: 48,
            child: bowlingInnings.bowler.imagePath != null
                ? CircleAvatar(
                    foregroundImage:
                        AssetImage(bowlingInnings.bowler.imagePath!),
                    radius: 24,
                  )
                : const Icon(Icons.person_outline),
          ),
          primaryHint: bowlingInnings.bowler.name,
          secondaryHint: bowlingInnings.economy.toStringAsFixed(2),
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
