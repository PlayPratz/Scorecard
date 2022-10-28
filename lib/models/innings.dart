import 'package:scorecard/models/player.dart';
import 'package:scorecard/models/wicket.dart';
import 'package:scorecard/util/constants.dart';

import 'ball.dart';
import 'team.dart';

class Innings {
  Team battingTeam;
  int? target;
  final int maxOvers;

  Innings({
    required this.battingTeam,
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
    if (!_overs.last.isCompleted) {
      bowledOvers--;
    }
    return bowledOvers;
  }

  int get ballsBowled {
    if (_overs.isEmpty) {
      return 0;
    }
    if (_overs.last.isCompleted) {
      return Constants.ballsPerOver * oversCompleted;
    }
    return Constants.ballsPerOver * oversCompleted +
        _overs.last.numOfBallsBowled;
  }

  int get ballsRemaining => Constants.ballsPerOver * maxOvers - ballsBowled;

  String get oversBowled {
    if (_overs.isEmpty) {
      return "0.0";
    }
    String numOfBallsLeft =
        _overs.last.isCompleted ? "0" : _overs.last.numOfLegalBalls.toString();
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
      // TODO Exception
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

  void addBall(Ball ball) {
    if (isCompleted) {
      //TODO Exception
      throw UnimplementedError();
    }

    if (_overs.last.isCompleted) {
      // Add new over
      Over newOver = Over(ball.bowler);
      _overs.add(newOver);

      // Add current over to BowlerInnings
      _bowlerTeamInnings.firstWhere(
        (bowlerInnings) => bowlerInnings.bowler == ball.bowler,
        orElse: () {
          // No such bowler exists in the current BowlerInnings list.
          // Add to list
          _BowlerInnings newBowlerInnings = _BowlerInnings(bowler: ball.bowler);
          _bowlerTeamInnings.add(newBowlerInnings);
          return newBowlerInnings;
        },
      ).bowl(_overs.last);
    }

    _overs.last.addBall(ball);

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

  void addOver(Over over) {
    if (isCompleted || (_overs.isNotEmpty && !_overs.last.isCompleted)) {
      throw UnimplementedError();
    }
    _overs.add(over);
  }
}

class _BatterInnings {
  Player batter;
  _BatterInnings({required this.batter});

  final List<Ball> _ballsFaced = [];
  Wicket? wicket;

  int get runsScored =>
      _ballsFaced.fold(0, (runsScored, ball) => runsScored + ball.batterRuns);
  int get ballsFaced =>
      _ballsFaced.where((ball) => !ball.isBowlingExtra).length;

  double get strikeRate => 100 * runsScored / ballsFaced;

  bool get isOut => wicket != null;

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

  int get maidensBowled => _overs.where((over) => over.totalRuns == 0).length;

  int get ballsBowled =>
      _overs.fold(0, (ballsBowled, over) => ballsBowled + over.numOfLegalBalls);

  String get oversBowled {
    int balls = ballsBowled;
    return (balls / 6).toString() + '.' + (balls % 6).toString();
  }

  double get economy => Constants.ballsPerOver * runsConceded / ballsBowled;

  void bowl(Over over) {
    _overs.add(over);
  }
}
