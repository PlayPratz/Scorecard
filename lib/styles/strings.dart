import '../models/ball.dart';
import '../models/cricketmatch.dart';
import '../models/player.dart';
import '../models/wicket.dart';

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
  static const String scoreRunsPerOver = " RPO";
  static const String scoreRunsPerOverSingle = " RPO";
  static const String scoreWillScore = " will score ";
  static const String scoreRunsAtCurrentRate = " runs at ";
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

  // Hacks
  static const String empty = "";
  static const String seperatorHyphen = '-';
  static const String seperatorSlash = '/';
  static const String bracketOpenWithSpace = " (";
  static const String bracketClose = ")";
  static const String seperatorVersus = " v ";

  // Create Team
  static const String createTeamSelectCaptain = "Select a captain";
  static const String createTeamCaptainHint =
      "A good captain can make a bad team good, and a bad captain can make a good team bad.";
  static const String createTeamSquadHint =
      "Your captain is already in the squad. You can change the captian later.";
  static const String createTeamTeamName = "Team Name";
  static const String createTeamShortName = "Short Name";
  static const String createTeamCreate = "Create Team";

  // Create Player
  static const String createPlayerTitle = "Player Details";
  static const String createPlayerName = "Name";
  static const String createPlayerNameHint = "A future superstar?";
  static const String createPlayerBatArm = "Batting Arm";
  static const String createPlayerBowlArm = "Bowling Arm";
  static const String createPlayerBowlStyle = "Bowling Style";
  static const String createPlayerSave = "Save Player";

  // Create Match
  static const String createMatchSelectHomeTeam = "Select Home Team";
  static const String createMatchHomeTeamHint =
      "The crowd cheers more for them";
  static const String createMatchSelectAwayTeam = "Select Away Team";
  static const String createMatchAwayTeamHint =
      "People always love the underdogs";
  static const String createMatchStartMatch = "Start Match";
  static const String createMatchOvers = "Overs";
  static const String createMatchOversHint = "How many overs? 5? 10? 20?";

  // Match Init
  static const String initMatchTitle = "The Fun Begins!";
  static const String initMatchHeadingToss = "Toss";
  static const String initMatchTossTeamPrimary = "Toss Winner";
  static const String initMatchTossTeamHint = "Specify which team was luckier";
  static const String initMatchTossChoicePrimary = "Choose to?";
  static const String initMatchTossChoiceHint =
      "Win or Lose? Oh sorry - Bat or Field?";
  static const String initMatchTossChoiceTitle = "Win the toss and choose to";
  static const String initMatchStartMatch = Strings.createMatchStartMatch;

  // Innings Init
  static const String initInningsTitle = "Let's Start The Innings";
  static const String initInningsBatter1 = "Batter One";
  static const String initInningsBatter2 = "Batter Two";
  static const String initInningsBowler = "Bowler";
  static const String initInningsChooseBatter = "Choose a Batter";
  static const String initInningsChooseBatterHint =
      "Someone who can score many runs, hopefully";
  static const String initInningsChooseBowler = "Choose a Batter";
  static const String initInningsChooseBowlerHint =
      "Someone who can take many wickets, hopefully";
  static const String initInningsStartInnings = "Start Innings";

  // Scorecard
  static const String scorecardFirstInnings = "First Innings";
  static const String scorecardSecondInnings = "Second Innings";
  static const String scorecardBatting = "Batting";
  static const String scorecardBowling = "Bowling";

  // Choose
  static const String choosePlayer = "Choose a Player";
  static const String chooseTeam = "Choose a Team";

  // Wickets
  static const String chooseWicket = "Choose a Wicket";

  // Match Screen
  static const String matchScreenAddWicket = "Add Wicket";
  static const String matchScreenAddWicketHint =
      "Specify the game-changing incident";
  static const String matchScreenEndInnings = "End Innings";
  static const String matchScreenUndo = "Undo";
  static const String matchScreenChooseBatter = "Choose Batter";
  static const String matchScreenChooseBowler = "Choose Bowler";

  // Ball Selector
  static const String ballSelectorRuns = "Runs";

  // Common
  static const String buttonNext = "Next";

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

  static String getBowlingExtra(BowlingExtra bowlingExtra) {
    switch (bowlingExtra) {
      case BowlingExtra.noBall:
        return "No Ball";
      case BowlingExtra.wide:
        return "Wide";
      default:
        return "Bowling Extra";
    }
  }

  static String getBattingExtra(BattingExtra battingExtra) {
    switch (battingExtra) {
      case BattingExtra.bye:
        return "Bye";
      case BattingExtra.legBye:
        return "Leg Bye";
      default:
        return "Bowling Extra";
    }
  }

  static String getRunText(int run) {
    return run.toString();
  }
}
