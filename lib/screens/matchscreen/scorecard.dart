import 'package:flutter/material.dart';
import 'package:scorecard/screens/widgets/matchtile.dart';
import 'package:scorecard/styles/colorstyles.dart';
import 'package:scorecard/util/strings.dart';
import 'package:scorecard/util/elements.dart';
import '../../models/cricketmatch.dart';
import '../../models/innings.dart';
import '../../models/wicket.dart';
import '../templates/titledpage.dart';
import '../widgets/genericitem.dart';

class Scorecard extends StatefulWidget {
  final CricketMatch match;
  const Scorecard({Key? key, required this.match}) : super(key: key);

  @override
  State<Scorecard> createState() => _ScorecardState();
}

class _ScorecardState extends State<Scorecard> {
  List<bool> _isInningsPanelOpen = [true, false];

  @override
  Widget build(BuildContext context) {
    String title = widget.match.homeTeam.shortName +
        Strings.seperatorVersus +
        widget.match.awayTeam.shortName;

    return TitledPage(
      title: title,
      child: SingleChildScrollView(
        child: Column(
          children: [
            MatchTile(match: widget.match),
            const SizedBox(height: 16),
            ExpansionPanelList(
              dividerColor: Colors.transparent,
              children: [
                _wInningsPanel(
                    widget.match.firstInnings,
                    widget.match.firstInnings.battingTeam.name +
                        Strings.scorecardInningsWithSpace,
                    _isInningsPanelOpen[0]),
                _wInningsPanel(
                    widget.match.secondInnings,
                    widget.match.secondInnings.battingTeam.name +
                        Strings.scorecardInningsWithSpace,
                    _isInningsPanelOpen[1]),
              ],
              expansionCallback: (panelIndex, isExpanded) => setState(() {
                _isInningsPanelOpen[panelIndex] = !isExpanded;
              }),
            ),
          ],
        ),
      ),
    );
  }

  ExpansionPanel _wInningsPanel(
      Innings innings, String inningsTitle, bool isOpen) {
    return ExpansionPanel(
      backgroundColor: ColorStyles.background,
      isExpanded: isOpen,
      headerBuilder: (context, isExpanded) => Text(inningsTitle.toUpperCase()),
      body: innings.hasStarted
          ? Column(
              children: [
                _wBattingPanel(innings),
                const SizedBox(height: 16),
                _wBowlingPanel(innings),
                const SizedBox(height: 16),
              ],
            )
          : Text("Not started"),
    );
  }

  Widget _wBowlingPanel(Innings innings) {
    return _innerPanel(
        Strings.scorecardBowling,
        innings.bowlingTeam.color,
        innings.allBowlingInnings
            .map((bowlInn) => GenericItem(
                  leading: Elements.getPlayerIcon(bowlInn.bowler, 36),
                  primaryHint: bowlInn.bowler.name,
                  secondaryHint:
                      "Economy: " + bowlInn.economy.toStringAsFixed(2),
                  trailing: Text(bowlInn.score),
                ))
            .toList());
  }

  Widget _wBattingPanel(Innings innings) {
    return _innerPanel(
        Strings.scorecardBatting,
        innings.battingTeam.color,
        innings.allBattingInnings
            .map(
              (batInn) => GenericItem(
                leading: Elements.getPlayerIcon(batInn.batter, 36),
                primaryHint: batInn.batter.name,
                secondaryHint: _getWicket(batInn.wicket),
                trailing: Text(batInn.score),
              ),
            )
            .toList());
  }

  Widget _innerPanel(String heading, Color color, List<Widget> playerTiles) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Text(
              heading.toUpperCase(),
              // style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          ...playerTiles.map((tile) => Column(
                children: [
                  const Divider(color: Colors.white30, thickness: 1),
                  tile
                ],
              )),
        ],
      ),
    );
  }

  String _getWicket(Wicket? wicket) {
    if (wicket == null) {
      return "not out";
    }
    switch (wicket.dismissal) {
      case Dismissal.bowled:
      default:
        return Strings.wicketBowled + wicket.bowler!.name;
    }
  }
}
