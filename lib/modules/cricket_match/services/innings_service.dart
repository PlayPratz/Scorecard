import 'package:scorecard/modules/cricket_match/models/cricket_match_model.dart';
import 'package:scorecard/modules/cricket_match/models/innings_model.dart';
import 'package:scorecard/modules/player/player_model.dart';
import 'package:scorecard/modules/team/models/team_model.dart';

class InningsService {
  void nextInnings({
    required CricketGame game,
    required Squad battingSquad,
    required Squad bowlingSquad,
  }) {
    late final Innings innings;
    switch (game) {
      case LimitedOversGame():
        innings = LimitedOversInnings(
          rules: game.rules,
          battingSquad: battingSquad,
          bowlingSquad: bowlingSquad,
        );
      case UnlimitedOversGame():
        innings = UnlimitedOversInnings(
          rules: game.rules,
          battingSquad: battingSquad,
          bowlingSquad: bowlingSquad,
        );
    }
    game.innings.add(innings);
  }

  void initializeInnings(
    Innings innings, {
    required Player batter1,
    required Player batter2,
    required Player bowler,
  }) {
    final batterInnings1 = createBatterInnings(innings, batter1);
    final batterInnings2 = createBatterInnings(innings, batter2);
    final bowlerInnings = createBowlerInnings(innings, bowler);

    setStrike(innings, batterInnings1);
  }

  void setStrike(Innings innings, BatterInnings batter) {
    if (innings.batter1 == batter || innings.batter2 == batter) {
      innings.striker = batter;
    }
  }

  void swapStrike(Innings innings) {
    if (innings.striker == innings.batter1) {
      innings.striker = innings.batter2;
    } else {
      innings.striker = innings.batter1;
    }
  }

  /// Creates a new [BatterInnings] and adds it to the given [Innings]
  ///
  /// Call this function when a new batter walks out to bat.
  BatterInnings createBatterInnings(Innings innings, Player batter) {
    final batterInnings = BatterInnings(batter);
    innings.batters.add(batterInnings);
    return batterInnings;
  }

  /// Fetches the [BatterInnings] of the given [player]. Returns `null`
  /// if the player hasn't batted.
  BatterInnings? getBatterInningsOfPlayer(Innings innings, Player player) {
    try {
      final batterInnings = innings.batters
          .lastWhere((batterInnings) => batterInnings.batter == player);
      return batterInnings;
    } on StateError {
      return null;
    }
  }

  /// Deletes the LAST [BatterInnings] of the given [player].
  bool deleteBatterInningsOfPlayer(Innings innings, Player player) {
    final batterInnings = getBatterInningsOfPlayer(innings, player);
    if (batterInnings == null) {
      return false;
    }
    innings.batters.remove(batterInnings);
    return true;
  }

  /// Deletes the LAST [BatterInnings] from the given [innings]
  void deleteLastBatterInnings(Innings innings) {
    if (innings.batters.isNotEmpty) innings.batters.removeLast();
  }

  /// Creates a new [BowlerInnings] in the given [innings].
  ///
  /// CAll this function when a new bowler
  BowlerInnings createBowlerInnings(Innings innings, Player bowler) {
    final bowlerInnings = BowlerInnings(bowler);
    innings.bowlers.add(bowlerInnings);
    return bowlerInnings;
  }

  BowlerInnings? getBowlerInningsOfPlayer(Innings innings, Player player) {
    try {
      final bowlerInnings = innings.bowlers
          .lastWhere((bowlerInnings) => bowlerInnings.bowler == player);
      return bowlerInnings;
    } on StateError {
      return null;
    }
  }

  /// Deletes the last bowler innings of the player
  void deleteBowlerInningsOfPlayer(Innings innings, Player player) {
    final bowlerInnings = getBowlerInningsOfPlayer(innings, player);
    innings.bowlers.remove(bowlerInnings);
  }

  void deleteLastBowlerInnings(Innings innings) {
    innings.bowlers.removeLast();
  }

  void postToInnings(Innings innings, InningsPost event) {
    innings.posts.add(event);

    if (event is Ball) {
      // Swap strike for odd number of runs
      if (event.runsScored % 2 == 1) swapStrike(innings);

      // Swap strike whenever an over completes
      if (event.index.ball == innings.rules.ballsPerOver) swapStrike(innings);
    }
  }

  void undoPostFromInnings(Innings innings) {
    if (innings.posts.isNotEmpty) innings.posts.removeLast();
  }

  void forfeitInnings(Innings innings) {
    innings.isForfeited = true;
  }
}
