import 'package:scorecard/models/cricketmatch.dart';
import 'package:scorecard/models/player.dart';

class Strings {
  // Bottom Navigation Bar
  static const String navbarMatches = "Matches";
  static const String navbarTournaments = "Tourneys";
  static const String navbarTeams = "Teams";
  static const String navbarPlayers = "Players";
  static const String navbarSettings = "Settings";

  //Score
  static const String scoreIn = " in ";
  static const String scoreYetToBat = "Yet to bat";
  static const String scoreWonToss = " has elected to ";
  static const String scoreMatchNotStarted = "This match hasn't started";
  static const String scoreRequire = " requires ";
  static const String scoreRunsIn = " runs in ";
  static const String scoreRunsInSingle = " run in ";
  static const String scoreBalls = " balls";
  static const String scoreAt = "\nat ";
  static const String scoreBallSingle = " ball";
  static const String scoreRunsPerOver = " runs per over";
  static const String scoreRunsPerOverSingle = " run per over";
  static const String scoreWillScore = " will score ";
  static const String scoreRunsAtCurrentRate = " runs at the current rate of ";
  static const String scoreOvers = " overs";
  static const String scoreWinBy = " win by ";
  static const String scoreWinByWickets = " wickets with ";
  static const String scoreWinByWicketSingle = " wicket with ";
  static const String scoreWinByBallsToSpare = " balls to spare";
  static const String scoreWinByBallsToSpareSingle = " ball to spare";
  static const String scoreWinByRuns = " runs";
  static const String scoreWinByRunSingle = " run";
  static const String scoreMatchTied = "Match Tied";

  static const String playerBatter = " Bat";
  // static const String playerBowler = " Bowl";

  static String getTossChoice(TossChoice tossChoice) {
    switch (tossChoice) {
      case TossChoice.bat:
        return "bat";
      case TossChoice.bowl:
        return "field";
    }
  }

  static String getArm(Arm arm) {
    if (arm == Arm.left) {
      return "Left Arm";
    } else {
      return "Right Arm";
    }
  }

  static String getBowlStyle(BowlStyle bowlStyle) {
    switch (bowlStyle) {
      case BowlStyle.spin:
        return " Spin";
      case BowlStyle.medium:
        return " Medium";
      case BowlStyle.fast:
        return " Fast";
    }
  }
}
