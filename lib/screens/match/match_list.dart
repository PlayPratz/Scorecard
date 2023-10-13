import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scorecard/models/cricket_match.dart';
import 'package:scorecard/screens/match/innings_init.dart';
import 'package:scorecard/screens/match/match_init.dart';
import 'package:scorecard/screens/match/innings_play_screen/match_interface.dart';
import 'package:scorecard/screens/match/scorecard.dart';
import 'package:scorecard/screens/templates/titled_page.dart';
import 'package:scorecard/screens/widgets/common_builders.dart';
import 'package:scorecard/screens/widgets/generic_item_tile.dart';
import 'package:scorecard/services/cricket_match_service.dart';
import 'package:scorecard/styles/color_styles.dart';
import 'package:scorecard/screens/match/create_match.dart';
import 'package:scorecard/screens/widgets/item_list.dart';
import 'package:scorecard/screens/match/match_tile.dart';
import 'package:scorecard/util/strings.dart';
import 'package:scorecard/util/utils.dart';

void handleOpenMatch(BuildContext context, CricketMatch match) {
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
        handleOpenMatch(context, match);
        return;
      }
      Utils.goToPage(MatchInterface(match: match), context);
  }
}

class CricketMatchList extends StatelessWidget {
  final List<CricketMatch> cricketMatches;

  final void Function(CricketMatch cricketMatch)? onCreate;
  final void Function(CricketMatch cricketMatch) onSelect;
  final void Function(CricketMatch cricketMatch) onDelete;
  final void Function(CricketMatch cricketMatch) onRematch;

  const CricketMatchList({
    super.key,
    required this.cricketMatches,
    this.onCreate,
    required this.onSelect,
    required this.onDelete,
    required this.onRematch,
  });

  @override
  Widget build(BuildContext context) {
    return ItemList(
      itemList: [
        for (final cricketMatch in cricketMatches)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: MatchTile(
              match: cricketMatch,
              onTap: () => onSelect(cricketMatch),
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
                                onSelect: () => onRematch(cricketMatch),
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
                                onSelect: () => onDelete(cricketMatch),
                              ),
                              const SizedBox(height: 128),
                            ],
                          ),
                        ))
              },
            ),
          )
      ],
      createItem: onCreate == null
          ? null
          : CreateItemEntry<CricketMatch>(
              form: const CreateMatchForm(),
              string: Strings.matchlistCreateNewMatch,
              onCreate: onCreate!,
            ),
    );
  }
}

class OngoingCricketMatchList extends StatelessWidget {
  const OngoingCricketMatchList({super.key});

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Expanded(
            child: _FutureCricketMatchList(
                controller: _OngoingMatchListController(
                    cricketMatchService: context.read<CricketMatchService>())),
          ),
          const SizedBox(height: 12),
          GenericItemTile(
            leading: const Icon(
              Icons.task,
              color: ColorStyles.online,
            ),
            primaryHint: "Show completed matches",
            secondaryHint: Strings.empty,
            onSelect: () {
              Utils.goToPage(
                const TitledPage(
                  title: "Completed Matches",
                  child: CompletedCricketMatchList(),
                ),
                context,
              );
            },
          )
        ],
      );
}

class _OngoingMatchListController extends _CricketMatchListController {
  _OngoingMatchListController({required super.cricketMatchService});

  @override
  Future<List<CricketMatch>> get cricketMatches =>
      cricketMatchService.getOngoing();
}

class CompletedCricketMatchList extends StatelessWidget {
  const CompletedCricketMatchList({super.key});

  @override
  Widget build(BuildContext context) => _FutureCricketMatchList(
      controller: _CompletedMatchListController(
          cricketMatchService: context.read<CricketMatchService>()));
}

class _CompletedMatchListController extends _CricketMatchListController {
  _CompletedMatchListController({required super.cricketMatchService});

  @override
  Future<List<CricketMatch>> get cricketMatches =>
      cricketMatchService.getCompleted();
}

class _FutureCricketMatchList extends StatelessWidget {
  final _CricketMatchListController controller;

  const _FutureCricketMatchList({required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => SimplifiedFutureBuilder(
        future: controller.cricketMatches,
        builder: (context, cricketMatchList) => CricketMatchList(
          cricketMatches: cricketMatchList,
          // onCreate: (cricketMatch) {},
          onSelect: (cricketMatch) => handleOpenMatch(context, cricketMatch),
          onRematch: (cricketMatch) async {
            final cricketRematch = await Utils.goToReplacementPage(
              CreateMatchForm(
                home: cricketMatch.home,
                away: cricketMatch.away,
              ),
              context,
            );
            controller.save(cricketMatch);
            handleOpenMatch(context, cricketRematch);
          },
          onDelete: (cricketMatch) {
            controller.delete(cricketMatch);
            Utils.goBack(context);
          },
        ),
      ),
    );
  }
}

abstract class _CricketMatchListController with ChangeNotifier {
  final CricketMatchService cricketMatchService;

  _CricketMatchListController({required this.cricketMatchService});

  Future<List<CricketMatch>> get cricketMatches;

  Future<void> save(CricketMatch cricketMatch) async {
    await cricketMatchService.save(cricketMatch);
    notifyListeners();
  }

  Future<void> delete(CricketMatch cricketMatch) async {
    await cricketMatchService.delete(cricketMatch);
    notifyListeners();
  }
}
