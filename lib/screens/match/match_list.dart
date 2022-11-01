import 'package:flutter/material.dart';
import 'package:scorecard/models/cricketmatch.dart';
import 'package:scorecard/screens/match/innings_init.dart';
import 'package:scorecard/screens/match/match_init.dart';
import 'package:scorecard/screens/match/match_screen.dart';
import 'package:scorecard/screens/match/scorecard.dart';
import 'create_match.dart';
import '../templates/item_list.dart';
import 'match_tile.dart';
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
