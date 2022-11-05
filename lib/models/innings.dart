import 'package:scorecard/util/strings.dart';

import 'player.dart';
import 'wicket.dart';
import '../util/constants.dart';

import 'ball.dart';
import 'team.dart';

class Innings {
  final Team battingTeam;
  final Team bowlingTeam;
  final int maxOvers;
  int? target;

  bool _isInPlay = false;
  bool isAbandoned = false;

  Innings({
    required this.battingTeam,
    required this.bowlingTeam,
    required this.maxOvers,
    this.target,
  });

  // Stuff that is populated as this innings progresses
  final List<Over> _overs = [];
  final List<BatterInnings> _battingTeamInnings = [];
  final Map<Player, BowlerInnings> _bowlerTeamInnings = {};

  // Getters and setters

  int get maxWickets => battingTeam.squadSize;

  int get runs => _overs.fold(0, (runs, over) => runs + over.totalRuns);
  int get wickets =>
      _overs.fold(0, (wickets, over) => wickets + over.totalWickets);

  int get wicketsRemaining => maxWickets - wickets;

  int get oversCompleted {
    if (_overs.isEmpty) {
      return 0;
    }
    int bowledOvers = _overs.length;
    if (!currentOver.isCompleted) {
      bowledOvers--;
    }
    return bowledOvers;
  }

  Over get currentOver => _overs.last;
  List<BatterInnings> get onPitchBatters => _allOnPitchBatters.take(2).toList();
  Iterable<BatterInnings> get _allOnPitchBatters =>
      _battingTeamInnings.where((battingInnings) => !battingInnings.isOut);
  List<BatterInnings> get allBattingInnings => _battingTeamInnings;
  List<BowlerInnings> get allBowlingInnings =>
      _bowlerTeamInnings.values.toList();

  BowlerInnings get currentBowlerInnings =>
      _bowlerTeamInnings[currentOver.bowler]!;

  // BatterInnings batterInningsOfPlayer(Player player) => _battingTeamInnings
  //     .lastWhere((batterInnings) => batterInnings.batter == player);

  int get ballsBowled {
    if (_overs.isEmpty) {
      return 0;
    }
    if (currentOver.isCompleted) {
      return Constants.ballsPerOver * oversCompleted;
    }
    return Constants.ballsPerOver * oversCompleted +
        currentOver.numOfLegalBalls;
  }

  List<Ball> get allBalls {
    List<Ball> ballList = [];
    for (Over over in _overs) {
      ballList.addAll(over.balls);
    }
    return ballList;
  }

  int get ballsRemaining => Constants.ballsPerOver * maxOvers - ballsBowled;

  String get oversBowled {
    if (_overs.isEmpty) {
      return "0.0";
    }
    String numOfBallsLeft =
        currentOver.isCompleted ? "0" : currentOver.numOfLegalBalls.toString();
    return oversCompleted.toString() + "." + numOfBallsLeft;
  }

  set isInPlay(bool isInPlay) => _isInPlay = isInPlay;
  bool get hasStarted => isInPlay || isCompleted;
  bool get isInPlay => (_isInPlay || _overs.isNotEmpty) && !isCompleted;
  bool get isCompleted =>
      isAbandoned ||
      oversCompleted == maxOvers ||
      // wicketsRemaining == 0 ||
      (target != null && runsRequired <= 0);

  double get runRatePerOver => Constants.ballsPerOver * runs / ballsBowled;
  int get runsProjected => (maxOvers * runRatePerOver).floor();

  int get runsRequired {
    if (target == null) {
      throw UnimplementedError();
    }
    return target! - runs;
  }

  double get runRateRequired {
    if (target == null) {
      // Exception
      return -1;
    }
    return Constants.ballsPerOver * runsRequired / ballsRemaining;
  }

  // Functions
  void addBall(Ball ball) {
    // This should happen only when the Innings is loaded from storage
    // Hence, commenting. TODO check if needed
    //if (isCompleted) {
    //   throw UnimplementedError();
    // }

    if (_overs.isEmpty || currentOver.isCompleted) {
      // Add new over
      Over newOver = Over(ball.bowler);
      addOver(newOver);
    }

    currentOver.addBall(ball);

    addBatter(ball.batter);

    _battingTeamInnings
        .lastWhere((batterInnings) => batterInnings.batter == ball.batter)
        .play(ball);
    // if (
    //     // (wicketsRemaining == 0) || // The batting team is all down
    //     (ballsRemaining == 0) || // All overs have been bowled
    //         (target != null && target! <= runs)) {
    //   // The batting team has chased its target
    //   _isCompleted = true;
    // }
  }

