import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scorecard/models/innings.dart';
import 'package:scorecard/screens/match/innings_play_screen/players_on_pitch.dart';
import 'package:scorecard/screens/match/innings_play_screen/recent_balls.dart';
import 'package:scorecard/screens/match/innings_play_screen/input_choosers.dart';
import 'package:scorecard/state_managers/innings_manager.dart';

import '../../../models/cricket_match.dart';
import '../../../models/player.dart';
import '../../../styles/color_styles.dart';
import '../../../util/strings.dart';
import '../../../util/elements.dart';
import '../../../util/utils.dart';
import '../../player/player_list.dart';
import '../../templates/titled_page.dart';
import '../match_tile.dart';
import '../scorecard.dart';

class MatchInterface extends StatelessWidget {
  final CricketMatch match;
  const MatchInterface({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    final title = match.homeTeam.shortName +
        Strings.seperatorVersus +
        match.awayTeam.shortName;
    return TitledPage(
      title: title,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          MatchTile(
            match: match,
            onSelectMatch: (match) =>
                Utils.goToPage(Scorecard(match: match), context),
          ),
          const RecentBallsView(),
          const PlayersOnPitchView(),
          const WicketChooser(),
          const ExtraChooser(),
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
        onPressed = () => inningsManager.addBall();
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
        onPressed = inningsManager.endInnings;
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
}
