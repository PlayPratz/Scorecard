import 'package:flutter/material.dart';
import 'package:scorecard/models/ball.dart';
import 'package:scorecard/models/player.dart';
import 'package:scorecard/models/wicket.dart';

class BallManager with ChangeNotifier {
  Player batter;
  Player bowler;

  BallManager({required this.batter, required this.bowler});

  int runs = 0;

  Wicket? wicket;
  BowlingExtra? bowlingExtra;
  BattingExtra? battingExtra;

  void setRuns(int runs) {
    this.runs = runs;
  }

  void setBatter(Player batter) {
    this.batter = batter;
    notifyListeners();
  }

  void setBowler(Player bowler) {
    this.bowler = bowler;
    notifyListeners();
  }

  void setWicket(Wicket? wicket) {
    this.wicket = wicket;
    notifyListeners();
  }

  void setBowlingExtra(BowlingExtra? bowlingExtra) {
    this.bowlingExtra = bowlingExtra;
    notifyListeners();
  }

  void setBattingExtra(BattingExtra? battingExtra) {
    this.battingExtra = battingExtra;
    notifyListeners();
  }

  Ball createBall() => Ball(
      bowler: bowler,
      batter: batter,
      runsScored: runs,
      battingExtra: battingExtra,
      bowlingExtra: bowlingExtra,
      wicket: wicket);

  void reset() {
    runs = 0;
    wicket = null;
    bowlingExtra = null;
    battingExtra = null;
  }
}
