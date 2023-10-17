import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scorecard/models/innings.dart';
import 'package:scorecard/models/result.dart';
import 'package:scorecard/screens/match/innings_init.dart';
import 'package:scorecard/screens/match/innings_play_screen/ball_details_selector.dart';
import 'package:scorecard/screens/player/player_pickers.dart';
import 'package:scorecard/screens/match/innings_play_screen/players_in_action.dart';
import 'package:scorecard/screens/match/innings_play_screen/recent_balls.dart';
import 'package:scorecard/screens/match/innings_play_screen/run_rate_pane.dart';
import 'package:scorecard/screens/match/innings_play_screen/wicket_details_selector.dart';
import 'package:scorecard/screens/match/match_tile.dart';
import 'package:scorecard/screens/match/scorecard.dart';
import 'package:scorecard/screens/widgets/generic_item_tile.dart';
import 'package:scorecard/services/cricket_match_service.dart';
import 'package:scorecard/states/containers/innings_selection.dart';
import 'package:scorecard/states/controllers/ball_details_state.dart';
import 'package:scorecard/states/controllers/innings_state.dart';

import 'package:scorecard/models/cricket_match.dart';
import 'package:scorecard/styles/color_styles.dart';
import 'package:scorecard/screens/widgets/elements.dart';
import 'package:scorecard/util/strings.dart';
import 'package:scorecard/util/utils.dart';
import 'package:scorecard/screens/templates/titled_page.dart';

