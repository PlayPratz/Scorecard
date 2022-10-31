import 'package:flutter/material.dart';
import 'package:scorecard/styles/strings.dart';
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
    String title = match.homeTeam.shortName +
        Strings.seperatorHyphen +
        match.awayTeam.shortName;
    return TitledPage(
        title: title,
        child: SingleChildScrollView(
          child: Column(
            children: [
              MatchTile(match: match),
              _wInningsPanel(match.firstInnings, Strings.scorecardFirstInnings),
              _wInningsPanel(
                  match.secondInnings, Strings.scorecardSecondInnings),
            ],
          ),
        ));
  }

  Widget _wInningsPanel(Innings innings, String inningsTitle) {
    return Column(
      children: [
        Text(inningsTitle),
        Text(Strings.scorecardBatting),
        ..._wbBattingPanel(innings),
        Text(Strings.scorecardBowling),
        ..._wBowlingPanel(innings)
      ],
    );
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
