import 'package:flutter/material.dart';
import 'package:scorecard/services/storage_service.dart';
import '../../models/cricket_match.dart';
import '../../models/team.dart';
import 'innings_init.dart';
import '../team/team_list.dart';
import '../templates/titled_page.dart';
import '../widgets/generic_item_tile.dart';
import '../widgets/item_list.dart';
import '../team/team_dummy_tile.dart';
import '../team/team_tile.dart';
import '../../util/strings.dart';
import '../../util/elements.dart';
import '../../util/utils.dart';

class MatchInitScreen extends StatefulWidget {
  final CricketMatch match;
  const MatchInitScreen({Key? key, required this.match}) : super(key: key);

  @override
  State<MatchInitScreen> createState() => _MatchInitScreenState();
}

class _MatchInitScreenState extends State<MatchInitScreen> {
  Team? _tossWinner;
  TossChoice? _tossChoice;

  @override
  Widget build(BuildContext context) {
    return TitledPage(
        title: Strings.initMatchTitle,
        child: Column(
          children: [
            const Spacer(),
            const Text(Strings.initMatchHeadingToss),
            const SizedBox(height: 32),
            _wTossWinningTeam(),
            const SizedBox(height: 32),
            _wWinningTeamChoice(),
            const SizedBox(height: 128),
            const Spacer(),
            _wConfirmButton(),
          ],
        ));
  }

  Widget _wTossWinningTeam() {
    return _tossWinner == null
        ? TeamDummyTile(
            primaryHint: Strings.initMatchTossTeamPrimary,
            secondaryHint: Strings.initMatchTossTeamHint,
            onSelect: _chooseTossWinner)
        : TeamTile(
            team: _tossWinner!,
            onSelect: (team) => _chooseTossWinner(),
          );
  }

  Widget _wWinningTeamChoice() {
    if (_tossChoice == null) {
      return GenericItemTile(
        primaryHint: Strings.initMatchTossChoicePrimary,
        secondaryHint: Strings.initMatchTossChoiceHint,
        leading: const Icon(Icons.casino),
        onSelect: _chooseTossChoice,
      );
    }
    return _wTossChoiceInner(_tossChoice!, _chooseTossChoice);
  }

  void _chooseTossWinner() {
    Utils.goToPage(
        TitledPage(
          title: Strings.chooseTeam,
          child: TeamList(
            teamList: [widget.match.homeTeam, widget.match.awayTeam],
            onSelectTeam: (Team selectedTeam) {
              setState(() {
                _tossWinner = selectedTeam;
              });
              Utils.goBack(context);
            },
          ),
        ),
        context);
  }

  Widget _wTossChoiceInner(TossChoice tossChoice, void Function() onSelect) {
    return GenericItemTile(
      primaryHint: Strings.getTossChoice(tossChoice),
      secondaryHint: Strings.empty,
      onSelect: onSelect,
    );
  }

  void _chooseTossChoice() {
    Utils.goToPage(
        TitledPage(
          title: Strings.initMatchTossChoiceTitle,
          child: ItemList(
              itemList: TossChoice.values
                  .map((tossChoice) => _wTossChoiceInner(
                        tossChoice,
                        () {
                          setState(() {
                            _tossChoice = tossChoice;
                          });
                          Utils.goBack(context);
                        },
                      ))
                  .toList()),
        ),
        context);
  }

  Widget _wConfirmButton() {
    return Elements.getConfirmButton(
      text: Strings.initMatchStartMatch,
      onPressed: _canCreateMatch
          ? () {
              widget.match.startMatch(Toss(_tossWinner!, _tossChoice!));
              StorageService.saveMatch(widget.match);
              Utils.goToReplacementPage(
                  InningsInitScreen(match: widget.match), context);
            }
          : null,
    );
  }

  bool get _canCreateMatch => _tossChoice != null && _tossWinner != null;
}
