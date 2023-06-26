import 'package:flutter/material.dart';
import 'package:scorecard/models/player.dart';
import 'package:scorecard/models/result.dart';
import 'package:scorecard/screens/match/innings_play_screen/recent_balls.dart';
import 'package:scorecard/screens/match/match_tile.dart';
import 'package:scorecard/styles/color_styles.dart';
import 'package:scorecard/util/strings.dart';
import 'package:scorecard/util/elements.dart';
import 'package:scorecard/util/utils.dart';
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
  late final List<bool> _isInningsPanelOpen;
  Widget? resultLine;

  @override
  void initState() {
    super.initState();
    _isInningsPanelOpen =
        widget.match.inningsList.map((innings) => false).toList();
    if (_isInningsPanelOpen.isNotEmpty) {
      _isInningsPanelOpen.first = true;
    }
    if (widget.match.matchState == MatchState.completed) {
      String resultString;
      final result = widget.match.result;
      if (result.getVictoryType() == VictoryType.chasing) {
        resultString =
            "${result.winner.shortName} ${Strings.scoreWinWith} ${(result as ResultWinByChasing).ballsLeft} ${Strings.scoreWinByBallsToSpare}";
      } else if (result.getVictoryType() == VictoryType.defending) {
        resultString =
            "${result.winner.shortName} ${Strings.scoreWinBy} ${(result as ResultWinByDefending).runsWonBy} ${Strings.scoreWinByRuns}";
      } else {
        resultString = Strings.scoreMatchTied;
      }
      resultLine = Text(resultString);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.revertToParentMatch && widget.match.isSuperOver) {
      return _ScorecardMatchPanel(match: widget.match.parentMatch!);
    }

    return Column(children: [
      MatchTile(match: widget.match),
      const SizedBox(height: 32),
      if (resultLine != null) resultLine!,
      ExpansionPanelList(
        expandedHeaderPadding: const EdgeInsets.all(0),
        dividerColor: Colors.transparent,
        children: widget.match.inningsList
            .map(
              (innings) => _wInningsPanel(
                innings,
                innings.battingTeam.name + Strings.scorecardInningsWithSpace,
                widget.match.inningsList.indexOf(innings),
              ),
            )
            .toList(),
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
                const SizedBox(height: 16),
                _wBattingPanel(innings),
                const SizedBox(height: 16),
                _wBowlingPanel(innings),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: () => Utils.goToPage(
                        InningsTimelineScreen(innings: innings), context),
                    icon: const Icon(Icons.timeline),
                    label: const Text(Strings.goToTimeline),
                  ),
                ),
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
            .map((bowlInn) => _BowlerInningsScore(bowlerInnings: bowlInn))
            .toList());
  }

  Widget _wBattingPanel(Innings innings) {
    return _innerPanel(
      Strings.scorecardBatting,
      innings.battingTeam.color,
      innings.batterInnings
          .map((batInn) => _BattingInningsScore(batterInnings: batInn))
          .toList(),
    );
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

class _BowlerInningsScore extends StatelessWidget {
  final BowlerInnings bowlerInnings;
  const _BowlerInningsScore({required this.bowlerInnings});

  @override
  Widget build(BuildContext context) {
    final average = bowlerInnings.average;
    return GenericInningsScore(
      player: bowlerInnings.bowler,
      // secondary: "Economy: " + bowlerInnings.economy.toStringAsFixed(2),
      secondary:
          "${bowlerInnings.oversBowled} Overs at ${bowlerInnings.economy.toStringAsFixed(2)} RPO",
      trailPrimary:
          "${bowlerInnings.wicketsTaken.toString()}/${bowlerInnings.runsConceded.toString()}",
      trailSecondary:
          average == double.infinity ? "" : "@${average.toStringAsFixed(2)}",
    );
  }
}

class _BattingInningsScore extends StatelessWidget {
  final BatterInnings batterInnings;
  const _BattingInningsScore({required this.batterInnings});

  @override
  Widget build(BuildContext context) {
    return GenericInningsScore(
      player: batterInnings.batter,
      secondary: Strings.getWicketDescription(batterInnings.wicket),
      trailPrimary: batterInnings.runsScored.toString(),
      trailSecondary: batterInnings.numBallsFaced.toString(),
    );
  }
}

class GenericInningsScore extends StatelessWidget {
  final String secondary;
  final String trailPrimary;
  final String trailSecondary;
  final Player player;
  const GenericInningsScore({
    super.key,
    required this.player,
    required this.secondary,
    required this.trailPrimary,
    required this.trailSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return GenericItemTile(
      leading: Elements.getPlayerIcon(player, 40),
      primaryHint: player.name,
      secondaryHint: secondary,
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            trailPrimary,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Text(
            trailSecondary,
            // style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
