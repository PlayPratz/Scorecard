import 'package:flutter/material.dart';
import 'package:scorecard/models/cricket_match.dart';
import 'package:scorecard/screens/match/innings_init.dart';
import 'package:scorecard/screens/match/match_init.dart';
import 'package:scorecard/screens/match/match_screen.dart';
import 'package:scorecard/screens/match/scorecard.dart';
import 'package:scorecard/screens/widgets/generic_item_tile.dart';
import 'package:scorecard/styles/color_styles.dart';
import 'package:scorecard/util/storage_utils.dart';
import 'create_match.dart';
import '../templates/item_list.dart';
import 'match_tile.dart';
import '../../util/strings.dart';
import '../../util/utils.dart';

class MatchList extends StatefulWidget {
  const MatchList({Key? key}) : super(key: key);

  @override
  State<MatchList> createState() => _MatchListState();
}

class _MatchListState extends State<MatchList> {
  @override
  Widget build(BuildContext context) {
    return ItemList(
        itemList: getMatchList(context),
        createItem: CreateItemEntry(
          page: CreateMatchForm(onCreateMatch: (match) => setState(() {})),
          string: Strings.matchlistCreateNewMatch,
        ));
  }

  List<Widget> getMatchList(BuildContext context) {
    return StorageUtils.getAllMatches()
        .reversed
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
                onLongPress: (match) => {
                  showModalBottomSheet(
                      context: context,
                      builder: (context) => Material(
                            color: ColorStyles.background,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(height: 64),
                                GenericItemTile(
                                  leading: const Icon(
                                    Icons.delete_forever,
                                    color: ColorStyles.remove,
                                  ),
                                  primaryHint: "Delete",
                                  secondaryHint:
                                      "This match will be gone forever! (That's a really long time)",
                                  onSelect: () => setState(() {
                                    StorageUtils.deleteMatch(match);
                                    Utils.goBack(context);
                                  }),
                                ),
                                const SizedBox(height: 128),
                              ],
                            ),
                          ))
                },
              ),
            ))
        .toList();
  }
}
