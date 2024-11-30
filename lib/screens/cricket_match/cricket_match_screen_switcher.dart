import 'package:flutter/material.dart';
import 'package:scorecard/modules/cricket_match/models/cricket_match_model.dart';
import 'package:scorecard/modules/cricket_match/services/cricket_match_service.dart';
import 'package:scorecard/screens/cricket_match/cricket_match_scorecard.dart';
import 'package:scorecard/screens/cricket_game/cricket_game_screen.dart';
import 'package:scorecard/screens/cricket_match/review_cricket_match_screen.dart';
import 'package:scorecard/screens/cricket_match/initialize_cricket_match_screen.dart';

class CricketMatchScreenSwitcher extends StatefulWidget {
  final CricketMatch match;

  const CricketMatchScreenSwitcher(this.match, {super.key});

  @override
  State<CricketMatchScreenSwitcher> createState() =>
      _CricketMatchScreenSwitcherState();
}

class _CricketMatchScreenSwitcherState
    extends State<CricketMatchScreenSwitcher> {
  late bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Builder(builder: (context) {
        if (_isLoading) return const Center(child: CircularProgressIndicator());
      }),
    );
  }

  void _showLoading() {
    setState(() {
      _isLoading = true;
    });
  }

  void _hideLoading() {
    setState(() {
      _isLoading = false;
    });
  }

  Future<Widget> getScreen(BuildContext context) async {
    final match = widget.match;
    switch (match) {
      case CompletedCricketMatch():
        return CricketMatchScorecard(match);
      case OngoingCricketMatch():
        final controller = CricketGameScreenController(match.game);
        return CricketGameScreen(controller);
      case InitializedCricketMatch():
        final controller = ReviewCricketGameScreenController(match);
        return ReviewCricketGameScreen(controller);
      case ScheduledCricketMatch():
        final controller = InitializeCricketMatchScreenController(match);
        return InitializeCricketMatchScreen(controller);
    }
    throw UnsupportedError(
        "Attempted to open match that was not of the defined types (id: ${match.id}");
  }

  Future<CricketGame> getGameForMatch(InitializedCricketMatch match) async {
    CricketMatchService().
  }
}
