import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scorecard/models/cricket_match.dart';
import 'package:scorecard/models/team.dart';
import 'package:scorecard/screens/match/innings_init.dart';
import 'package:scorecard/screens/templates/titled_page.dart';
import 'package:scorecard/screens/widgets/generic_item_tile.dart';
import 'package:scorecard/screens/widgets/item_list.dart';
import 'package:scorecard/screens/widgets/separated_widgets.dart';
import 'package:scorecard/services/cricket_match_service.dart';
import 'package:scorecard/util/elements.dart';
import 'package:scorecard/util/strings.dart';
import 'package:scorecard/util/utils.dart';

class MatchInitScreen extends StatelessWidget {
  final CricketMatch match;
  MatchInitScreen({Key? key, required this.match}) : super(key: key);

  final teamSquadController = SelectableItemController<TeamSquad>(maxItems: 1);
  final tossChoiceController =
      SelectableItemController<TossChoice>(maxItems: 1);

  @override
  Widget build(BuildContext context) {
    return TitledPage(
        title: Strings.initMatchTitle,
        child: Column(
          children: [
            const SizedBox(height: 32),
            Text(
              Strings.initMatchHeadingToss,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 32),
            Expanded(
              child: SeparatedWidgetPair(
                top: const GenericItemTile(
                  leading: Icon(Icons.people),
                  primaryHint: Strings.initMatchTossTeamPrimary,
                  secondaryHint: Strings.initMatchTossTeamHint,
                  trailing: null,
                ),
                bottom: Expanded(
                  child: SelectableItemList<TeamSquad>(
                    items: [match.home, match.away],
                    controller: teamSquadController,
                    onBuild: (teamSquad) => ListTile(
                      leading: Icon(Icons.people,
                          color: teamSquad.team.color.withOpacity(0.7)),
                      title: Text(teamSquad.team.name),
                      trailing: const SizedBox(),
                      onTap: () => teamSquadController.selectItem(
                          teamSquad), //TODO decide where to handle this
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onBuildSelected: (teamSquad) => ListTile(
                      selected: true,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      selectedTileColor: teamSquad.team.color.withOpacity(0.1),
                      selectedColor: teamSquad.team.color.withOpacity(1),
                      leading: Icon(Icons.people,
                          color: teamSquad.team.color.withOpacity(1)),
                      title: Text(teamSquad.team.name),
                      trailing: Icon(Icons.check_circle,
                          color: teamSquad.team.color.withOpacity(1)),
                      onTap: () => teamSquadController.selectItem(
                          teamSquad), // TODO maybe move to SelectableItemList
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
                child: SeparatedWidgetPair(
              top: const GenericItemTile(
                primaryHint: Strings.initMatchTossChoicePrimary,
                secondaryHint: Strings.initMatchTossChoiceHint,
                leading: Icon(Icons.casino),
                trailing: null,
              ),
              bottom: Expanded(
                child: SelectableItemList<TossChoice>(
                  items: TossChoice.values,
                  controller: tossChoiceController,
                  onBuild: (tossChoice) => ListTile(
                    leading: tossChoice == TossChoice.bat
                        ? const Icon(Icons.sports_cricket)
                        : const Icon(Icons.sports_gymnastics),
                    title: Text(Strings.getTossChoice(tossChoice)),
                    onTap: () => tossChoiceController.selectItem(tossChoice),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onBuildSelected: (tossChoice) => ListTile(
                    leading: tossChoice == TossChoice.bat
                        ? const Icon(Icons.sports_cricket)
                        : const Icon(Icons.sports_gymnastics),
                    title: Text(Strings.getTossChoice(tossChoice)),
                    selected: true,
                    selectedTileColor:
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    onTap: () => tossChoiceController.selectItem(tossChoice),
                    trailing: const Icon(Icons.check_circle),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            )),
            const SizedBox(height: 128),
            ListenableBuilder(
                // TODO Please solve this nested jugaad
                listenable: teamSquadController,
                builder: (context, child) => ListenableBuilder(
                    listenable: tossChoiceController,
                    builder: (context, child) => _wConfirmButton(context))),
          ],
        ));
  }

  Widget _wConfirmButton(BuildContext context) {
    return Elements.getConfirmButton(
      text: Strings.initMatchStartMatch,
      onPressed: _canCreateMatch
          ? () {
              final tossWinner = teamSquadController.selectedItems.single;
              final tossChoice = tossChoiceController.selectedItems.single;
              match.startMatch(Toss(tossWinner.team, tossChoice));
              context.read<CricketMatchService>().save(match); // TODO move
              Utils.goToReplacementPage(
                  InningsInitScreen(match: match), context);
            }
          : null,
    );
  }

  bool get _canCreateMatch =>
      teamSquadController.selectedItems.singleOrNull != null &&
      tossChoiceController.selectedItems.singleOrNull != null;
}
