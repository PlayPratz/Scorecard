import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scorecard/screens/match/innings_play_screen/players_on_pitch.dart';
import 'package:scorecard/screens/match/innings_play_screen/recent_balls.dart';
import 'package:scorecard/screens/match/innings_play_screen/input_choosers.dart';
import 'package:scorecard/screens/match/match_list.dart';
import 'package:scorecard/screens/match/match_tile.dart';
import 'package:scorecard/screens/match/player_pick.dart';
import 'package:scorecard/screens/match/scorecard.dart';
import 'package:scorecard/services/storage_service.dart';
import 'package:scorecard/state_managers/innings_manager.dart';

import '../../../models/cricket_match.dart';
import '../../../models/player.dart';
import '../../../styles/color_styles.dart';
import '../../../util/strings.dart';
import '../../../util/elements.dart';
import '../../../util/utils.dart';
import '../../player/player_list.dart';
import '../../templates/titled_page.dart';

class MatchInterface extends StatelessWidget {
  final CricketMatch match;
  const MatchInterface({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    return TitledPage(
      headerWidget: Selector<InningsManager, int>(
        selector: (context, inningsManager) =>
            inningsManager.innings.balls.length,
        builder: (context, inningsManager, child) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: InkWell(
            onTap: () => Utils.goToPage(Scorecard(match: match), context),
            child: Row(
              // mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: ScoreTile(
                      team: match.homeTeam,
                      battingInnings: match.currentInnings),
                ),
                // const SizedBox(width: 8),
                Expanded(
                  child: ScoreTile(
                      team: match.awayTeam,
                      battingInnings: match.currentInnings),
                ),
              ],
            ),
          ),
        ),
      ),
      toolbarHeight: 96,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RunRatePane(
            showTarget: (match.currentInnings == match.secondInnings),
          ),
          PlayersOnPitchView(
            isHomeTeamBatting:
                match.currentInnings.battingTeam == match.homeTeam,
          ),
          const RecentBallsView(),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                width: 100,
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: null,
                  onLongPress: () {
                    match.progressMatch();
                    handleOpenMatch(match, context);
                  },
                  icon: Icon(Icons.cancel),
                  label: Text("End"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                  ),
                ),
              ),
              const Expanded(child: WicketChooser()),
            ],
          ),
          ExtraChooser(),
          RunChooser(),
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

  Widget _wUndoButton(InningsManager inningsManager) {
    return OutlinedButton.icon(
      onPressed: inningsManager.canUndoMove ? inningsManager.undoMove : null,
      style: OutlinedButton.styleFrom(primary: ColorStyles.remove),
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
        };
        canClick = inningsManager.canAddBall;
        break;
      case NextInput.batter:
        text = Strings.matchScreenChooseBatter;
        onPressed = () => _chooseBatter(context, inningsManager);
        break;
      case NextInput.bowler:
        text = Strings.matchScreenChooseBowler;
        onPressed = () => _chooseBowler(context, inningsManager);
        break;
      case NextInput.end:
        text = Strings.matchScreenEndInnings;
        onPressed = () => _endInnings(context);
        break;
    }

    return Elements.getConfirmButton(
        text: text, onPressed: canClick ? onPressed : null);
  }

  void _chooseBatter(
      BuildContext context, InningsManager inningsManager) async {
    final player = await Utils.goToPage(
      PickBatter(
        squad: inningsManager.innings.battingTeam.squad,
        batterToReplace: inningsManager.batterToReplace!.batter,
        wicket: inningsManager.wicket,
      ),
      context,
    );

    if (player == null) {
      return;
    }
    inningsManager.addBatter(player);
  }

  void _chooseBowler(
      BuildContext context, InningsManager inningsManager) async {
    final player =
        await _choosePlayer(context, inningsManager.innings.bowlingTeam.squad);
    if (player != null) {
      inningsManager.setBowler(player);
    }
  }

  Future<Player?> _choosePlayer(
      BuildContext context, List<Player> squad) async {
    final Player? selectedPlayer = await Utils.goToPage(
        TitledPage(
          title: Strings.choosePlayer,
          child: PlayerList(
            playerList: squad,
            onSelectPlayer: (player) => Utils.goBack(context, player),
          ),
        ),
        context);

    return selectedPlayer;
  }

  void _endInnings(BuildContext context) {
    match.progressMatch();
    Utils.goBack(context);
    handleOpenMatch(match, context);
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
