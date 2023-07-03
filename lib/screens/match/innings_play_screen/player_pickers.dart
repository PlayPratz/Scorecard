import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scorecard/models/innings.dart';
import 'package:scorecard/models/player.dart';
import 'package:scorecard/models/wicket.dart';
import 'package:scorecard/screens/match/innings_play_screen/players_in_action.dart';
import 'package:scorecard/screens/player/player_list.dart';
import 'package:scorecard/screens/templates/titled_page.dart';
import 'package:scorecard/screens/widgets/separated_widgets.dart';
import 'package:scorecard/state_managers/innings_manager.dart';
import 'package:scorecard/util/strings.dart';
import 'package:scorecard/util/utils.dart';

class BatterPicker extends StatelessWidget {
  final List<Player> squad;
  final BatterInnings batterToReplace;
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
                player: batterToReplace.batter,
                score: wicket != null
                    ? Strings.getWicketDescription(wicket)
                    : "null",
              ),
              bottom: Expanded(
                child: PlayerList(
                  playerList: squad,
                  onSelectPlayer: (player) => Utils.goBack(context, player),
                ),
              ),
            ),
          ),
          const SizedBox(height: 64),
        ],
      ),
    );
  }
}

void chooseBatter(BuildContext context, BatterInnings batterToReplace) async {
  final inningsManager = context.read<InningsManager>();
  final player = await Utils.goToPage(
    BatterPicker(
      squad: inningsManager.innings.battingTeam.squad,
      batterToReplace: batterToReplace,
      wicket: inningsManager.wicket,
    ),
    context,
  );

  if (player == null) {
    return;
  }
  inningsManager.addBatter(inBatter: player, outBatter: batterToReplace);
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
