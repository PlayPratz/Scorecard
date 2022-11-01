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

  // MatchState _matchState = MatchState.notStarted;
  bool _isHomeInningsFirst = true;

  // In case of super over
  CricketMatch? _superOver;
  CricketMatch? _parentMatch;

  Toss? _toss;

  CricketMatch(
      {required this.id,
      required this.homeTeam,
      required this.awayTeam,
      required this.maxOvers})
      : _homeInnings = Innings(
            battingTeam: homeTeam, bowlingTeam: awayTeam, maxOvers: maxOvers),
        _awayInnings = Innings(
            battingTeam: awayTeam, bowlingTeam: homeTeam, maxOvers: maxOvers);

  CricketMatch.create({required homeTeam, required awayTeam, required maxOvers})
      : this(
            id: Utils.generateUniqueId(),
            homeTeam: homeTeam,
            awayTeam: awayTeam,
            maxOvers: maxOvers);

  factory CricketMatch.superOver({required CricketMatch match}) {
    CricketMatch superOverMatch = CricketMatch.create(
        homeTeam: match.homeTeam, awayTeam: match.awayTeam, maxOvers: 1);
    superOverMatch
        .startMatch(Toss(match.secondInnings.battingTeam, TossChoice.bat));
    superOverMatch._parentMatch = match;
    return superOverMatch;
  }

  bool get isTossCompleted => _toss != null;

  MatchState get matchState {
    if (secondInnings.isCompleted) {
      return MatchState.completed;
    } else if (secondInnings.isInPlay) {
      return MatchState.secondInnings;
    } else if (firstInnings.isCompleted) {
      return MatchState.secondInnings;
    } else if (firstInnings.isInPlay) {
      return MatchState.firstInnings;
    } else if (isTossCompleted) {
      return MatchState.tossCompleted;
    } else {
      return MatchState.notStarted;
    }
  }

  Innings get currentInnings {
    switch (matchState) {
      case MatchState.tossCompleted:
      case MatchState.firstInnings:
        return firstInnings;
      case MatchState.completed:
      case MatchState.secondInnings:
        return secondInnings;
      default:
        // TODO Exception
        throw UnimplementedError("Current Innings requested before Toss");
    }
  }

  Result? get result {
    if (!secondInnings.isCompleted) {
      //TODO Exception
      // throw UnimplementedError("Result generated before completion of match");
      return null;
    }
    // This implies firstInnings.isCompleted is true as well
    // _matchState = MatchState.completed;

    if (firstInnings.runs > secondInnings.runs) {
      // Won by defending
      int runsWonBy = firstInnings.runs - secondInnings.runs;
      return ResultWinByDefending(
        winner: firstInnings.battingTeam,
        loser: secondInnings.battingTeam,
        runsWonBy: runsWonBy,
      );
    } else if (firstInnings.runs < secondInnings.runs) {
      // Won by chasing
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

  Toss? get toss => _toss;
  Innings get firstInnings => _isHomeInningsFirst ? homeInnings : awayInnings;
  Innings get secondInnings => _isHomeInningsFirst ? awayInnings : homeInnings;
  Innings get homeInnings => _homeInnings;
  Innings get awayInnings => _awayInnings;

  bool get isSuperOver => _superOver != null;
  CricketMatch? get superOver => _superOver;
  CricketMatch? get parentMatch => _parentMatch;

  void startMatch(Toss completedToss) {
    _toss = completedToss;
    if ((completedToss.winningTeam == homeTeam &&
            completedToss.choice == TossChoice.bowl) ||
        (completedToss.winningTeam == awayTeam &&
            completedToss.choice == TossChoice.bat)) {
      _isHomeInningsFirst = false;
    }
    // _matchState = MatchState.tossCompleted;
  }

  void startFirstInnings() {
    // _matchState = MatchState.firstInnings;
    firstInnings.isInPlay = true;
  }

  void startSecondInnings() {
    // firstInnings.isCompleted = true;
    secondInnings.target = firstInnings.runs + 1;
    // _matchState = MatchState.secondInnings;
    secondInnings.isInPlay = true;
  }

  void startSuperOver() {
    if (result?.getVictoryType() != VictoryType.tie) {
      // TODO Exception
      throw UnimplementedError("Super Over initiated without tie");
    }
    _superOver = CricketMatch.superOver(match: this);

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
