import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scorecard/models/result.dart';
import 'package:scorecard/screens/match/innings_init.dart';
import 'package:scorecard/screens/match/innings_play_screen/players_in_action.dart';
import 'package:scorecard/screens/match/innings_play_screen/recent_balls.dart';
import 'package:scorecard/screens/match/innings_play_screen/ball_details_selector.dart';
import 'package:scorecard/screens/match/innings_play_screen/wicket_details_selector.dart';
import 'package:scorecard/screens/match/match_tile.dart';
import 'package:scorecard/screens/match/innings_play_screen/player_pickers.dart';
import 'package:scorecard/screens/match/scorecard.dart';
import 'package:scorecard/screens/widgets/generic_item_tile.dart';
import 'package:scorecard/services/storage_service.dart';
import 'package:scorecard/state_managers/innings_manager.dart';

import '../../../models/cricket_match.dart';
import '../../../styles/color_styles.dart';
import '../../../util/strings.dart';
import '../../../util/elements.dart';
import '../../../util/utils.dart';
import '../../templates/titled_page.dart';

class MatchInterface extends StatelessWidget {
  final CricketMatch match;
  const MatchInterface({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    return TitledPage(
      backgroundColor: match.currentInnings.battingTeam.color.withOpacity(0.10),
      appBarColor: Colors.transparent,
      // headerWidget: Selector<InningsManager, int>(
      //   selector: (context, inningsManager) =>
      //       inningsManager.innings.balls.length,
      //   builder: (context, inningsManager, child) => Padding(
      //     padding: const EdgeInsets.symmetric(horizontal: 8.0),
      //     child: InkWell(
      //       onTap: () => Utils.goToPage(Scorecard(match: match), context),
      //       child: Row(
      //         // mainAxisSize: MainAxisSize.min,
      //         children: [
      //           Expanded(
      //             child: ScoreTile(
      //                 team: match.homeTeam,
      //                 battingInnings: match.currentInnings),
      //           ),
      //           // const SizedBox(width: 8),
      //           Expanded(
      //             child: ScoreTile(
      //                 team: match.awayTeam,
      //                 battingInnings: match.currentInnings),
      //           ),
      //         ],
      //       ),
      //     ),
      //   ),
      // ),
      // toolbarHeight: 96,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // RunRatePane(
          //   showTarget: (match.currentInnings == match.secondInnings),
          // ),
          Card(
            child: Row(
              children: [
                Expanded(
                  child: ScoreTile(
                      team: match.homeTeam,
                      battingInnings: match.currentInnings),
                ),
                Expanded(
                  child: ScoreTile(
                      team: match.awayTeam,
                      battingInnings: match.currentInnings),
                ),
              ],
            ),
          ),
          PlayersInActionPane(
            isHomeTeamBatting:
                match.currentInnings.battingTeam == match.homeTeam,
          ),
          const RecentBallsPane(),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _wEndInningsButton(context),
              const Expanded(child: WicketTile()),
            ],
          ),
          const SizedBox(height: 16),
          ExtraSelector(),
          const SizedBox(height: 16),
          RunSelector(),
          const SizedBox(height: 16),
          Consumer<InningsManager>(
            builder: (context, inningsManager, child) => Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(child: _wUndoButton(inningsManager)),
                const SizedBox(width: 16),
                Expanded(
                    flex: 2, child: _wConfirmButton(context, inningsManager))
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _wEndInningsButton(BuildContext context) => SizedBox(
        width: 100,
        height: 56,
        child: ElevatedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(Strings.matchScreenEndInningsLongPressToEnd,
                    style: TextStyle(color: Colors.white)),
                backgroundColor: ColorStyles.card,
                showCloseIcon: true,
                closeIconColor: Colors.white,
                dismissDirection: DismissDirection.horizontal,
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 32),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          onLongPress: () => _endInnings(context),
          icon: const Icon(Icons.cancel),
          label: const Text(Strings.matchScreenEndInningsShort),
          style: ElevatedButton.styleFrom(
            foregroundColor: ColorStyles.remove,
            backgroundColor: ColorStyles.remove.withOpacity(0.1),
          ),
        ),
      );

  Widget _wUndoButton(InningsManager inningsManager) {
    return ElevatedButton.icon(
      onPressed: inningsManager.canUndoBall
          ? () {
              inningsManager.undoBall();
              recentBallsViewKey.currentState?.removeItem(
                0,
                (context, animation) => const SizedBox(),
                duration: Duration.zero,
              );
            }
          : null,
      style: ElevatedButton.styleFrom(
        foregroundColor: ColorStyles.remove,
        backgroundColor: ColorStyles.remove.withOpacity(0.1),
      ),
      icon: const Icon(Icons.undo),
      label: const Text(Strings.matchScreenUndo),
    );
  }

