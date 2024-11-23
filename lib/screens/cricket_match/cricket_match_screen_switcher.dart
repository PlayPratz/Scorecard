import 'package:flutter/material.dart';
import 'package:scorecard/modules/cricket_match/models/cricket_match_model.dart';
import 'package:scorecard/screens/cricket_game/cricket_game_scorecard.dart';
import 'package:scorecard/screens/cricket_game/cricket_game_screen.dart';
import 'package:scorecard/screens/cricket_match/commence_cricket_match_screen.dart';
import 'package:scorecard/screens/cricket_match/initialize_cricket_match_screen.dart';

class CricketMatchScreenSwitcher extends StatelessWidget {
  final CricketMatch match;

  const CricketMatchScreenSwitcher(this.match, {super.key});

  @override
  Widget build(BuildContext context) {
    final match = this.match;
    switch (match) {
      case CompletedCricketMatch():
        return CricketGameScorecard(match.game);
      case OngoingCricketMatch():
        final controller = CricketGameScreenController(match.game);
        return CricketGameScreen(controller);
      case InitializedCricketMatch():
        final controller = CommenceCricketGameScreenController(match);
        return CommenceCricketMatchScreen(controller);
      case ScheduledCricketMatch():
        final controller = InitializeCricketMatchScreenController(match);
        return InitializeCricketMatchScreen(controller);
    }
    return const Text("Error! This should not happen.");
  }
}
