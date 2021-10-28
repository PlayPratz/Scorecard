import 'package:scorecard/models/ball.dart';
import 'package:scorecard/models/result.dart';
import 'package:scorecard/models/team.dart';
import 'package:scorecard/util/constants.dart';

class CricketMatch {
  Team homeTeam;
  Team awayTeam;
  int maxOvers;

  late Innings _homeInnings;
  late Innings _awayInnings;

  MatchState _matchState = MatchState.notStarted;
  bool _isHomeInningsFirst = true;

  // In case of super over
  CricketMatch? _superOver;

  Toss? toss;

  CricketMatch(
      {required this.homeTeam,
      required this.awayTeam,
      required this.maxOvers,
      maxWickets}) {
    _homeInnings = Innings(
        battingTeam: homeTeam, maxOvers: maxOvers, maxWickets: maxWickets);
    _awayInnings = Innings(
        battingTeam: awayTeam, maxOvers: maxOvers, maxWickets: maxWickets);
  }

  bool get isTossCompleted => toss != null;

  Innings get currentInnings {
    switch (_matchState) {
      case MatchState.tossCompleted:
      case MatchState.firstInnings:
        return firstInnings;
      case MatchState.completed:
      case MatchState.secondInnings:
        return secondInnings;
      default:
        // TODO Exception
        throw UnimplementedError();
    }
  }

  Innings get firstInnings => _isHomeInningsFirst ? homeInnings : awayInnings;
  Innings get secondInnings => _isHomeInningsFirst ? awayInnings : homeInnings;
  Innings get homeInnings => _homeInnings;
  Innings get awayInnings => _awayInnings;
  MatchState get matchState => _matchState;
  CricketMatch? get superOver => _superOver;

  void startMatch(Toss completedToss) {
    toss = completedToss;
    if ((completedToss.winningTeam == homeTeam &&
            completedToss.choice == TossChoice.bowl) ||
        (completedToss.winningTeam == awayTeam &&
            completedToss.choice == TossChoice.bat)) {
      _isHomeInningsFirst = false;
    }
    _matchState = MatchState.tossCompleted;
  }

  void startFirstInnings() {
    _matchState = MatchState.firstInnings;
    firstInnings.isInPlay = true;
  }

  void finishFirstInnings() {
    firstInnings._isCompleted = true;
    secondInnings.target = firstInnings.runs + 1;
    _matchState = MatchState.secondInnings;
    secondInnings.isInPlay = true;
  }

  Result generateResult() {
    if (!secondInnings.isCompleted) {
      //TODO Exception
      throw UnimplementedError();
    }
    _matchState = MatchState.completed;
    // This implies firstInnings.isCompleted is true as well
    if (secondInnings.runs < firstInnings.runs) {
      // Winning by defending
      int runsWonBy = firstInnings.runs - secondInnings.runs;
      return ResultWinByDefending(
        winner: firstInnings.battingTeam,
        loser: secondInnings.battingTeam,
        runsWonBy: runsWonBy,
      );
    } else if (firstInnings.runs < secondInnings.runs) {
      // Winning by chasing
      return ResultWinByChasing(
        winner: secondInnings.battingTeam,
        loser: firstInnings.battingTeam,
        ballsLeft: secondInnings.ballsRemaining,
        wicketsLeft: secondInnings.wicketsRemaining,
      );
    } else {
      // Match ties
      return ResultTie(homeTeam: homeTeam, awayTeam: awayTeam);
    }
  }

  void startSuperOver() {
    if (generateResult().getVictoryType() != VictoryType.tie) {
      // TODO Exception
      throw UnimplementedError();
    }
    _superOver = CricketMatch(
        homeTeam: homeTeam, awayTeam: awayTeam, maxOvers: 1, maxWickets: 2);

    _superOver?.startMatch(Toss(
        homeTeam,
        _isHomeInningsFirst
            ? TossChoice.bowl
            : TossChoice
                .bat)); // This ensures that the order of innings is swapped.
  }
}

class Innings {
  Team battingTeam;
  int? target;
  final int maxOvers;
  final int maxWickets;
  final List<Over> _overs = [];
  int _runs = 0;
  int _wickets = 0;

  bool _isInPlay = false;
  bool _isCompleted = false;

  Innings({
    required this.battingTeam,
    required this.maxOvers,
    required this.maxWickets,
  });

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
      //Exception
      return;
    }
    _overs.last.addBall(ball);

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

class Toss {
  Team winningTeam;
  TossChoice choice;

  Toss(this.winningTeam, this.choice);
}

enum TossChoice {
  bat,
  bowl,
}

enum MatchState {
  notStarted,
  tossCompleted,
  firstInnings,
  secondInnings,
  completed
}
