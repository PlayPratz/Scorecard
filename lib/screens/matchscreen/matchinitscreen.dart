import 'package:flutter/material.dart';
import '../../models/cricketmatch.dart';
import '../../models/team.dart';
import 'inningsinitscreen.dart';
import '../teamlist.dart';
import '../titledpage.dart';
import '../widgets/genericitem.dart';
import '../widgets/itemlist.dart';
import '../widgets/teamdummytile.dart';
import '../widgets/teamtile.dart';
import '../../styles/strings.dart';
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
            Text(Strings.initMatchHeadingToss),
            _wTossWinningTeam(),
            _wWinningTeamChoice(),
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
      return GenericItem(
        primaryHint: Strings.initMatchTossChoicePrimary,
        secondaryHint: Strings.initMatchTossChoiceHint,
        leading: Icon(Icons.casino),
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

  Widget _wTossChoiceInner(TossChoice tossChoice, Function onSelect) {
    return GenericItem(
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
              Utils.goToPage(InningsInitScreen(match: widget.match), context);
            }
          : null,
    );
  }

  bool get _canCreateMatch => _tossChoice != null && _tossWinner != null;
}
