import 'package:flutter/material.dart';
import 'package:scorecard/modules/cricket_match/models/cricket_match_model.dart';
import 'package:scorecard/screens/cricket_game/cricket_game_screen.dart';
import 'package:scorecard/screens/cricket_match/initialize_cricket_match_screen.dart';

class CricketMatchScreen extends StatelessWidget {
  final CricketMatch match;

  const CricketMatchScreen(this.match, {super.key});

  @override
  Widget build(BuildContext context) {
    final match = this.match;
    switch (match) {
      case CompletedCricketMatch():
        return const Placeholder();
      case OngoingCricketMatch():
      case InitializedCricketMatch():
        final controller = CricketGameScreenController(match.game);
        return CricketGameScreen(controller);
      case ScheduledCricketMatch():
        final controller = InitializeCricketMatchScreenController(match);
        return InitializeCricketMatchScreen(controller);
    }
    return Text("This should not happen");
  }
}
