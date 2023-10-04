import 'package:flutter/material.dart';
import 'package:scorecard/models/cricket_match.dart';
import 'package:scorecard/models/player.dart';
import 'package:scorecard/screens/match/innings_play_screen/match_interface.dart';
import 'package:scorecard/screens/player/player_list.dart';
import 'package:scorecard/screens/templates/titled_page.dart';
import 'package:scorecard/screens/widgets/generic_item_tile.dart';
import 'package:scorecard/screens/widgets/item_list.dart';
import 'package:scorecard/screens/widgets/separated_widgets.dart';
import 'package:scorecard/util/elements.dart';
import 'package:scorecard/util/strings.dart';
import 'package:scorecard/util/utils.dart';

class InningsInitScreen extends StatefulWidget {
  final CricketMatch match;
  const InningsInitScreen({super.key, required this.match});

  @override
  State<InningsInitScreen> createState() => _InningsInitScreenState();
}

// TODO Convert to Stateless
class _InningsInitScreenState extends State<InningsInitScreen> {
  final batterController = SelectableItemController<Player>(maxItems: 2);
  final bowlerController = SelectableItemController<Player>(maxItems: 1);

  @override
  Widget build(BuildContext context) {
    return TitledPage(
        title: Strings.initInningsTitle,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: SeparatedWidgetPair(
                color: widget.match.nextTeamToBat.color.withOpacity(0.1),
                top: const GenericItemTile(
                  leading: Icon(Icons.sports_cricket),
                  primaryHint: Strings.initInningsChooseBatter,
                  secondaryHint: Strings.initInningsChooseBatterHint,
                  trailing: null,
                ),
                bottom: Expanded(
                  child: SelectablePlayerList(
                    players: widget.match.nextTeamToBat.squad,
                    controller: batterController,
                  ),
                ),
              ),
            ),
            Expanded(
                child: SeparatedWidgetPair(
              color: widget.match.nextTeamToBowl.color.withOpacity(0.1),
              top: const GenericItemTile(
                leading: Icon(Icons.sports_baseball),
                primaryHint: Strings.initInningsChooseBowler,
                secondaryHint: Strings.initInningsChooseBowlerHint,
                trailing: null,
              ),
              bottom: Expanded(
                child: SelectablePlayerList(
                  players: widget.match.nextTeamToBowl.squad,
                  controller: bowlerController,
                ),
              ),
            )),
            ListenableBuilder(
              // TODO Solve nested jugaad
              listenable: bowlerController,
              builder: (context, child) => ListenableBuilder(
                builder: (context, child) => _wConfirmButton(),
                listenable: batterController,
              ),
            )
          ],
        ));
  }

  Widget _wConfirmButton() {
    return Elements.getConfirmButton(
      text: Strings.initInningsStartInnings,
      onPressed: _canInitInnings
          ? () {
              widget.match.progressMatch();
              final batter1 = batterController.selectedItems.first;
              final batter2 = batterController.selectedItems.length == 2
                  ? batterController.selectedItems.last
                  : null;

              final bowler = bowlerController.selectedItems.first;

              widget.match.currentInnings.initialize(
                  batter1: batter1, batter2: batter2, bowler: bowler);

              //TODO Move
              Navigator.popUntil(
                  context, ModalRoute.withName(Navigator.defaultRouteName));
              Utils.goToPage(MatchInterface(match: widget.match), context);
            }
          : null,
    );
  }

  bool get _canInitInnings =>
      batterController.selectedItems.isNotEmpty &&
      bowlerController.selectedItems.singleOrNull != null;
}
