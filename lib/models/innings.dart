import 'dart:collection';
import 'dart:math';

import 'package:scorecard/models/ball.dart';
import 'package:scorecard/models/player.dart';
import 'package:scorecard/models/statistics.dart';
import 'package:scorecard/models/team.dart';
import 'package:scorecard/models/wicket.dart';
import 'package:scorecard/util/constants.dart';

class Innings {
  final TeamSquad battingTeam;
  final TeamSquad bowlingTeam;

  int? target;
  final int maxOvers;

  Innings.load({
    required this.battingTeam,
    required this.bowlingTeam,
    required this.maxOvers,
    required this.target,
    required List<Ball> balls,
    required List<Player> batters,
    required List<Player> bowlers,
    // Players in Action
    required Player batter1,
    required Player? batter2,
    required Player striker,
    required Player bowler,
  }) {
    for (final batter in batters) {
      _addBatterToBatterInnings(batter);
    }

    for (final bowler in bowlers) {
      _addBowlerToBowlerInnings(bowler);
    }

    for (final ball in balls) {
      play(ball);
    }

    playersInAction = PlayersInAction(
      batter1: _batterInnings[batter1]!,
      batter2: batter2 == null ? null : _batterInnings[batter2],
      striker: _batterInnings[striker]!,
      bowler: _bowlerInnings[bowler]!,
    );
  }

  Innings.create({
    required this.battingTeam,
    required this.bowlingTeam,
    required this.maxOvers,
    this.target,
  });

  final List<Ball> _balls = [];
  UnmodifiableListView<Ball> get balls => UnmodifiableListView(_balls);

  final List<Over> _overs = [];
  UnmodifiableListView<Over> get overs => UnmodifiableListView(_overs);

  void initialize({
    required Player batter1,
    required Player? batter2,
    required Player bowler,
  }) {
    final bowlerInnings = BowlerInnings(bowler, innings: this);
    _bowlerInnings[bowler] = bowlerInnings;

    final batterInnings1 = BatterInnings(batter1, innings: this);
    _batterInnings[batter1] =
        batterInnings1; //TODO Remove duplicate code from [addBatter]

    playersInAction = PlayersInAction(
      batter1: batterInnings1,
      batter2: null,
      striker: batterInnings1,
      bowler: bowlerInnings,
    );

    if (batter2 != null) {
      final batterInnings2 = BatterInnings(batter2, innings: this);
      _batterInnings[batter2] = batterInnings2;
      playersInAction.batter2 = batterInnings2;
    }
  }

  // OPERATIONS

  /// Add the given [ball] to the proceedings of this innings.
  ///
  /// This function serves as an entry point
  void play(Ball ball) {
    if (!_bowlerInnings.containsKey(ball.bowler)) {
      throw StateError("Ball delivered by unregistered bowler");
    }
    if (!_batterInnings.containsKey(ball.batter)) {
      throw StateError("Ball faced by unregistered batter");
    }

    _balls.add(ball);

    if (_overs.isEmpty || _overs.last.isCompleted) {
      _overs.add(Over());
    }
    _overs.last.addBall(ball);

    _bowlerInnings[ball.bowler]!.deliver(ball);
    _batterInnings[ball.batter]!.face(ball);

    if (ball.isWicket) {
      _fallOfWickets.add(
        FallOfWicket(ball: ball, runsAtWicket: runs, wicketsAtWicket: wickets),
      );
      if (ball.wicket!.batter != ball.batter) {
        _batterInnings[ball.wicket!.batter]!.setWicket(ball.wicket!);
      }
    }
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

    _overs.last.removeBall(ball);
    if (overs.last.balls.isEmpty) {
      _overs.removeLast();
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
  final List<FallOfWicket> _fallOfWickets = [];
  UnmodifiableListView<FallOfWicket> get fallOfWickets =>
      UnmodifiableListView(_fallOfWickets);

  // Players In Action
  late final PlayersInAction playersInAction;

  // Bowler

  final Map<Player, BowlerInnings> _bowlerInnings = {};
  List<BowlerInnings> get bowlerInningsList => _bowlerInnings.values.toList();

  BowlerInnings setBowler(Player bowler) {
    // Check if bowler is not already registered
    if (!_bowlerInnings.containsKey(bowler)) {
      // Add bowler to bowlerInnings
      _addBowlerToBowlerInnings(bowler);
    }

    // Set bowler as the current bowler
    playersInAction.bowler = _bowlerInnings[bowler]!;

    return _bowlerInnings[bowler]!;
  }

  BowlerInnings _addBowlerToBowlerInnings(Player bowler) {
    final bowlerInn = BowlerInnings(bowler, innings: this);
    _bowlerInnings[bowler] = bowlerInn;
    return bowlerInn;
  }

  BowlerInnings? getBowlerInnings(Player bowler) {
    return _bowlerInnings[bowler];
  }

  void removeBowler(BowlerInnings bowlInn) {
    _bowlerInnings.remove(bowlInn.bowler);
  }

  // Batter

  final Map<Player, BatterInnings> _batterInnings = {};
  List<BatterInnings> get batterInningsList => _batterInnings.values.toList();

  BatterInnings addBatter(Player batter, BatterInnings outBatter) {
    final inBatter = _addBatterToBatterInnings(batter);

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

  BatterInnings _addBatterToBatterInnings(Player batter) {
    final inBatter = BatterInnings(batter, innings: this);
    _batterInnings[batter] = inBatter; //TODO check containsKey?

    return inBatter;
  }

  BatterInnings? getBatterInnings(Player batter) {
    return _batterInnings[batter];
  }

  void removeBatter(BatterInnings batInn) {
    _batterInnings.remove(batInn.batter);
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

  void setWicket(Wicket wicket) {
    this.wicket = wicket;
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

  final int runsAtWicket;
  final int wicketsAtWicket;

  Wicket get wicket => ball.wicket!;

  FallOfWicket({
    required this.ball,
    // required this.inBatter,
    required this.runsAtWicket,
    required this.wicketsAtWicket,
  });
}

/// The [Player]s that are currently on pitch
///
/// It's a handy class to represent the two batters and a bowler
class PlayersInAction {
  BatterInnings batter1;
  BatterInnings? batter2;
  BatterInnings striker;

  BowlerInnings bowler;

  PlayersInAction({
    required this.batter1,
    required this.batter2,
    required this.striker,
    required this.bowler,
  });
}
