import 'package:flutter/material.dart';
import 'package:scorecard/models/cricketmatch.dart';
import 'package:scorecard/screens/match/inningsinitscreen.dart';
import 'package:scorecard/screens/match/matchinitscreen.dart';
import 'package:scorecard/screens/match/matchscreen.dart';
import 'package:scorecard/screens/match/scorecard.dart';
import 'creatematch.dart';
import '../templates/itemlist.dart';
import 'matchtile.dart';
import '../../util/strings.dart';
import '../../util/utils.dart';

class MatchList extends StatelessWidget {
  MatchList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ItemList(
        itemList: getMatchList(context),
        createItem: CreateItemEntry(
          page: const CreateMatchForm(),
          string: Strings.matchlistCreateNewMatch,
        ));
  }

  List<Widget> getMatchList(BuildContext context) {
    return Utils.getAllMatches()
        .map((match) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: MatchTile(
                match: match,
                onSelectMatch: (match) {
                  switch (match.matchState) {
                    case MatchState.notStarted:
                      Utils.goToPage(MatchInitScreen(match: match), context);
                      return;
                    case MatchState.tossCompleted:
                      Utils.goToPage(InningsInitScreen(match: match), context);
                      return;
                    case MatchState.completed:
                      Utils.goToPage(Scorecard(match: match), context);
                      return;
                    default:
                      Utils.goToPage(MatchScreen(match: match), context);
                  }
                },
              ),
            ))
        .toList();
  }
}
