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
  int _runs = 0;
  int _wickets = 0;

  bool _isInPlay = false;
  bool _isCompleted = false;

  List<_BatterInnings> _battingTeamInnings = [];

  int get maxWickets => battingTeam.squadSize;

  int get runs => _runs;
  int get wickets => _wickets;

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
      return;
    }
    _overs.last.addBall(ball);

    _battingTeamInnings.firstWhere((batterInning) => batterInning.batter == ball.playedBy)

    _runs += ball.totalRuns;
    if (ball.isWicket) {
      _wickets++;
    }

    if ((wicketsRemaining == 0) || // The batting team is all down
        (ballsRemaining == 0) || // All overs have been bowled
        (target != null && target! <= _runs)) {
      // The batting team has chased its target
      _isCompleted = true;
    }
  }

  void addOver(Over over) {
    if (isCompleted || (_overs.isNotEmpty && !_overs.last.isCompleted)) {
      // Exception
      return;
    }
    _overs.add(over);
  }
}

class _BatterInnings {
  Player batter;
  _BatterInnings({required this.batter});

  final List<Ball> _ballsFaced = [];
  Wicket? wicket;

  int get runs =>
      _ballsFaced.fold(0, (runsScored, ball) => runsScored + ball.batterRuns);
  int get balls => _ballsFaced.where((ball) => !ball.isBowlingExtra).length;

  // int get fours => _ballsFaced.where((ball) => ball.legalRuns == 4).length;
  // int get sixes => _ballsFaced.where((ball) => ball.legalRuns == 6).length;

  void play(Ball ball) {
    _ballsFaced.add(ball);
    if (ball.isWicket) {
      // TODO Do we even need this "if"?
      wicket = ball.wicket;
    }
  }
}
