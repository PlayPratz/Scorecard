import 'package:flutter/material.dart';
import 'package:scorecard/models/cricketmatch.dart';
import 'package:scorecard/screens/matchscreen/inningsinitscreen.dart';
import 'package:scorecard/screens/matchscreen/matchinitscreen.dart';
import 'package:scorecard/screens/matchscreen/matchscreen.dart';
import 'package:scorecard/screens/matchscreen/scorecard.dart';
import 'creatematch.dart';
import 'widgets/itemlist.dart';
import 'widgets/matchtile.dart';
import '../styles/strings.dart';
import '../util/utils.dart';

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
        .map((match) => MatchTile(
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
            ))
        .toList();
  }
}
