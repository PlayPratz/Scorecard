import '../util/utils.dart';
import 'innings.dart';
import 'result.dart';
import 'team.dart';

class CricketMatch {
  final String id;
  Team homeTeam;
  Team awayTeam;
  int maxOvers;

  final Innings _homeInnings;
  final Innings _awayInnings;

  MatchState _matchState = MatchState.notStarted;
  bool _isHomeInningsFirst = true;

  // In case of super over
  CricketMatch? _superOver;

  Toss? toss;

  CricketMatch.create({required homeTeam, required awayTeam, required maxOvers})
      : this(
            id: Utils.generateUniqueId(),
            homeTeam: homeTeam,
            awayTeam: awayTeam,
            maxOvers: maxOvers);

  CricketMatch(
      {required this.id,
      required this.homeTeam,
      required this.awayTeam,
      required this.maxOvers})
      : _homeInnings = Innings(
            battingTeam: homeTeam, bowlingTeam: awayTeam, maxOvers: maxOvers),
        _awayInnings = Innings(
            battingTeam: awayTeam, bowlingTeam: homeTeam, maxOvers: maxOvers);

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

  void startSecondInnings() {
    // firstInnings.isCompleted = true;
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
    _superOver = CricketMatch.create(
      homeTeam: homeTeam,
      awayTeam: awayTeam,
      maxOvers: 1,
    );

    _superOver?.startMatch(
      Toss(homeTeam, _isHomeInningsFirst ? TossChoice.bowl : TossChoice.bat),
    ); // This ensures that the order of innings is swapped.
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
