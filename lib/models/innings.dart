import 'dart:collection';
import 'dart:math';

import 'package:scorecard/models/statistics.dart';
import 'package:scorecard/models/wicket.dart';

import 'player.dart';
import '../util/constants.dart';

import 'ball.dart';
import 'team.dart';

class Innings {
  final Team battingTeam;
  final Team bowlingTeam;

  int? target;
  final int maxOvers;

  Innings({
    required this.battingTeam,
    required this.bowlingTeam,
    required this.maxOvers,
    // this.bowlerInnings = const [],
  }) : target = null;

  Innings.target({
    required this.battingTeam,
    required this.bowlingTeam,
    required this.target,
    required this.maxOvers,
    // this.bowlerInnings = const [],
  });

  final List<Ball> _balls = [];
  UnmodifiableListView<Ball> get balls => UnmodifiableListView(_balls);

  void initialize(
      {required Player batter1,
      required Player? batter2,
      required Player bowler}) {
    final bowlerInnings = BowlerInnings(bowler, innings: this);
    _bowlerInnings[bowler] = bowlerInnings;

    final batterInnings1 = BatterInnings(batter1, innings: this);
    _batterInnings[batter1] =
        batterInnings1; //TODO Remove duplicate code from [addBatter]

    playersInAction = PlayersInAction(
        batter1: batterInnings1,
        striker: batterInnings1,
        bowler: bowlerInnings);

    if (batter2 != null) {
      final batterInnings2 = BatterInnings(batter2, innings: this);
      _batterInnings[batter2] = batterInnings1;
      playersInAction.batter2 = batterInnings2;
    }
  }

  // OPERATIONS

  /// Add the given [ball] to the proceedings of this innings.
  ///
  /// This function serves as an entry point
  void play(Ball ball) {
    _balls.add(ball);
    if (!_bowlerInnings.containsKey(ball.bowler)) {
      throw StateError("Ball delivered by unregistered bowler");
    }
    if (!_batterInnings.containsKey(ball.batter)) {
      throw StateError("Ball faced by unregistered batter");
    }
    _bowlerInnings[ball.bowler]!.deliver(ball);
    _batterInnings[ball.batter]!.face(ball);
  }

  /// Remove the given [ball] from this innings.
  ///
  /// The parameter [ball] is pretty useless as of now, it's added as a means of
  /// forwards compatibility. For now, only removing the last ball is supported.
  void unPlay(Ball ball) {
    if (_balls.isEmpty) {
      return;
    }
    if (_balls.last != ball) {
      throw StateError("Attempted to remove ball other than last ball");
    }
    _balls.removeLast();

    if (!_bowlerInnings.containsKey(ball.bowler)) {
      throw StateError("Ball delivered by unregistered bowler");
    }
    if (!_batterInnings.containsKey(ball.batter)) {
      throw StateError("Ball faced by unregistered batter");
    }

    _bowlerInnings[ball.bowler]!.unDeliver(ball);
    _batterInnings[ball.batter]!.unFace(ball);
  }

  bool get isInitialized => _batterInnings.isNotEmpty;
  // && bowlerInnings.isNotEmpty; TODO

  // Score

  int get runs => balls.fold(0, (runs, ball) => runs + ball.totalRuns);
  int get wickets => balls.where((ball) => ball.isWicket).length;
  int get ballsBowled => balls.where((ball) => ball.isLegal).length;
  bool get areOversCompleted =>
      maxOvers * Constants.ballsPerOver == ballsBowled;

  // Calculations

  double get currentRunRate =>
      ballsBowled == 0 ? 0 : (runs / ballsBowled) * Constants.ballsPerOver;
  int get projectedRuns => (currentRunRate * maxOvers).floor();
  int get requiredRuns => target != null ? max(0, (target! - runs)) : 0;
  int get ballsLeft => maxOvers * Constants.ballsPerOver - ballsBowled;
  double get requiredRunRate =>
      target != null ? (requiredRuns / ballsLeft) * Constants.ballsPerOver : 0;

  // Fall of Wickets
  UnmodifiableListView<FallOfWicket> get fallOfWickets =>
      UnmodifiableListView(balls
          .where((ball) => ball.isWicket)
          .map((ball) => FallOfWicket(ball: ball, outBatter: ball.batter)));

  // Players In Action
  late final PlayersInAction playersInAction;

  // Bowler

