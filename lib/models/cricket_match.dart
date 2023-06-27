import 'package:scorecard/util/constants.dart';

import '../util/utils.dart';
import 'innings.dart';
import 'result.dart';
import 'team.dart';

class CricketMatch {
  final String id;
  final Team homeTeam;
  final Team awayTeam;
  final int maxOvers;

  // final Innings homeInnings;
  // final Innings awayInnings;

  final List<Innings> inningsList;
  // int inningsIndex = -1;
  bool _isCompleted = false;
  bool get isCompleted => _isCompleted;

  // MatchState _matchState = MatchState.notStarted;
  bool _isHomeInningsFirst = true;

  Team get nextTeamToBat {
    if (inningsList.isEmpty && _isHomeInningsFirst) {
      return homeTeam;
    } else if (!_isHomeInningsFirst) {
      return awayTeam;
    }
    return currentInnings.bowlingTeam;
  }

  Team get nextTeamToBowl => nextTeamToBat == homeTeam ? awayTeam : homeTeam;

  // In case of super over
  CricketMatch? superOver;
  CricketMatch? parentMatch;

  Toss? toss;

  CricketMatch({
    required this.id,
    required this.homeTeam,
    required this.awayTeam,
    required this.maxOvers,
  }) : inningsList = [];
  // : homeInnings = Innings(battingTeam: homeTeam, bowlingTeam: awayTeam),
  // awayInnings = Innings(battingTeam: awayTeam, bowlingTeam: homeTeam);

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
        Toss(parentMatch.secondInnings!.battingTeam, TossChoice.bat));
    superOverMatch.parentMatch = parentMatch;
    return superOverMatch;
  }

  CricketMatch.load({
    required this.id,
    required this.maxOvers,
    required this.homeTeam,
    required this.awayTeam,
    required this.inningsList,
    // this.inningsIndex = -1,
  });

  bool get isTossCompleted => toss != null;

  Innings get currentInnings => inningsList.last;

  MatchState get matchState {
    if (_isCompleted) {
      return MatchState.completed;
    } else if (toss == null || inningsList.isEmpty) {
      // Toss has not completed
      return MatchState.notStarted;
    } else if (inningsList.length == 2) {
      return MatchState.secondInnings;
    } else if (inningsList.length == 1) {
      return MatchState.firstInnings;
    } else {
      return MatchState.tossCompleted;
    }
  }

  Result get result {
    final firstInnings = this.firstInnings!;
    final secondInnings = this.secondInnings!;
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
        ballsLeft:
            maxOvers * Constants.ballsPerOver - secondInnings.ballsBowled,
        // wicketsLeft: secondInnings.wicketsRemaining,
      );
    } else {
      // Match ties, TODO fix jugaad
      return ResultTie(winner: homeTeam, loser: awayTeam);
    }
  }

  Innings? get firstInnings => inningsList.isNotEmpty ? inningsList[0] : null;
  // Innings get firstInnings => _isHomeInningsFirst ? homeInnings : awayInnings;
  Innings? get secondInnings => inningsList.length > 1 ? inningsList[1] : null;
  // Innings get secondInnings => _isHomeInningsFirst ? awayInnings : homeInnings;

  Innings? get homeInnings =>
      _isHomeInningsFirst ? firstInnings : secondInnings;
  Innings? get awayInnings =>
      _isHomeInningsFirst ? secondInnings : firstInnings;

  bool get isSuperOver => parentMatch != null;
  bool get hasSuperOver => superOver != null;

  void startMatch(Toss completedToss) {
    toss = completedToss;
    if ((completedToss.winningTeam == homeTeam &&
            completedToss.choice == TossChoice.bowl) ||
        (completedToss.winningTeam == awayTeam &&
            completedToss.choice == TossChoice.bat)) {
      _isHomeInningsFirst = false;
    }
    // inningsIndex = 0;
    // matchState = MatchState.tossCompleted;
  }

  void progressMatch() {
    if (inningsList.isEmpty) {
      _startFirstInnings();
    } else if (currentInnings == firstInnings) {
      _startSecondInnings();
    } else {
      _endMatch();
    }
  }

  void _startFirstInnings() {
    final battingTeam = _isHomeInningsFirst ? homeTeam : awayTeam;
    final bowlingTeam = _isHomeInningsFirst ? awayTeam : homeTeam;
    inningsList.add(
      Innings(
        battingTeam: battingTeam,
        bowlingTeam: bowlingTeam,
        maxOvers: maxOvers,
      ),
    );
  }

  void _startSecondInnings() {
    final battingTeam = _isHomeInningsFirst ? awayTeam : homeTeam;
    final bowlingTeam = _isHomeInningsFirst ? homeTeam : awayTeam;
    inningsList.add(
      Innings.target(
        battingTeam: battingTeam,
        bowlingTeam: bowlingTeam,
        target: firstInnings!.runs + 1,
        maxOvers: maxOvers,
      ),
    );
    // inningsIndex = 1;
  }

  void _endMatch() {
    // inningsIndex = 2; // TODO
    _isCompleted = true;
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
