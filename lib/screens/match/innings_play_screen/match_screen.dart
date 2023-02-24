import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scorecard/models/innings.dart';
import 'package:scorecard/screens/match/innings_play_screen/players_on_pitch.dart';
import 'package:scorecard/screens/match/innings_play_screen/recent_balls.dart';
import 'package:scorecard/screens/match/innings_play_screen/input_choosers.dart';
import 'package:scorecard/screens/match/match_list.dart';
import 'package:scorecard/screens/match/match_tile.dart';
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
          const SizedBox(height: 0),
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
                width: 96,
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
              Expanded(child: const WicketChooser()),
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
    final player =
        await _choosePlayer(context, inningsManager.innings.battingTeam.squad);
    if (player != null) {
      inningsManager.setBatter(
          BatterInnings(batter: player, innings: inningsManager.innings));
    }
  }

  void _chooseBowler(
      BuildContext context, InningsManager inningsManager) async {
    final player =
        await _choosePlayer(context, inningsManager.innings.bowlingTeam.squad);
    if (player != null) {
      inningsManager.setBowler(
          BowlerInnings(bowler: player, innings: inningsManager.innings));
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
    handleOpenMatch(match, context);
  }
}

class RunRatePane extends StatelessWidget {
  final bool showTarget;
  const RunRatePane({super.key, this.showTarget = false});

  @override
  Widget build(BuildContext context) {
    final innings = context.watch<InningsManager>().innings;
    return Row(
      children: !showTarget
          ? [
              Expanded(
                child: ScoreTileInner(
                  teamName: "Current RR",
                  score: innings.currentRunRate.toStringAsFixed(2),
                  color: Colors.blueGrey,
                ),
              ),
              Expanded(
                child: ScoreTileInner(
                  teamName: "Projected",
                  score: innings.projectedRuns.toString(),
                  color: Colors.lime,
                ),
              ),
            ]
          : [
              Expanded(
                child: ScoreTileInner(
                  teamName: "Required",
                  score: innings.requiredRuns.toString(),
                  color: Colors.green,
                ),
              ),
              Expanded(
                child: ScoreTileInner(
                  teamName: "Balls Left",
                  score: innings.ballsLeft.toString(),
                  color: Colors.red,
                ),
              ),
            ],
    );
  }
}
