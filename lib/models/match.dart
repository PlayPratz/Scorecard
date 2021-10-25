import 'package:scorecard/models/ball.dart';
import 'package:scorecard/models/team.dart';
import 'package:scorecard/util/constants.dart';

class Match {
  Team homeTeam;
  Team awayTeam;
  List<Innings> innings = [];
  int _currentInningsIndex = 0;
  Toss? toss;

  Match(this.homeTeam, this.awayTeam);

  Innings get currentInnings => innings[_currentInningsIndex];

  void startMatch(Toss completedToss, int maxOvers) {
    toss = completedToss;
    Team firstTeam;
    Team secondTeam;
    if ((completedToss.winningTeam == homeTeam &&
            completedToss.choice == TossChoice.bat) ||
        (completedToss.winningTeam == awayTeam &&
            completedToss.choice == TossChoice.bowl)) {
      firstTeam = homeTeam;
      secondTeam = awayTeam;
    } else {
      firstTeam = awayTeam;
      secondTeam = homeTeam;
    }
    innings.add(Innings(firstTeam, maxOvers));
    innings.add(Innings(secondTeam, maxOvers));
    _currentInningsIndex = 0;
  }

  void completeInnings() {
    _currentInningsIndex++;
  }
}

class Innings {
  Team battingTeam;
  List<Over> overs = [];
  int maxOvers;
  int? target;

  Innings(this.battingTeam, this.maxOvers);

  int get runs {
    int runs = 0;
    for (Over over in overs) {
      runs += over.runs;
    }
    return runs;
  }

  int get oversCompleted {
    int bowledOvers = overs.length;
    if (!overs.last.isCompleted) {
      bowledOvers--;
    }
    return bowledOvers;
  }

  int get ballsBowled =>
      Constants.ballsPerOver * oversCompleted + overs.last.numOfBallsLeft;

  int get ballsRemaining => Constants.ballsPerOver * maxOvers - ballsBowled;

  Over get currentOver => overs.last;

  bool get isCompleted => oversCompleted == maxOvers;

  double get runRatePerOver => Constants.ballsPerOver * runs / ballsBowled;

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
    return Constants.ballsPerOver * runRateRequired / ballsRemaining;
  }

  void addBall(Ball ball) {
    overs.last.addBall(ball);
  }

  void addOver(Over over) {
    if (!overs.last.isCompleted || isCompleted) {
      // Exception
      return;
    }
    overs.add(over);
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