  Ball undoBall() {
    if (_overs.isEmpty) {
      throw UnimplementedError(
          "Atttempted to remove ball when no ball has been bowled");
    }

    Ball removedBall = currentOver.balls.removeLast();
    _battingTeamInnings
        .lastWhere(
            (battingInnings) => battingInnings.batter == removedBall.batter)
        .ballsFaced
        .remove(removedBall);

    if (removedBall.isWicket) {
      // Remove wicket from batter
      _battingTeamInnings
          .lastWhere((battingInnings) =>
              battingInnings.batter == removedBall.wicket!.batter)
          .wicket = null;

      // Remove batters who haven't batted yet
      Iterable<BatterInnings> onPitchBatters = _allOnPitchBatters;
      while (onPitchBatters.length > 2) {
        _battingTeamInnings.remove(onPitchBatters.last);
        onPitchBatters = _allOnPitchBatters;
      }
    }

    // No need to handle seperately for bowlerInnings
    // as it uses the same Over object as Innings._overs

    return removedBall;
  }

  @Deprecated("Use [addBall] instead")
  void addBatter(Player batter) {
    if (!_battingTeamInnings.any((batterInnings) =>
        batterInnings.batter == batter && !batterInnings.isOut)) {
      // Add only if a not-out innings of the same batter DOES NOT exist
      _battingTeamInnings.add(BatterInnings(batter: batter));
    }
  }

  @Deprecated("Use [addBall] instead")
  void addOver(Over over) {
    // This should happen only when loading from storage, hence commenting
    // TODO check if needed
    // if (isCompleted || (_overs.isNotEmpty && !currentOver.isCompleted)) {
    //   throw UnimplementedError();
    // }
    _overs.add(over);

    // Add current over to BowlerInnings
    _bowlerTeamInnings.putIfAbsent(
        over.bowler, () => BowlerInnings(bowler: over.bowler));

    _bowlerTeamInnings[over.bowler]!.bowl(over);
  }

  Over undoOver() {
    // if (currentOver.numOfBallsBowled == 0)
    // Cancel this over
    Over removedOver = _overs.removeLast();
    _bowlerTeamInnings[removedOver.bowler]?.overs.remove(removedOver);

    if (_bowlerTeamInnings[removedOver.bowler]!.overs.isEmpty) {
      _bowlerTeamInnings.remove(removedOver.bowler);
    }
    return removedOver;
  }
}

class BatterInnings {
  Player batter;
  BatterInnings({required this.batter});

  final List<Ball> ballsFaced = [];
  Wicket? wicket;

  int get runsScored =>
      ballsFaced.fold(0, (runsScored, ball) => runsScored + ball.batterRuns);
  int get numBallsFaced => ballsFaced.where((ball) => ball.shouldCount).length;

  double get strikeRate => 100 * runsScored / numBallsFaced;

  bool get isOut => wicket != null;

  String get score =>
      runsScored.toString() + Strings.scoreIn + numBallsFaced.toString();

  void play(Ball ball) {
    ballsFaced.add(ball);
    if (ball.isWicket && ball.wicket?.batter == batter) {
      wicket = ball.wicket;
    }
  }
}

class BowlerInnings {
  Player bowler;
  BowlerInnings({required this.bowler});

  final List<Over> overs = [];

  int get runsConceded =>
      overs.fold(0, (runsConceded, over) => runsConceded + over.totalRuns);

  int get wicketsTaken =>
      overs.fold(0, (wicketsTaken, over) => wicketsTaken + over.bowlerWickets);

  int get maidensBowled => overs.where((over) => over.totalRuns == 0).length;

  int get ballsBowled =>
      overs.fold(0, (ballsBowled, over) => ballsBowled + over.numOfLegalBalls);

  String get oversBowled =>
      (ballsBowled ~/ 6).toString() + '.' + (ballsBowled % 6).toString();

  double get economy => ballsBowled == 0
      ? 0
      : Constants.ballsPerOver * runsConceded / ballsBowled;

  String get score =>
      wicketsTaken.toString() +
      Strings.seperatorHyphen +
      runsConceded.toString() +
      Strings.scoreIn +
      oversBowled;

  void bowl(Over over) {
    overs.add(over);
  }
}
