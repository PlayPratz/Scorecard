import 'package:flutter/material.dart';
import 'package:scorecard/models/innings.dart';
import 'package:scorecard/models/player.dart';
import 'package:scorecard/models/wicket.dart';
import 'package:scorecard/screens/match/innings_play_screen/players_in_action.dart';
import 'package:scorecard/screens/player/player_list.dart';
import 'package:scorecard/screens/templates/titled_page.dart';
import 'package:scorecard/screens/widgets/separated_widgets.dart';
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
                    ? Text(Strings.getWicketDescription(wicket))
                    : const SizedBox(),
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

Future<Player?> chooseBatter(
  BuildContext context,
  Innings innings,
  BatterInnings batterToReplace,
  Wicket? wicket,
) async {
  final player = await Utils.goToPage(
    BatterPicker(
      squad: innings.battingTeam.squad,
      batterToReplace: batterToReplace,
      wicket: wicket,
    ),
    context,
  );

  return player;
}

Future<Player?> chooseBowler(BuildContext context, Innings innings) async {
  final player = await choosePlayer(context, innings.bowlingTeam.squad);
  return player;
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