  final Map<Player, BowlerInnings> _bowlerInnings = {};
  List<BowlerInnings> get bowlerInningsList => _bowlerInnings.values.toList();

  // BowlerInnings addBowler(Player bowler) {
  //   final bowlInn = BowlerInnings(bowler, innings: this);
  //   _bowlerInnings[bowler] = bowlInn; //TODO Check containsKey?
  //   return bowlInn;
  // }

  BowlerInnings setBowler(Player bowler) {
    // Check if bowler is not already registered
    if (!_bowlerInnings.containsKey(bowler)) {
      // Add bowler to bowlerInnings
      final bowlInn = BowlerInnings(bowler, innings: this);
      _bowlerInnings[bowler] = bowlInn;
    }

    // Set bowler as the current bowler
    playersInAction.bowler = _bowlerInnings[bowler];

    return _bowlerInnings[bowler]!;
  }

  BowlerInnings? getBowlerInnings(Player bowler) {
    return _bowlerInnings[bowler];
  }

  void removeBowler(BowlerInnings bowlInn) {
    _bowlerInnings.remove(bowlInn);
  }

  // Batter

  final Map<Player, BatterInnings> _batterInnings = {};
  List<BatterInnings> get batterInningsList => _batterInnings.values.toList();

  BatterInnings addBatter(Player batter, BatterInnings outBatter) {
    final inBatter = BatterInnings(batter, innings: this);
    _batterInnings[batter] = inBatter; //TODO check containsKey?

    // Add to PlayersInAction
    // if (batterToReplace == playersInAction.batter2) {
    //   playersInAction.batter2 = inBatter;
    // } else {
    //   playersInAction.batter1 = inBatter;
    // }

    if (outBatter == playersInAction.batter2) {
      playersInAction.batter2 = inBatter;
    } else {
      playersInAction.batter1 = inBatter;
    }
    if (playersInAction.striker != playersInAction.batter1 &&
        playersInAction.striker != playersInAction.batter2) {
      playersInAction.striker = inBatter;
    }

    return inBatter;
  }

  BatterInnings? getBatterInnings(Player batter) {
    return _batterInnings[batter];
  }

  void removeBatter(BatterInnings batInn) {
    _batterInnings.remove(batInn);
  }

  void setStrike(BatterInnings batter) {
    if (batter != playersInAction.batter1 &&
        batter != playersInAction.batter2) {
      throw StateError(
          "Attempted to set strike to batter who is not in PlayersInAction");
    }
    playersInAction.striker = batter;
  }
}

class BatterInnings extends BattingStats {
  Innings innings;
  BatterInnings(super.batter, {required this.innings});
  Wicket? wicket;

  @override
  List<Ball> get balls =>
      innings.balls.where((ball) => ball.batter == batter).toList();

  bool get isOut => wicket != null;

  bool get isRetired =>
      wicket != null && wicket!.dismissal == Dismissal.retired;

  // bool isRetired = false;
  // bool get isPlaying => !isOut && !isRetired;

  void face(Ball ball) {
    if (ball.isWicket && ball.wicket!.batter == batter) {
      wicket = ball.wicket;
    }
  }

  void unFace(Ball ball) {
    if (ball.isWicket && ball.wicket!.batter == batter) {
      wicket = null;
    }
  }

  void retire() {
    wicket = Wicket.retired(batter: batter);
  }
}

class BowlerInnings extends BowlingStats {
  Innings innings;

  BowlerInnings(super.bowler, {required this.innings});

  @override
  List<Ball> get balls =>
      innings.balls.where((ball) => ball.bowler == bowler).toList();

  void deliver(Ball ball) {
    // Added for uniformity
  }

  void unDeliver(Ball ball) {
    // Added for uniformity
  }
}

class FallOfWicket {
  Ball ball;
  // BatterInnings inBatter;
  // BatterInnings outBatter;
  Player outBatter;

  FallOfWicket(
      {required this.ball,
      // required this.inBatter,
      required this.outBatter});
}

/// The [Player]s that are currently on pitch
///
/// It's a handy class to represent the two batters and a bowler
class PlayersInAction {
  BatterInnings? batter1;
  BatterInnings? batter2;
  BatterInnings? striker;

  BowlerInnings? bowler;

  PlayersInAction(
      {required this.batter1,
      this.batter2,
      required this.striker,
      required this.bowler});
}