  Widget _wConfirmButton(BuildContext context, InningsManager inningsManager) {
    String text = Strings.buttonNext;
    bool canClick = inningsManager.canAddBall;
    VoidCallback onPressed;
    switch (inningsManager.nextInput) {
      case NextInput.ball:
        text = Strings.buttonNext;
        onPressed = () {
          inningsManager.addBall();
          StorageService.saveMatch(match);
          recentBallsViewKey.currentState?.insertItem(0);
        };
        canClick = inningsManager.canAddBall;
        break;
      case NextInput.batter:
        text = Strings.matchScreenChooseBatter;
        onPressed = () => chooseBatter(context, inningsManager);
        break;
      case NextInput.bowler:
        text = Strings.matchScreenChooseBowler;
        onPressed = () => chooseBowler(context, inningsManager);
        break;
      case NextInput.end:
        text = Strings.matchScreenEndInnings;
        onPressed = () => _endInnings(context);
        break;
    }

    return Elements.getConfirmButton(
        text: text, onPressed: canClick ? onPressed : null);
  }

  void _endInnings(BuildContext context) {
    // final inningsManager = context.read<InningsManager>();
    if (match.matchState == MatchState.secondInnings ||
        match.matchState == MatchState.completed) {
      // TODO make this such that matchState need not be checked
      match.progressMatch();
      if (match.result.getVictoryType() == VictoryType.tie) {
        // Show Super Over option
        showModalBottomSheet(
          context: context,
          builder: (context) => Material(
            color: ColorStyles.background,
            child: Column(
              children: [
                const SizedBox(height: 32),
                const Text(
                  Strings.matchScreenMatchTied,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),
                const Text(Strings.matchScreenMatchTiedHint),
                const SizedBox(height: 32),
                GenericItemTile(
                  leading: const Icon(Icons.handshake),
                  primaryHint: Strings.matchScreenEndTiedMatch,
                  secondaryHint: Strings.matchScreenEndTiedMatchHint,
                  onSelect: () {
                    Utils.goBack(context);
                    Utils.goToReplacementPage(Scorecard(match: match), context);
                  },
                ),
                const SizedBox(height: 32),
                GenericItemTile(
                  leading: const Icon(Icons.sports_baseball),
                  primaryHint: Strings.matchScreenSuperOver,
                  secondaryHint: Strings.matchScreenSuperOverHint,
                  onSelect: () {
                    match.startSuperOver();
                    Utils.goBack(context);
                    Utils.goToReplacementPage(
                        InningsInitScreen(match: match.superOver!), context);
                  },
                ),
              ],
            ),
          ),
        );
        return;
      }

      // Show Scorecard for completed Match
      Utils.goToReplacementPage(Scorecard(match: match), context);
      return;
    }
    Utils.goToReplacementPage(InningsInitScreen(match: match), context);
  }
}

class RunRatePane extends StatelessWidget {
  final bool showTarget;
  const RunRatePane({super.key, this.showTarget = false});

  @override
  Widget build(BuildContext context) {
    final innings = context.watch<InningsManager>().innings;
    final dataTextStyle = Theme.of(context).textTheme.headlineMedium;
    return Row(
      children: !showTarget
          ? [
              Expanded(
                child: ScoreTileInner(
                  teamName: "Run Rate",
                  score: innings.currentRunRate.toStringAsFixed(2),
                  color: Colors.blueGrey,
                  dataTextStyle: dataTextStyle,
                ),
              ),
              Expanded(
                child: ScoreTileInner(
                  teamName: "Projected",
                  score: innings.projectedRuns.toString(),
                  color: Colors.lime,
                  dataTextStyle: dataTextStyle,
                ),
              ),
            ]
          : [
              Expanded(
                child: ScoreTileInner(
                  teamName: "Required",
                  score: max(innings.requiredRuns, 0).toString(),
                  color: Colors.green,
                  dataTextStyle: dataTextStyle,
                ),
              ),
              Expanded(
                child: ScoreTileInner(
                  teamName: "Balls Left",
                  score: innings.ballsLeft.toString(),
                  color: Colors.red,
                  dataTextStyle: dataTextStyle,
                ),
              ),
            ],
    );
  }
}