class MatchInterface extends StatelessWidget {
  final CricketMatch match;
  const MatchInterface({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    final selections = InningsSelections();
    final inningsStateController = InningsStateController(
      innings: match.currentInnings,
      selections: selections,
    );
    final ballDetailsStateController =
        BallDetailsStateController(selections: selections);

    final runRatePaneStateController = RunRatePaneStateController();
    return TitledPage(
      // backgroundColor: match.currentInnings.battingTeam.color.withOpacity(0.05),
      // toolbarHeight: 0,
      appBarColor: Colors.transparent,
      child: StreamBuilder<InningsState>(
        stream: inningsStateController.stateStream,
        initialData: inningsStateController.initialState,
        builder: (context, snapshot) {
          final inningsState = snapshot.data!;
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              MatchTile(
                match: match,
                showSummaryLine: false,
                onTap: () => Utils.goToPage(Scorecard(match: match), context),
              ),
              RunRatePane(
                stateController: runRatePaneStateController,
                innings: inningsState.innings,
                showChaseRequirement:
                    inningsState.innings == match.secondInnings,
              ),
              PlayersInActionPane(
                innings: inningsState.innings,
                isHomeTeamBatting: match.homeInnings == match.currentInnings,
                onTapBatter: (batter) =>
                    inningsStateController.setStrike(batter),
                onLongTapBatter: (batter) => _handleReplaceBatter(
                    context, inningsStateController, batter),
                onTapBowler: (bowler) =>
                    _handleSetBowler(context, inningsStateController),
              ),
              RecentBallsPane(innings: inningsState.innings),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _wEndInningsButton(context),
                  const SizedBox(width: 4),
                  Expanded(
                      child: WicketTile(
                    stateController: ballDetailsStateController,
                    innings: inningsState.innings,
                  )),
                ],
              ),
              const SizedBox(height: 8),
              BallDetailsSelector(
                stateController: ballDetailsStateController,
                innings: inningsState.innings,
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(child: _wUndoButton(inningsStateController)),
                  const SizedBox(width: 16),
                  Expanded(
                      flex: 2,
                      child: _wConfirmButton(context, inningsStateController,
                          inningsState, ballDetailsStateController))
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _wEndInningsButton(BuildContext context) => SizedBox(
        width: 100,
        height: 56,
        child: ElevatedButton.icon(
          onPressed: () => Elements.showSnackBar(context,
              text: Strings.matchScreenEndInningsLongPressToEnd),
          onLongPress: () => _endInnings(context),
          icon: const Icon(Icons.cancel),
          label: const Text(Strings.matchScreenEndInningsShort),
          style: ElevatedButton.styleFrom(
            foregroundColor: ColorStyles.remove,
            backgroundColor: ColorStyles.remove.withOpacity(0.1),
          ),
        ),
      );

  Widget _wUndoButton(InningsStateController stateController) {
    return ElevatedButton.icon(
      onPressed: match.currentInnings.balls.isNotEmpty
          ? () {
              stateController.undo();
            }
          : null,
      style: ElevatedButton.styleFrom(
        foregroundColor: ColorStyles.remove,
        backgroundColor: ColorStyles.remove.withOpacity(0.1),
      ),
      icon: const Icon(Icons.undo),
      label: const Text(Strings.matchScreenUndo),
    );
  }

  Widget _wConfirmButton(
      BuildContext context,
      InningsStateController stateController,
      InningsState inningsState,
      BallDetailsStateController ballDetailsStateController) {
    switch (inningsState) {
      case AddBallState():
        return Elements.getConfirmButton(
          text: Strings.matchScreenAddBall,
          onPressed: () {
            stateController.addBall();
            ballDetailsStateController.reset();
            //TODO Find a better place
            context.read<CricketMatchService>().save(match);
          },
        );
      case AddBatterState():
        final batterToReplace = inningsState.batterToReplace;
        return Elements.getConfirmButton(
          text: Strings.matchScreenChooseBatter,
          onPressed: () =>
              _handleAddBatter(context, stateController, batterToReplace),
        );
      case AddBowlerState():
        return Elements.getConfirmButton(
          text: Strings.matchScreenChooseBowler,
          onPressed: () => _handleSetBowler(context, stateController),
        );
      case EndInningsState():
        return Elements.getConfirmButton(
          text: Strings.matchScreenEndInnings,
          onPressed: () => _endInnings(context),
        );
    }
  }

  void _handleReplaceBatter(
      BuildContext context,
      InningsStateController stateController,
      BatterInnings batterInnings) async {
    if (batterInnings.ballsFaced > 0 || batterInnings.isOutOrRetired) {
      Elements.showSnackBar(context,
          text: Strings.matchScreenReplaceBatterError);
      return;
    }
    _handleAddBatter(context, stateController, batterInnings);
  }

  void _handleAddBatter(
      BuildContext context,
      InningsStateController stateController,
      BatterInnings batterInnings) async {
    final inBatter =
        await chooseBatter(context, match.currentInnings, batterInnings, null);
    if (inBatter == null) {
      return;
    }
    stateController.addBatter(
        inBatter: inBatter, outBatterInnings: batterInnings);
  }

  void _handleSetBowler(
      BuildContext context, InningsStateController stateController) async {
    final inBowler = await chooseBowler(context, stateController.innings);
    if (inBowler == null) {
      return;
    }
    stateController.setBowler(bowler: inBowler);
  }

  void _endInnings(BuildContext context) {
    // final inningsManager = context.read<InningsManager>();
    if (match.matchState == MatchState.secondInnings ||
        match.matchState == MatchState.completed) {
      // TODO make this such that matchState need not be checked
      match.progressMatch();
      if (match.result.victoryType == VictoryType.tie) {
        // Show Super Over option
        showModalBottomSheet(
          context: context,
          builder: (context) => Material(
            color: ColorStyles.background,
            child: Column(
              children: [
                const SizedBox(height: 32),
                const Text(
                  Strings.matchScreenMatchTied,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),
                const Text(Strings.matchScreenMatchTiedHint),
                const SizedBox(height: 32),
                GenericItemTile(
                  leading: const Icon(Icons.handshake),
                  primaryHint: Strings.matchScreenEndTiedMatch,
                  secondaryHint: Strings.matchScreenEndTiedMatchHint,
                  onSelect: () {
                    context.read<CricketMatchService>().save(match);
                    Utils.goBack(context);
                    Utils.goToReplacementPage(Scorecard(match: match), context);
                  },
                ),
                const SizedBox(height: 32),
                GenericItemTile(
                  leading: const Icon(Icons.sports_baseball),
                  primaryHint: Strings.matchScreenSuperOver,
                  secondaryHint: Strings.matchScreenSuperOverHint,
                  onSelect: () {
                    match.startSuperOver();
                    Utils.goBack(context);
                    // Utils.goToReplacementPage(
                    //     InningsInitScreen(match: match.superOver!), context);
                    //
                  },
                ),
              ],
            ),
          ),
        );
        return;
      }

      // Show Scorecard for completed Match
      Utils.goToPage(Scorecard(match: match), context);
      return;
    }
    Utils.goToPage(InningsInitScreen(match: match), context);
  }
}
