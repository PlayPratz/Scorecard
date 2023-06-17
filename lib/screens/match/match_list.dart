import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scorecard/models/cricket_match.dart';
import 'package:scorecard/screens/match/innings_init.dart';
import 'package:scorecard/screens/match/match_init.dart';
import 'package:scorecard/screens/match/innings_play_screen/match_screen.dart';
import 'package:scorecard/screens/match/scorecard.dart';
import 'package:scorecard/screens/widgets/generic_item_tile.dart';
import 'package:scorecard/state_managers/innings_manager.dart';
import 'package:scorecard/styles/color_styles.dart';
import 'package:scorecard/services/storage_service.dart';
import 'create_match.dart';
import '../widgets/item_list.dart';
import 'match_tile.dart';
import '../../util/strings.dart';
import '../../util/utils.dart';

class MatchList extends StatefulWidget {
  final List<CricketMatch> matchList;
  final bool allowCreateMatch;
  const MatchList(
      {Key? key, required this.matchList, this.allowCreateMatch = false})
      : super(key: key);

  @override
  State<MatchList> createState() => _MatchListState();
}

class _MatchListState extends State<MatchList> {
  @override
  Widget build(BuildContext context) {
    return ItemList(
        itemList: getMatchList(context),
        createItem: widget.allowCreateMatch
            ? CreateItemEntry(
                page:
                    CreateMatchForm(onCreateMatch: (match) => setState(() {})),
                string: Strings.matchlistCreateNewMatch,
              )
            : null);
  }

  List<Widget> getMatchList(BuildContext context) {
    return widget.matchList.reversed
        .map((match) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: MatchTile(
                match: match,
                onSelectMatch: (match) => handleOpenMatch(match, context),
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
                                    Icons.replay,
                                    color: ColorStyles.selected,
                                  ),
                                  primaryHint: "Rematch",
                                  secondaryHint:
                                      "Quickly start a new match with the same teams",
                                  onSelect: () => setState(() {
                                    Utils.goBack(context);
                                    Utils.goToPage(
                                        CreateMatchForm(
                                          homeTeam: match.homeTeam,
                                          awayTeam: match.awayTeam,
                                        ),
                                        context);
                                  }),
                                ),
                                const SizedBox(height: 24),
                                GenericItemTile(
                                  leading: const Icon(
                                    Icons.delete_forever,
                                    color: ColorStyles.remove,
                                  ),
                                  primaryHint: "Delete",
                                  secondaryHint:
                                      "This match will be gone forever! (That's a really long time)",
                                  onSelect: () => setState(() {
                                    StorageService.deleteMatch(match);
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

void handleOpenMatch(CricketMatch match, BuildContext context) {
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
    case MatchState.secondInnings:
      if (match.secondInnings!.balls.isEmpty) {
        Utils.goToPage(InningsInitScreen(match: match), context);
        return;
      }
      continue def;
    def:
    default:
      Utils.goToPage(
          ChangeNotifierProvider<InningsManager>(
            create: (context) => InningsManager.resume(
              match.currentInnings,
            ),
            child: MatchInterface(match: match),
          ),
          context);
  }
}
