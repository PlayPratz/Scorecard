import 'package:flutter/material.dart';
import 'package:scorecard/models/player.dart';
import 'package:scorecard/models/wicket.dart';
import 'package:scorecard/screens/match/innings_play_screen/player_score_tile.dart';
import 'package:scorecard/screens/player/player_list.dart';
import 'package:scorecard/screens/templates/titled_page.dart';
import 'package:scorecard/screens/widgets/separated_widgets.dart';
import 'package:scorecard/state_managers/innings_manager.dart';
import 'package:scorecard/util/strings.dart';
import 'package:scorecard/util/utils.dart';

class BatterPicker extends StatelessWidget {
  final List<Player> squad;
  final Player batterToReplace;
  final Wicket? wicket;
  const BatterPicker({
    super.key,
    required this.squad,
    required this.batterToReplace,
    this.wicket,
  });

  @override
  Widget build(BuildContext context) {
    return TitledPage(
      title: Strings.pickBatterTitle,
      child: Column(
        children: [
          const Spacer(),
          Flexible(
            flex: 2,
            child: SeparatedWidgetPair(
              top: PlayerScoreTile.wicket(
                player: batterToReplace,
                score:
                    wicket != null ? Strings.getWicketDescription(wicket) : "",
              ),
              bottom: Expanded(
                child: PlayerList(
                  playerList: squad,
                  onSelectPlayer: (player) => Utils.goBack(context, player),
                ),
              ),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

void chooseBatter(BuildContext context, InningsManager inningsManager) async {
  final player = await Utils.goToPage(
    BatterPicker(
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

void chooseBowler(BuildContext context, InningsManager inningsManager) async {
  final player =
      await choosePlayer(context, inningsManager.innings.bowlingTeam.squad);
  if (player != null) {
    inningsManager.setBowler(player);
  }
}

Future<Player?> choosePlayer(BuildContext context, List<Player> squad) async {
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
