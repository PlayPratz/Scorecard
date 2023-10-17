import 'package:flutter/material.dart';
import 'package:scorecard/models/innings.dart';
import 'package:scorecard/models/player.dart';
import 'package:scorecard/models/team.dart';
import 'package:scorecard/states/controllers/ball_details_state.dart';
import 'package:scorecard/styles/color_styles.dart';
import 'package:scorecard/screens/widgets/elements.dart';

import 'package:scorecard/models/wicket.dart';
import 'package:scorecard/util/strings.dart';
import 'package:scorecard/util/utils.dart';
import 'package:scorecard/screens/templates/titled_page.dart';
import 'package:scorecard/screens/widgets/generic_item_tile.dart';
import 'package:scorecard/screens/widgets/item_list.dart';

class WicketTile extends StatelessWidget {
  final BallDetailsStateController stateController;

  final Innings innings;

  const WicketTile(
      {super.key, required this.stateController, required this.innings});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: stateController.wicketStateSteam,
      builder: (context, snapshot) {
        final wicket = snapshot.data;
        final (primary, hint) = wicket == null
            ? (Strings.matchScreenAddWicket, Strings.matchScreenAddWicketHint)
            : (wicket.batter.name, Strings.getWicketDescription(wicket));
        return Card(
          margin: const EdgeInsets.all(0),
          surfaceTintColor: ColorStyles.wicket,
          child: GenericItemTile(
            leading: const Icon(
              Icons.gpp_bad,
              color: Colors.redAccent,
              size: 32,
            ),
            primaryHint: primary,
            secondaryHint: hint,
            trailing: Elements.forwardIcon,
            onSelect: () => _onSelectWicket(context, innings),
            onLongPress: () => stateController.selectWicket(null),
          ),
        );
      },
    );
  }

  void _onSelectWicket(BuildContext context, Innings innings) async {
    Wicket? selectedWicket = await Utils.goToPage(
        _WicketPickerScreen(
          fieldingTeam: innings.bowlingTeam,
          battingTeam: innings.battingTeam,
          playersInAction: innings.playersInAction,
        ),
        context);
    stateController.selectWicket(selectedWicket);
  }
}

class _WicketPickerScreen extends StatelessWidget {
  final PlayersInAction playersInAction;
  final TeamSquad battingTeam;
  final TeamSquad fieldingTeam;

  _WicketPickerScreen({
    required this.playersInAction,
    required this.battingTeam,
    required this.fieldingTeam,
  });

  final dismissalController = SelectableItemController<Dismissal>(maxItems: 1);
  final batterController = SelectableItemController<Player>(maxItems: 1);
  final fielderController = SelectableItemController<Player>(maxItems: 1);

