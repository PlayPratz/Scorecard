import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scorecard/models/cricket_match.dart';
import 'package:scorecard/screens/match/innings_init.dart';
import 'package:scorecard/screens/match/match_init.dart';
import 'package:scorecard/screens/match/innings_play_screen/match_interface.dart';
import 'package:scorecard/screens/match/scorecard.dart';
import 'package:scorecard/screens/widgets/common_builders.dart';
import 'package:scorecard/screens/widgets/generic_item_tile.dart';
import 'package:scorecard/services/data/cricket_match_service.dart';
import 'package:scorecard/styles/color_styles.dart';
import 'package:scorecard/screens/match/create_match.dart';
import 'package:scorecard/screens/widgets/item_list.dart';
import 'package:scorecard/screens/match/match_tile.dart';
import 'package:scorecard/util/strings.dart';
import 'package:scorecard/util/utils.dart';

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
    default:
      if (match.currentInnings.balls.isEmpty) {
        match.inningsList.removeLast();
        handleOpenMatch(match, context);
        return;
      }
      Utils.goToPage(MatchInterface(match: match), context);
  }
}

class CricketMatchList extends StatelessWidget {
  final List<CricketMatch> cricketMatches;
  final bool showCreateMatch;

  const CricketMatchList(
      {super.key, required this.cricketMatches, required this.showCreateMatch});

  @override
  Widget build(BuildContext context) {
    return ItemList(
      itemList: [
        for (final cricketMatch in cricketMatches)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: MatchTile(
              match: cricketMatch,
              onTap: () => handleOpenMatch(cricketMatch, context),
              onLongPress: () => {
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
                                primaryHint: Strings.matchListRematch,
                                secondaryHint:
                                    Strings.matchListRematchDescription,
                                onSelect: () => Utils.goToReplacementPage(
                                  CreateMatchForm(
                                    home: cricketMatch.home,
                                    away: cricketMatch.away,
                                  ),
                                  context,
                                ),
                              ),
                              const SizedBox(height: 24),
                              GenericItemTile(
                                leading: const Icon(
                                  Icons.delete_forever,
                                  color: ColorStyles.remove,
                                ),
                                primaryHint: Strings.matchListDelete,
                                secondaryHint:
                                    Strings.matchListDeleteDescription,
                                onSelect: () async {
                                  await context
                                      .read<CricketMatchService>()
                                      .delete(cricketMatch);
                                  Utils.goBack(context);
                                },
                              ),
                              const SizedBox(height: 128),
                            ],
                          ),
                        ))
              },
            ),
          )
      ],
      createItem: showCreateMatch
          ? CreateItemEntry(
              page: CreateMatchForm(
                onCreateMatch: (match) => {
                  // TODO
                  throw UnimplementedError("Bhai create match ka sort kar!")
                },
              ),
              string: Strings.matchlistCreateNewMatch,
            )
          : null,
    );
  }
}

class OngoingCricketMatches extends StatelessWidget {
  const OngoingCricketMatches({super.key});

  @override
  Widget build(BuildContext context) {
    final ongoingCricketMatchesFuture =
        context.read<CricketMatchService>().getOngoingCricketMatches();
    return SimplifiedFutureBuilder(
        future: ongoingCricketMatchesFuture,
        builder: (context, ongoingCricketMatches) => CricketMatchList(
              cricketMatches: ongoingCricketMatches,
              showCreateMatch: false,
            ));
  }
}

class CompletedCricketMatches extends StatelessWidget {
  const CompletedCricketMatches({super.key});

  @override
  Widget build(BuildContext context) {
    final completedCricketMatchesFuture =
        context.read<CricketMatchService>().getCompletedCricketMatches();
    return SimplifiedFutureBuilder(
        future: completedCricketMatchesFuture,
        builder: (context, completedCricketMatches) => CricketMatchList(
              cricketMatches: completedCricketMatches,
              showCreateMatch: false,
            ));
  }
}
