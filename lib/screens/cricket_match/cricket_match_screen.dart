import 'package:flutter/material.dart';
import 'package:scorecard/modules/cricket_match/models/cricket_match_model.dart';
import 'package:scorecard/screens/cricket_match/cricket_game_screen.dart';

class CricketMatchScreen extends StatelessWidget {
  final CricketMatch match;

  const CricketMatchScreen(this.match, {super.key});

  @override
  Widget build(BuildContext context) {
    switch (match) {
      case CompletedCricketMatch():
        return const Placeholder();
      case OngoingCricketMatch():
      case InitializedCricketMatch():
        return CricketGameScreen(game: (match as OngoingCricketMatch).game);
      case ScheduledCricketMatch():
        return _InitializeCricketMatchScreen(
            match: match as ScheduledCricketMatch);
    }

    return const Placeholder();
  }
}

class _InitializeCricketMatchScreen extends StatelessWidget {
  final ScheduledCricketMatch match;

  const _InitializeCricketMatchScreen({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        // Team 1
        // Team 2
        // FUTURE: Type of match
        // Number of overs
        // Hideable Advanced Settings
      ],
    );
  }
}