  @override
  Widget build(BuildContext context) {
    return TitledPage(
      child: ListenableBuilder(
        listenable: Listenable.merge(
            [dismissalController, batterController, fielderController]),
        builder: (context, child) => Column(
          children: [
            Expanded(
              child: ListView(
                shrinkWrap: true,
                children: [
                  _wDismissalChooser,
                  if (_requiresBatter) _wBatterChooser(context),
                  if (_requiresFielder) _wFielderChooser(context),
                ],
              ),
            ),
            Elements.getConfirmButton(
              text: Strings.matchScreenAddWicket,
              onPressed: _canSubmit ? _processWicket : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget get _wDismissalChooser => Column(
        children: [
          const GenericItemTile(
            leading: Icon(Icons.gpp_bad),
            primaryHint: Strings.selectDismissal,
            secondaryHint: Strings.selectDismissalHint,
            trailing: null,
          ),
          SelectableItemList(
            items: Dismissal.values,
            controller: dismissalController,
            onBuild: (dismissal) => ListTile(
              leading: const SizedBox(),
              title: Text(Strings.getDismissalName(dismissal)),
              onTap: () {
                dismissalController.selectItem(dismissal);
              },
            ),
            onBuildSelected: (dismissal) => ListTile(
              leading: const SizedBox(),
              title: Text(Strings.getDismissalName(dismissal)),
              selected: true,
              onTap: () {
                dismissalController.selectItem(dismissal);
              },
              trailing: const Icon(Icons.check_circle),
              selectedColor: ColorStyles.wicket,
              selectedTileColor: ColorStyles.wicket.withOpacity(0.15),
            ),
          ),
        ],
      );

  Widget _wBatterChooser(BuildContext context) => Column(
        // mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(),
          const GenericItemTile(
            leading: Icon(Icons.sports_cricket_outlined),
            primaryHint: Strings.selectBatter,
            secondaryHint: Strings.selectBatterHint,
            trailing: null,
          ),
          SelectableItemList(
            items: [
              playersInAction.batter1.batter,
              if (playersInAction.batter2 != null)
                playersInAction.batter2!.batter
            ],
            controller: batterController,
            onBuild: (player) => ListTile(
              leading: Elements.getPlayerIcon(context, player, 36),
              title: Text(player.name),
              onTap: () {
                batterController.selectItem(player);
              },
            ),
            onBuildSelected: (player) => ListTile(
              leading: Elements.getPlayerIcon(context, player, 36),
              title: Text(player.name),
              selected: true,
              selectedColor: ColorStyles.wicket,
              selectedTileColor: ColorStyles.wicket.withOpacity(0.15),
              trailing: const Icon(Icons.check_circle),
              onTap: () {
                batterController.selectItem(player);
              },
            ),
          ),
        ],
      );

  Widget _wFielderChooser(BuildContext context) => Column(
        children: [
          const Divider(),
          const GenericItemTile(
            leading: Icon(Icons.sports_gymnastics),
            primaryHint: Strings.selectFielder,
            secondaryHint: Strings.selectFielderHint,
            trailing: null,
          ),
          SelectableItemList(
            items: fieldingTeam.squad,
            controller: fielderController,
            onBuild: (player) => ListTile(
              leading: Elements.getPlayerIcon(context, player, 36),
              title: Text(player.name),
              onTap: () {
                fielderController.selectItem(player);
              },
            ),
            onBuildSelected: (player) => ListTile(
              leading: Elements.getPlayerIcon(context, player, 36),
              title: Text(player.name),
              selected: true,
              selectedColor: ColorStyles.wicket,
              selectedTileColor: ColorStyles.wicket.withOpacity(0.15),
              trailing: const Icon(Icons.check_circle),
              onTap: () {
                fielderController.selectItem(player);
              },
            ),
          ),
        ],
      );

  bool get _requiresBatter =>
      _dismissal == Dismissal.runout || _dismissal == Dismissal.retired;

  bool get _requiresFielder =>
      _dismissal == Dismissal.caught ||
      _dismissal == Dismissal.runout ||
      _dismissal == Dismissal.stumped;

  bool get _canSubmit =>
      _dismissal != null &&
      (!_requiresBatter || _batter != null) &&
      (!_requiresFielder || _fielder != null);

  Dismissal? get _dismissal => dismissalController.selectedItems.singleOrNull;
  Player? get _batter => batterController.selectedItems.singleOrNull;
  Player? get _fielder => fielderController.selectedItems.singleOrNull;

  Player get _bowler => playersInAction.bowler.bowler;
  Player get _striker => playersInAction.striker.batter;

  void _processWicket() async {
    switch (_dismissal) {
      case Dismissal.retired:
        _sendWicketToParent(Wicket.runout(
          batter: _batter!,
          fielder: _fielder!,
        ));
        return;

      case Dismissal.runout:
        _sendWicketToParent(Wicket.runout(
          batter: _batter!,
          fielder: _fielder!,
        ));
        return;

      case Dismissal.caught:
        _sendWicketToParent(Wicket.caught(
          batter: playersInAction.bowler.bowler,
          bowler: playersInAction.bowler.bowler,
          fielder: _fielder!,
        ));
        return;
      case Dismissal.stumped:
        _sendWicketToParent(Wicket.stumped(
          batter: playersInAction.bowler.bowler,
          bowler: playersInAction.bowler.bowler,
          fielder: _fielder!,
        ));
        return;

      case Dismissal.hitWicket:
        _sendWicketToParent(Wicket.hitWicket(
          batter: _striker,
          bowler: playersInAction.bowler.bowler,
        ));
        return;
      case Dismissal.lbw:
        _sendWicketToParent(Wicket.lbw(
          batter: _striker,
          bowler: _bowler,
        ));
        return;
      case Dismissal.bowled:
      default:
        _sendWicketToParent(Wicket.bowled(
          batter: _striker,
          bowler: _bowler,
        ));
        return;
    }
  }

  void _sendWicketToParent(Wicket wicket) {
    // Utils.goBack(context, wicket);
  }
}
