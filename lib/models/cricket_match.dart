import 'package:scorecard/util/constants.dart';

import 'innings.dart';
import 'result.dart';
import 'team.dart';

class CricketMatch {
  final String id;
  final TeamSquad home;
  final TeamSquad away;
  final int maxOvers;

  final List<Innings> inningsList;

  bool _isCompleted = false;
  bool get isCompleted => _isCompleted; // TODO Duplicate of MatchState?

  bool _isHomeInningsFirst = true;
  bool get isHomeInningsFirst => _isHomeInningsFirst;

  Toss? toss;

  // In case of super over
  // CricketMatch? superOver;
  // CricketMatch? parentMatch;

  final DateTime createdAt;

  CricketMatch.load({
    required this.id,
    required this.home,
    required this.away,
    required this.maxOvers,
    required this.inningsList,
    required this.toss,
    required this.createdAt,
    // required this.superOver,
    // required this.parentMatch,
    required bool isCompleted,
    required bool isHomeInningsFirst,
  })  : _isCompleted = isCompleted,
        _isHomeInningsFirst = isHomeInningsFirst;

  CricketMatch.create({
    required this.id,
    required this.home,
    required this.away,
    required this.maxOvers,
  })  : createdAt = DateTime.timestamp(),
        inningsList = [];

  bool get isTossCompleted => toss != null;

  Innings get currentInnings => inningsList.last;

  TeamSquad get nextTeamToBat {
    if (inningsList.isEmpty) {
      if (_isHomeInningsFirst) {
        return home;
      } else {
        return away;
      }
    }
    // TODO: Fix this for unlimited overs
    return currentInnings.bowlingTeam;
  }

  TeamSquad get nextTeamToBowl =>
      nextTeamToBat.team.id == home.team.id ? away : home;

  MatchState get matchState {
    if (_isCompleted) {
      _isCompleted = false; //TODO temporary
      return MatchState.completed;
    } else if (toss == null) {
      // Toss has not completed
      return MatchState.notStarted;
    } else if (inningsList.length == 2) {
      // The second innings is being played
      return MatchState.secondInnings;
    } else if (inningsList.length == 1) {
      // The first innings is being played
      return MatchState.firstInnings;
    } else {
      // The first innings has not started
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
      return ResultTie(winner: home, loser: away);
    }
  }

  Innings? get firstInnings => inningsList.isNotEmpty ? inningsList[0] : null;
  Innings? get secondInnings => inningsList.length > 1 ? inningsList[1] : null;

  Innings? get homeInnings =>
      _isHomeInningsFirst ? firstInnings : secondInnings;
  Innings? get awayInnings =>
      _isHomeInningsFirst ? secondInnings : firstInnings;

  // bool get isSuperOver => parentMatch != null;
  // bool get hasSuperOver => superOver != null;

  void startMatch(Toss completedToss) {
    toss = completedToss;
    if ((completedToss.winningTeam == home.team &&
            completedToss.choice == TossChoice.bowl) ||
        (completedToss.winningTeam == away.team &&
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
    final battingTeam = _isHomeInningsFirst ? home : away;
    final bowlingTeam = _isHomeInningsFirst ? away : home;
    inningsList.add(
      Innings.create(
        battingTeam: battingTeam,
        bowlingTeam: bowlingTeam,
        maxOvers: maxOvers,
      ),
    );
  }

  void _startSecondInnings() {
    final battingTeam = _isHomeInningsFirst ? away : home;
    final bowlingTeam = _isHomeInningsFirst ? home : away;
    inningsList.add(
      Innings.create(
        battingTeam: battingTeam,
        bowlingTeam: bowlingTeam,
        maxOvers: maxOvers,
        target: firstInnings!.runs + 1,
      ),
    );
  }

  void _endMatch() {
    _isCompleted = true;
  }

  void startSuperOver() {
    // superOver = CricketMatch.superOver(parentMatch: this);
    // superOver!.startMatch(
    //   Toss(homeTeam, _isHomeInningsFirst ? TossChoice.bowl : TossChoice.bat),
    // ); // This ensures that the order of innings is swapped.
    throw UnimplementedError("Super over not implemented!");
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
