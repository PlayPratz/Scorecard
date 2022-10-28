import 'package:scorecard/models/cricketmatch.dart';
import 'package:scorecard/models/player.dart';
import 'package:scorecard/models/wicket.dart';

class Strings {
  Strings._();

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

  // Creation
  static const String matchlistCreateNewMatch = "Create new match";
  static const String addNewPlayer = "Add new player";
  static const String createNewTeam = "Create new team";

  // Others
  static const String captain = "Captain";
  static const String squad = "Squad";

  // Create Team
  static const String createTeamSelectCaptain = "Select a captain";
  static const String createTeamCaptainHint =
      "A good captain can make a bad team good, and a bad captain can make a good team bad.";
  static const String createTeamSquadHint =
      "Your captain is already in the squad. You can change the captian later.";
  static const String createTeamTeamName = "Team Name";
  static const String createTeamShortName = "Short Name";
  static const String createTeamCreate = "Create Team";

  // Create Match
  static const String createMatchSelectHomeTeam = "Select Home Team";
  static const String createMatchHomeTeamHint =
      "The crowd cheers more for them";
  static const String createMatchSelectAwayTeam = "Select Away Team";
  static const String createMatchAwayTeamHint =
      "People always love the underdogs";
  static const String createMatchStartMatch = "Start Match";

  // Choose
  static const String choosePlayer = "Choose a player";
  static const String chooseTeam = "Choose a team";

  // Match Screen
  static const String addWicket = "Add Wicket";
  static const String addWicketHint =
      "Specify how an unfortunate batter lost their wicket";

  static String getTossChoice(TossChoice tossChoice) {
    switch (tossChoice) {
      case TossChoice.bat:
        return "Bat";
      case TossChoice.bowl:
        return "Field";
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

  static String getDismissalName(Dismissal dismissal) {
    switch (dismissal) {
      case Dismissal.bowled:
        return "Bowled";
      case Dismissal.caught:
        return "Caught";
      case Dismissal.lbw:
        return "LBW";
      case Dismissal.hitWicket:
        return "Hit Wicket";
      case Dismissal.stumped:
        return "Stumped";
      case Dismissal.runout:
        return "Run Out";

      case Dismissal.retired:
        return "Retired";
      case Dismissal.hitTwice:
        return "Hit Twice";
      case Dismissal.obstructingField:
        return "Obstructing The Field";
      case Dismissal.timedOut:
        return "Timed Out";
    }
  }

  static String getRunText(int run) {
    return run.toString();
  }
}
