import 'package:flutter/material.dart';
import 'package:scorecard/models/cricketmatch.dart';
import 'package:scorecard/models/team.dart';
import 'package:scorecard/screens/teamlist.dart';
import 'package:scorecard/screens/titledpage.dart';
import 'package:scorecard/screens/widgets/genericitem.dart';
import 'package:scorecard/screens/widgets/itemlist.dart';
import 'package:scorecard/screens/widgets/teamdummytile.dart';
import 'package:scorecard/screens/widgets/teamtile.dart';
import 'package:scorecard/styles/strings.dart';
import 'package:scorecard/util/elements.dart';
import 'package:scorecard/util/utils.dart';

class TossSelector extends StatefulWidget {
  final CricketMatch match;
  final Function(Toss) onCompleteToss;

  const TossSelector({
    Key? key,
    required this.match,
    required this.onCompleteToss,
  }) : super(key: key);

  @override
  State<TossSelector> createState() => _TossSelectorState();
}

class _TossSelectorState extends State<TossSelector> {
  Team? _tossWinner;
  TossChoice? _tossChoice;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("Toss"),
        _wTossWinningTeam(),
        _wWinningTeamChoice(),
        const Spacer(),
        _wConfirmButton(),
      ],
    );
  }

  Widget _wTossWinningTeam() {
    return _tossWinner == null
        ? TeamDummyTile(
            primaryHint: "Toss Winner",
            secondaryHint: "Specify which team was luckier.",
            onSelect: _chooseTossWinner)
        : TeamTile(
            team: _tossWinner!,
            onSelect: (team) => _chooseTossWinner(),
          );
  }

  Widget _wWinningTeamChoice() {
    if (_tossChoice == null) {
      return GenericItem(
        primaryHint: "Choose to",
        secondaryHint: "Win or Lose? Oh sorry - Bat or Bowl?",
        leading: Icon(Icons.casino),
        onSelect: _chooseTossChoice,
      );
    }
    return _wTossChoiceInner(_tossChoice!, _chooseTossChoice);
  }

  void _chooseTossWinner() {
    Utils.goToPage(
        TitledPage(
          title: "Choose a Team",
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

  Widget _wTossChoiceInner(TossChoice tossChoice, Function onSelect) {
    return GenericItem(
      primaryHint: Strings.getTossChoice(tossChoice),
      secondaryHint: "",
      onSelect: onSelect,
    );
  }

  void _chooseTossChoice() {
    Utils.goToPage(
        TitledPage(
          title: "Win the toss and choose to",
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
      text: "Start Match",
      onPressed: _canCreateMatch
          ? () {
              setState(() {
                widget.onCompleteToss(Toss(_tossWinner!, _tossChoice!));
              });
            }
          : null,
    );
  }

  bool get _canCreateMatch => _tossChoice != null && _tossWinner != null;
}
