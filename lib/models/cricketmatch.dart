import 'package:scorecard/models/ball.dart';
import 'package:scorecard/models/team.dart';
import 'package:scorecard/util/constants.dart';

class CricketMatch {
  Team homeTeam;
  Team awayTeam;
  int maxOvers;

  final List<Innings> _innings = [];
  Toss? toss;
  int _currentInningsIndex = 0;
  bool _isHomeBattingFirst = true;

  CricketMatch(this.homeTeam, this.awayTeam, this.maxOvers) {
    _innings.add(Innings(homeTeam, maxOvers));
    _innings.add(Innings(awayTeam, maxOvers));
  }

  bool get isTossCompleted => toss != null;

  Innings get currentInnings => _innings[_currentInningsIndex];
  Innings get firstInnings => _isHomeBattingFirst ? homeInnings : awayInnings;
  Innings get secondInnings => _isHomeBattingFirst ? awayInnings : homeInnings;
  Innings get homeInnings => _innings[0];
  Innings get awayInnings => _innings[1];

  // bool get isFirstInnings =>
  //     firstInnings.hasStarted && !firstInnings.isCompleted;
  // bool get isSecondInnings =>
  //     secondInnings.hasStarted && !secondInnings.isCompleted;

  void startMatch(Toss completedToss) {
    toss = completedToss;
    if ((completedToss.winningTeam == homeTeam &&
            completedToss.choice == TossChoice.bowl) ||
        (completedToss.winningTeam == awayTeam &&
            completedToss.choice == TossChoice.bat)) {
      _isHomeBattingFirst = false;
      _currentInningsIndex = 1;
    }
  }

  void finishInnings() {
    currentInnings._isCompleted = true;
    if (_isHomeBattingFirst) {
      if (_currentInningsIndex == 0) {
        _currentInningsIndex = 1;
        currentInnings.target = firstInnings.runs + 1;
      } else {
        // TODO: Match completed
      }
    } else {
      if (_currentInningsIndex == 1) {
        _currentInningsIndex = 0;
        currentInnings.target = firstInnings.runs + 1;
      } else {
        // TODO: Match completed
      }
    }
  }
}

class Innings {
  Team battingTeam;
  int? target;
  final int maxOvers;
  final List<Over> _overs = [];

  bool lastManAllowed;

  bool _isCompleted = false;

  Innings(this.battingTeam, this.maxOvers, {this.lastManAllowed = false});

  int get runs {
    int runs = 0;
    for (Over over in _overs) {
      runs += over.totalRuns;
    }
    return runs;
  }

  int get wickets {
    int wickets = 0;
    for (Over over in _overs) {
      wickets += over.wicketBalls.length;
    }
    return wickets;
  }

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
    return Constants.ballsPerOver * oversCompleted + _overs.last.numOfBallsLeft;
  }

  int get ballsRemaining => Constants.ballsPerOver * maxOvers - ballsBowled;

  String get oversBowled {
    String numOfBallsLeft =
        _overs.last.isCompleted ? "0" : _overs.last.numOfLegalBalls.toString();
    return oversCompleted.toString() + "." + numOfBallsLeft;
  }

  Over get currentOver => _overs.last;
  bool get isInPlay => _overs.isNotEmpty && !isCompleted;
  bool get isCompleted => _isCompleted || oversCompleted == maxOvers;

  double get runRatePerOver => Constants.ballsPerOver * runs / ballsBowled;
  int get runsProjected => (maxOvers * runRatePerOver).floor();

  int get runsRequired {
    if (target == null) {
      // Exception
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
      //Exception
      return;
    }
    _overs.last.addBall(ball);
  }

  void addOver(Over over) {
    if (isCompleted || (_overs.isNotEmpty && !_overs.last.isCompleted)) {
      // Exception
      return;
    }
    _overs.add(over);
  }
}

class Toss {
  Team winningTeam;
  TossChoice choice;

  Toss(this.winningTeam, this.choice);
}

enum TossChoice {
  bat,
  bowl,
}
