import 'package:scorecard/models/cricketmatch.dart';

class Strings {
  // Bottom Navigation Bar
  static const String navbarMatches = "Matches";
  static const String navbarFriendlies = "Friendlies";
  static const String navbarTournaments = "Tournaments";
  static const String navbarPlayers = "Players";

  //Score
  static const String scoreIn = " in ";
  static const String scoreYetToBat = "Yet to bat";
  static const String scoreWonToss = " have elected to ";
  static const String scoreMatchNotStarted = "This match hasn't started";
  static const String scoreRequire = " require ";
  static const String scoreRunsIn = " runs in ";
  static const String scoreBalls = " balls at ";
  static const String scoreRunsPerOver = " runs per over";
  static const String scoreWillScore = " will score ";
  static const String scoreRunsAtCurrentRate = " runs at the current rate of ";
  static const String scoreOvers = " overs";

  static String getTossChoice(TossChoice tossChoice) {
    switch (tossChoice) {
      case TossChoice.bat:
        return "bat";
      case TossChoice.bowl:
        return "field";
    }
  }
}
