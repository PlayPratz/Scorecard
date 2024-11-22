import 'package:scorecard/modules/cricket_match/models/cricket_match_model.dart';
import 'package:scorecard/modules/cricket_match/models/innings_model.dart';
import 'package:scorecard/modules/team/models/team_model.dart';

class CricketGameService {
  void nextInnings(
    CricketGame game, {
    required Lineup battingLineup,
    required Lineup bowlingLineup,
  }) {
    final Innings innings = switch (game) {
      LimitedOversGame() => LimitedOversInnings(
          rules: game.rules,
          battingLineup: battingLineup,
          bowlingLineup: bowlingLineup,
        ),
      UnlimitedOversGame() => UnlimitedOversInnings(
          rules: game.rules,
          battingLineup: battingLineup,
          bowlingLineup: bowlingLineup,
        ),
    };
    game.innings.add(innings);
  }
}
