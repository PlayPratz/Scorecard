import 'dart:math';

import 'package:scorecard/models/player.dart';
import 'package:scorecard/models/wicket.dart';
import 'package:scorecard/util/constants.dart';

import 'ball.dart';
import 'team.dart';

class Innings {
  Team battingTeam;
  Team bowlingTeam;
  int? target;
  final int maxOvers;

  Innings({
    required this.battingTeam,
    required this.bowlingTeam,
    required this.maxOvers,
    this.target,
  });

  final List<Over> _overs = [];
  final List<_BatterInnings> _battingTeamInnings = [];
  final List<_BowlerInnings> _bowlerTeamInnings = [];

  bool _isInPlay = false;
  bool _isCompleted = false;

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
  List<_BatterInnings> get allBattingInnings => _battingTeamInnings;
  List<_BowlerInnings> get allBowlingInnings => _bowlerTeamInnings;

  _BowlerInnings get currentBowlerInnings => _bowlerTeamInnings.firstWhere(
      (bowlerInnings) => bowlerInnings.bowler == currentOver.bowler);

  _BatterInnings batterInningsOfPlayer(Player player) => _battingTeamInnings
      .lastWhere((batterInnings) => batterInnings.batter == player);

  int get ballsBowled {
    if (_overs.isEmpty) {
      return 0;
    }
    if (currentOver.isCompleted) {
      return Constants.ballsPerOver * oversCompleted;
    }
    return Constants.ballsPerOver * oversCompleted +
        currentOver.numOfBallsBowled;
  }

  List<Ball> getLastBalls(int count) {
    List<Ball> ballList = [];
    for (Over over in _overs.reversed) {
      ballList.insertAll(0, over.balls);
      if (ballList.length > count) {
        break;
      }
    }
    return ballList.sublist(ballList.length - min(count, ballList.length));
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
  bool get isInPlay => (_isInPlay || _overs.isNotEmpty) && !isCompleted;
  bool get isCompleted => _isCompleted ||
          oversCompleted == maxOvers ||
          wicketsRemaining == 0 ||
          target != null
      ? runsRequired <= 0
      : false;

  double get runRatePerOver => Constants.ballsPerOver * runs / ballsBowled;
  int get runsProjected => (maxOvers * runRatePerOver).floor();

  int get runsRequired {
    if (target == null) {
      return -1;
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

  void addBall(Ball ball) {
    if (isCompleted) {
      //TODO Exception
      throw UnimplementedError();
    }

    if (currentOver.isCompleted) {
      // Add new over
      Over newOver = Over(ball.bowler);
      addOver(newOver);
    }

    currentOver.addBall(ball);

    _battingTeamInnings.lastWhere(
      (batterInnings) => batterInnings.batter == ball.batter,
      orElse: () {
        // No such batter exists in the current BowlerInnings list.
        // Add to list
        _BatterInnings newBatter = _BatterInnings(batter: ball.batter);
        _battingTeamInnings.add(newBatter);
        return newBatter;
      },
    ).play(ball);

    if ((wicketsRemaining == 0) || // The batting team is all down
        (ballsRemaining == 0) || // All overs have been bowled
        (target != null && target! <= runs)) {
      // The batting team has chased its target
      _isCompleted = true;
    }
  }

  void undoBall() {
    if (currentOver.numOfBallsBowled == 0) {
      // Cancel this over
      _overs.removeLast();
      return;
    }
    Ball removedBall = currentOver.balls.removeLast();
    _battingTeamInnings
        .lastWhere(
            (battingInnings) => battingInnings.batter == removedBall.batter)
        ._ballsFaced
        .remove(removedBall);

    // No need to handle seperately for bowlerInnings
    // as it uses the same Over object as Innings._overs
  }

  @Deprecated("Use [addBall] instead")
  void addBatter(Player batter) {
    _battingTeamInnings.add(_BatterInnings(batter: batter));
  }

  @Deprecated("Use [addBall] instead")
  void addOver(Over over) {
    if (isCompleted || (_overs.isNotEmpty && !currentOver.isCompleted)) {
      throw UnimplementedError();
    }
    _overs.add(over);

    // Add current over to BowlerInnings
    _bowlerTeamInnings.firstWhere(
      (bowlerInnings) => bowlerInnings.bowler == over.bowler,
      orElse: () {
        // No such bowler exists in the current BowlerInnings list.
        // Add to list
        _BowlerInnings newBowlerInnings = _BowlerInnings(bowler: over.bowler);
        _bowlerTeamInnings.add(newBowlerInnings);
        return newBowlerInnings;
      },
    ).bowl(currentOver);
  }
}

class _BatterInnings {
  Player batter;
  _BatterInnings({required this.batter});

  final List<Ball> _ballsFaced = [];
  Wicket? wicket;

  int get runsScored =>
      _ballsFaced.fold(0, (runsScored, ball) => runsScored + ball.batterRuns);
  int get ballsFaced => _ballsFaced.where((ball) => ball.shouldCount).length;

  double get strikeRate => 100 * runsScored / ballsFaced;

  bool get isOut => wicket != null;

  String get score => runsScored.toString() + " in " + ballsFaced.toString();

  void play(Ball ball) {
    _ballsFaced.add(ball);
    if (ball.isWicket) {
      // TODO Do we even need this "if"?
      wicket = ball.wicket;
    }
  }
}

class _BowlerInnings {
  Player bowler;
  _BowlerInnings({required this.bowler});

  final List<Over> _overs = [];

  int get runsConceded =>
      _overs.fold(0, (runsConceded, over) => runsConceded + over.totalRuns);

  int get wicketsTaken =>
      _overs.fold(0, (wicketsTaken, over) => wicketsTaken + over.bowlerWickets);

  int get maidensBowled => _overs.where((over) => over.totalRuns == 0).length;

  int get ballsBowled =>
      _overs.fold(0, (ballsBowled, over) => ballsBowled + over.numOfLegalBalls);

  String get oversBowled {
    int balls = ballsBowled;
    return (balls ~/ 6).toString() + '.' + (balls % 6).toString();
  }

  double get economy => Constants.ballsPerOver * runsConceded / ballsBowled;

  String get score =>
      wicketsTaken.toString() +
      '-' +
      runsConceded.toString() +
      " in " +
      oversBowled;

  void bowl(Over over) {
    _overs.add(over);
  }
}
