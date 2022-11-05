import '../util/utils.dart';
import 'innings.dart';
import 'result.dart';
import 'team.dart';

class CricketMatch {
  final String id;
  final Team homeTeam;
  final Team awayTeam;
  final int maxOvers;

  final Innings homeInnings;
  final Innings awayInnings;

  // MatchState _matchState = MatchState.notStarted;
  bool _isHomeInningsFirst = true;

  // In case of super over
  CricketMatch? superOver;
  CricketMatch? parentMatch;

  Toss? _toss;

  CricketMatch({
    required this.id,
    required this.homeTeam,
    required this.awayTeam,
    required this.maxOvers,
  })  : homeInnings = Innings(
            battingTeam: homeTeam, bowlingTeam: awayTeam, maxOvers: maxOvers),
        awayInnings = Innings(
            battingTeam: awayTeam, bowlingTeam: homeTeam, maxOvers: maxOvers);

  CricketMatch.create({
    required homeTeam,
    required awayTeam,
    required maxOvers,
  }) : this(
            id: Utils.generateUniqueId(),
            homeTeam: homeTeam,
            awayTeam: awayTeam,
            maxOvers: maxOvers);

  factory CricketMatch.superOver({required CricketMatch parentMatch}) {
    CricketMatch superOverMatch = CricketMatch(
        id: parentMatch.id + "_superover",
        homeTeam: parentMatch.homeTeam,
        awayTeam: parentMatch.awayTeam,
        maxOvers: 1);
    superOverMatch.startMatch(
        Toss(parentMatch.secondInnings.battingTeam, TossChoice.bat));
    superOverMatch.parentMatch = parentMatch;
    return superOverMatch;
  }

  CricketMatch.load({
    required this.id,
    required this.maxOvers,
    required this.homeInnings,
    required this.awayInnings,
  })  : homeTeam = homeInnings.battingTeam,
        awayTeam = awayInnings.battingTeam;

  bool get isTossCompleted => _toss != null;

  MatchState get matchState {
    if (secondInnings.isCompleted) {
      return MatchState.completed;
    } else if (secondInnings.isInPlay) {
      return MatchState.secondInnings;
    } else if (firstInnings.isCompleted) {
      return MatchState.firstInnings;
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
      case MatchState.secondInnings:
      case MatchState.completed:
        return secondInnings;
      default:
        // TODO Exception
        throw UnimplementedError("Current Innings requested before Toss");
    }
  }

  Result get result {
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
      return ResultTie();
    }
  }

  Toss? get toss => _toss;
  Innings get firstInnings => _isHomeInningsFirst ? homeInnings : awayInnings;
  Innings get secondInnings => _isHomeInningsFirst ? awayInnings : homeInnings;

  bool get isSuperOver => parentMatch != null;
  bool get hasSuperOver => superOver != null;

  void startMatch(Toss completedToss) {
    _toss = completedToss;
    if ((completedToss.winningTeam == homeTeam &&
            completedToss.choice == TossChoice.bowl) ||
        (completedToss.winningTeam == awayTeam &&
            completedToss.choice == TossChoice.bat)) {
      _isHomeInningsFirst = false;
    }
  }

  void startFirstInnings() {
    firstInnings.isInPlay = true;
  }

  void startSecondInnings() {
    if (!firstInnings.isCompleted) {
      firstInnings.isAbandoned = true;
    }
    secondInnings.target = firstInnings.runs + 1;
    secondInnings.isInPlay = true;
  }

  void endSecondInnings() {
    if (!secondInnings.isCompleted) {
      secondInnings.isAbandoned = true;
    }
  }

  void startSuperOver() {
    superOver = CricketMatch.superOver(parentMatch: this);

    superOver!.startMatch(
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
