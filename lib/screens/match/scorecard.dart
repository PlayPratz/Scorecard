import 'package:flutter/material.dart';
import 'package:scorecard/screens/match/match_tile.dart';
import 'package:scorecard/styles/color_styles.dart';
import 'package:scorecard/util/strings.dart';
import 'package:scorecard/util/elements.dart';
import '../../models/cricket_match.dart';
import '../../models/innings.dart';
import '../templates/titled_page.dart';
import '../widgets/generic_item_tile.dart';

class Scorecard extends StatefulWidget {
  final CricketMatch match;
  const Scorecard({Key? key, required this.match}) : super(key: key);

  @override
  State<Scorecard> createState() => _ScorecardState();
}

class _ScorecardState extends State<Scorecard> {
  final List<bool> _isInningsPanelOpen = [false, false];

  @override
  Widget build(BuildContext context) {
    if (widget.match.isSuperOver) {
      return Scorecard(match: widget.match.parentMatch!);
    }

    String title = widget.match.homeTeam.shortName +
        Strings.seperatorVersus +
        widget.match.awayTeam.shortName;

    return TitledPage(
      title: title,
      child: SingleChildScrollView(
        child: Column(
          children: _wMatchPanel(widget.match),
        ),
      ),
    );
  }

  List<Widget> _wMatchPanel(CricketMatch? match) {
    if (match == null) {
      return [];
    }
    List<Widget> children = [
      MatchTile(match: match),
      const SizedBox(height: 32),
      ExpansionPanelList(
        expandedHeaderPadding: const EdgeInsets.all(0),
        dividerColor: Colors.transparent,
        children: [
          _wInningsPanel(
              match.firstInnings,
              match.firstInnings.battingTeam.name +
                  Strings.scorecardInningsWithSpace,
              _isInningsPanelOpen[0]),
          _wInningsPanel(
              match.secondInnings,
              match.secondInnings.battingTeam.name +
                  Strings.scorecardInningsWithSpace,
              _isInningsPanelOpen[1]),
        ],
        expansionCallback: (panelIndex, isExpanded) => setState(() {
          _isInningsPanelOpen[panelIndex] = !isExpanded;
        }),
      ),
    ];

    return [...children, ..._wMatchPanel(match.superOver)];
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
            .map((bowlInn) => GenericItemTile(
                  leading: Elements.getPlayerIcon(bowlInn.bowler, 40),
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
              (batInn) => GenericItemTile(
                leading: Elements.getPlayerIcon(batInn.batter, 40),
                primaryHint: batInn.batter.name,
                secondaryHint: Strings.getWicketDescription(batInn.wicket),
                trailing: Text(
                  batInn.score,
                  // style: TextStyle(fontSize: 16),
                ),
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
}
