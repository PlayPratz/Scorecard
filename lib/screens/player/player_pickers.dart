import 'package:flutter/material.dart';
import 'package:scorecard/models/innings.dart';
import 'package:scorecard/models/player.dart';
import 'package:scorecard/models/team.dart';
import 'package:scorecard/screens/match/innings_play_screen/players_in_action.dart';
import 'package:scorecard/screens/player/player_list.dart';
import 'package:scorecard/screens/templates/titled_page.dart';
import 'package:scorecard/screens/widgets/elements.dart';
import 'package:scorecard/screens/widgets/generic_item_tile.dart';
import 'package:scorecard/screens/widgets/item_list.dart';
import 'package:scorecard/screens/widgets/separated_widgets.dart';
import 'package:scorecard/util/strings.dart';
import 'package:scorecard/util/utils.dart';

class _BatterPicker extends StatelessWidget {
  final TeamSquad teamSquad;
  final BatterInnings batterToReplace;
  const _BatterPicker({
    required this.teamSquad,
    required this.batterToReplace,
  });

  @override
  Widget build(BuildContext context) {
    final wicket = batterToReplace.wicket;
    return _SinglePlayerPicker(
      title: Strings.pickBatterTitle,
      player: batterToReplace.batter,
      secondary: wicket != null
          ? Strings.getWicketDescription(wicket)
          : Strings.whitespace,
      trailing: BatterRuns(batterToReplace),
      submitText: Strings.matchScreenChooseBatter,
      teamSquad: teamSquad,
    );
  }
}

Future<Player?> chooseBatter(
  BuildContext context,
  Innings innings,
  BatterInnings batterToReplace,
) async {
  final player = await Utils.goToPage(
    _BatterPicker(
      teamSquad: innings.battingTeam,
      batterToReplace: batterToReplace,
    ),
    context,
  );

  return player;
}

class _BowlerPicker extends StatelessWidget {
  final TeamSquad teamSquad;
  final BowlerInnings bowlerToReplace;

  const _BowlerPicker({required this.teamSquad, required this.bowlerToReplace});

  @override
  Widget build(BuildContext context) {
    return _SinglePlayerPicker(
      title: Strings.pickBowlerTitle,
      player: bowlerToReplace.bowler,
      secondary: Strings.getBowlerOversBowled(bowlerToReplace) + " overs",
      trailing: Text(
        Strings.getBowlerFigures(bowlerToReplace),
        style: Theme.of(context).textTheme.titleLarge,
      ),
      submitText: Strings.matchScreenChooseBowler,
      teamSquad: teamSquad,
    );
  }
}

class _SinglePlayerPicker extends StatelessWidget {
  final String title;

  final Player player;
  final String secondary;
  final Widget trailing;

  final String submitText;

  final TeamSquad teamSquad;

  _SinglePlayerPicker({
    required this.title,
    required this.player,
    required this.secondary,
    required this.trailing,
    required this.submitText,
    required this.teamSquad,
  });

  final playerController = SelectableItemController<Player>(maxItems: 1);

  @override
  Widget build(BuildContext context) {
    return TitledPage(
      title: title,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(
            child: SeparatedWidgetPair(
              top: GenericItemTile(
                leading: Elements.getPlayerIcon(context, player, 48),
                primaryHint: player.name,
                secondaryHint: secondary,
                trailing: trailing,
                shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(12.0))),
              ),
              bottom: Flexible(
                child: SelectablePlayerList(
                  players: teamSquad.squad,
                  controller: playerController,
                ),
              ),
              color: teamSquad.team.color.withOpacity(0.25),
            ),
          ),
          ListenableBuilder(
            listenable: playerController,
            builder: (context, _) => Elements.getConfirmButton(
                text: submitText,
                onPressed: playerController.selectedItems.singleOrNull == null
                    ? null
                    : () {
                        Utils.goBack(
                            context, playerController.selectedItems.single);
                      }),
          ),
        ],
      ),
    );
  }
}

Future<Player?> chooseBowler(BuildContext context, Innings innings,
    BowlerInnings bowlerToReplace) async {
  final player = await Utils.goToPage(
    _BowlerPicker(
      teamSquad: innings.bowlingTeam,
      bowlerToReplace: bowlerToReplace,
    ),
    context,
  );

  return player;
}

Future<Player?> choosePlayer(BuildContext context, List<Player> squad) async {
  final Player? selectedPlayer = await Utils.goToPage(
      TitledPage(
        title: Strings.choosePlayer,
        child: PlayerList(
          playerList: squad,
          onSelect: (player) => Utils.goBack(context, player),
        ),
      ),
      context);

  return selectedPlayer;
}
