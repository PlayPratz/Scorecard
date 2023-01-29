import 'package:flutter/material.dart';
import 'package:scorecard/screens/match/match_tile.dart';
import 'package:scorecard/styles/color_styles.dart';
import 'package:scorecard/util/strings.dart';
import 'package:scorecard/util/elements.dart';
import '../../models/cricket_match.dart';
import '../../models/innings.dart';
import '../templates/titled_page.dart';
import '../widgets/generic_item_tile.dart';

class Scorecard extends StatelessWidget {
  final CricketMatch match;
  const Scorecard({Key? key, required this.match}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String title = match.homeTeam.shortName +
        Strings.seperatorVersus +
        match.awayTeam.shortName;

    return TitledPage(
      title: title,
      child: SingleChildScrollView(
        child: _ScorecardMatchPanel(match: match),
      ),
    );
  }
}

class _ScorecardMatchPanel extends StatefulWidget {
  final CricketMatch match;
  final bool revertToParentMatch;
  const _ScorecardMatchPanel(
      {Key? key, required this.match, this.revertToParentMatch = true})
      : super(key: key);

  @override
  State<_ScorecardMatchPanel> createState() => __ScorecardMatchPanelState();
}

class __ScorecardMatchPanelState extends State<_ScorecardMatchPanel> {
  final List<bool> _isInningsPanelOpen = [false, false];

  @override
  Widget build(BuildContext context) {
    if (widget.revertToParentMatch && widget.match.isSuperOver) {
      return _ScorecardMatchPanel(match: widget.match.parentMatch!);
    }

    return Column(children: [
      MatchTile(match: widget.match),
      const SizedBox(height: 32),
      ExpansionPanelList(
        expandedHeaderPadding: const EdgeInsets.all(0),
        dividerColor: Colors.transparent,
        children: [
          _wInningsPanel(
              widget.match.firstInnings,
              widget.match.firstInnings.battingTeam.name +
                  Strings.scorecardInningsWithSpace,
              0),
          _wInningsPanel(
              widget.match.secondInnings,
              widget.match.secondInnings.battingTeam.name +
                  Strings.scorecardInningsWithSpace,
              1),
        ],
        expansionCallback: (panelIndex, isExpanded) => setState(() {
          _isInningsPanelOpen[panelIndex] = !isExpanded;
        }),
      ),
      if (widget.match.hasSuperOver) ...[
        const SizedBox(height: 32),
        _ScorecardMatchPanel(
          match: widget.match.superOver!,
          revertToParentMatch: false,
        ),
      ]
    ]);
  }

  ExpansionPanel _wInningsPanel(
      Innings innings, String inningsTitle, int index) {
    return ExpansionPanel(
      backgroundColor: ColorStyles.background,
      isExpanded: _isInningsPanelOpen[index],
      headerBuilder: (context, isExpanded) => InkWell(
          onTap: () => setState(() {
                _isInningsPanelOpen[index] = !isExpanded;
              }),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              inningsTitle.toUpperCase(),
            ),
          )),
      body: innings.balls.isNotEmpty
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
        innings.bowlerInnings
            .map((bowlInn) => GenericItemTile(
                  leading: Elements.getPlayerIcon(bowlInn.bowler, 40),
                  primaryHint: bowlInn.bowler.name,
                  secondaryHint:
                      "Economy: " + bowlInn.economy.toStringAsFixed(2),
                  trailing: Text("SCORE GOES HERE"),
                ))
            .toList());
  }

  Widget _wBattingPanel(Innings innings) {
    return _innerPanel(
        Strings.scorecardBatting,
        innings.battingTeam.color,
        innings.batterInnings
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
