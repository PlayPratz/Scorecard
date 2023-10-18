import 'package:scorecard/models/ball.dart';
import 'package:scorecard/models/cricket_match.dart';
import 'package:scorecard/models/innings.dart';
import 'package:scorecard/models/player.dart';
import 'package:scorecard/models/result.dart';
import 'package:scorecard/models/statistics.dart';
import 'package:scorecard/models/wicket.dart';
import 'package:scorecard/util/constants.dart';

class Strings {
  Strings._();

  // Bottom Navigation Bar
  static const String navbarMatches = "Matches";
  static const String navbarPlayers = "Players";
  static const String navbarSettings = "Settings";
  static const String navbarStats = "Statistics";

  //Score
  static const String scoreYetToBat = "Yet to bat";
  static const String scoreWonToss = " has elected to ";
  static const String scoreMatchNotStarted = "This match hasn't started";
  static const String scoreBallSingle = " ball";
  static const String scoreRunsPerOver = "RPO";
  static const String scoreRequire = "Require";
  static const String scoreBalls = "Balls";
  static const String scoreCRR = "CRR";
  static const String scoreCurrentRunRate = "Current Run Rate";
  static const String scoreRRR = "RRR";
  static const String scoreRequiredRunRate = "Required Run Rate";
  static const String scoreProjected = "Projected";

  // static const String scoreWinByWickets = " wickets with ";
  // static const String scoreWinByWicketSingle = "wicket with";
  static const String scoreMatchTied = "Match Tied";
  static const String scoreMatchDrawn = "Match Drawn";

  static String getTossWinner(Toss toss) {
    return "${toss.winningTeam.shortName} has elected to ${getTossChoice(toss.choice)}";
  }

  static String getChaseEquation(Innings innings) {
    return "${innings.battingTeam.team.shortName} requires ${innings.requiredRuns} in ${innings.ballsLeft} balls";
  }

  static String getResult(Result result) {
    if (result.victoryType == VictoryType.chasing) {
      final ballString = (result as ResultWinByChasing).ballsLeft == 1
          ? "ball to spare"
          : "balls to spare";
      return "${result.winner.team.shortName} wins with ${result.ballsLeft} $ballString";
    } else if (result.victoryType == VictoryType.defending) {
      final runString =
          (result as ResultWinByDefending).runsWonBy == 1 ? "run" : "runs";
      return "${result.winner.team.shortName} wins by ${result.runsWonBy} $runString";
    } else if (result.victoryType == VictoryType.tie) {
      return scoreMatchTied;
    } else {
      return scoreMatchDrawn;
    }
  }
  //
  // static String getBatterInningsScore(BatterInnings innings) {
  //   return "${innings.runs} in ${innings.ballsFaced}";
  // }

  // static String getBowlerInningsScore(BowlingStats bowlingStats) {
  //   return "${bowlingStats.wicketsTaken}-${bowlingStats.runsConceded} in ${getBowlerOversBowled(bowlingStats)}";
  // }

  static String getBowlerOversBowled(BowlingCalculations bowlingStats) {
    return "${bowlingStats.legalBallsBowled ~/ Constants.ballsPerOver}.${bowlingStats.legalBallsBowled % Constants.ballsPerOver}";
  }

  static String getBowlerFigures(BowlingCalculations bowlingStats) {
    return "${bowlingStats.wicketsTaken}-${bowlingStats.runsConceded}";
  }

  static String getOverBowledText(Innings innings, {required bool short}) {
    final oversBowled =
        "${innings.ballsBowled ~/ Constants.ballsPerOver}.${innings.ballsBowled % Constants.ballsPerOver}";
    if (short) return "$oversBowled ov";
    final overText = innings.maxOvers == 1 ? "over" : "overs";
    return "$oversBowled/${innings.maxOvers} $overText";
  }

  static String getInningsScore(Innings innings) =>
      "${innings.runs}/${innings.wickets}";

  static String getOverSummary(Over over) {
    int runs = over.runsConceded;
    int wickets = over.wicketsTaken;
    final runsString = runs == 1 ? "RUN" : "RUNS";
    final wicketString = wickets == 1 ? "WICKET" : "WICKETS";

    return "$runs $runsString, $wickets $wicketString";
  }

  static String getCricketMatchTitle(CricketMatch cricketMatch) {
    return "${cricketMatch.home.team.shortName} ${Strings.versus} ${cricketMatch.away.team.shortName}";
  }

  static const String playerBatter = " Bat";

  // static const String playerBowler = " Bowl";

  // Creation
  static const String matchListCreateNewMatch = "Create new match";
  static const String createQuickMatch = "Quick Match";

  static const String addNewPlayer = "Add new player";
  static const String createNewTeam = "Create new team";

  // Others
  static const String captain = "Captain";
  static const String squad = "Add to Squad";

  // Hacks
  static const String empty = "";
  static const String whitespace = " ";
  static const String versus = "v";

  // Create Team
  static const String createTeamSelectCaptain = "Select a captain";
  static const String createTeamCaptainHint =
      "A good captain can make a bad team good. But a bad captain can make a good team bad.";
  static const String createTeamSquadHint =
      "Your captain is already in the squad. You can change the captian later.";
  static const String createTeamTeamName = "Team Name";
  static const String createTeamShortName = "Short Name";
  static const String createTeamCreate = "Create new team";
  static const String createTeamSave = "Save Team";

  // Create Quick Teams
  static const String createQuickTeamsSelectPlayers = "Select Players";
  static String getSelectedPlayerCount(int count) {
    if (count == 1) {
      return "Selected $count player";
    } else {
      return "Selected $count players";
    }
  }

  // Create Player
  static const String createPlayerTitle = "Player Details";
  static const String createPlayerName = "Name";
  static const String createPlayerNameHint = "A future superstar?";
  static const String createPlayerBatArm = "Batting Arm";
  static const String createPlayerBowlArm = "Bowling Arm";
  static const String createPlayerBowlStyle = "Bowling Style";
  static const String createPlayerSave = "Save Player";

  // Match List
  static const String matchListRematch = "Rematch";
  static const String matchListRematchDescription =
      "Quickly start a new match with the same teams";
  static const String matchListDelete = "Delete";
  static const String matchListDeleteDescription =
      "This match will be gone forever! (That's a really long time)";

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
  static const String initMatchTossChoicePrimary = "Choose to...";
  static const String initMatchTossChoiceHint =
      "Win or Lose? Oh sorry - Bat or Field?";
  static const String initMatchTossChoiceTitle = "Win the toss and choose to";
  static const String initMatchStartMatch = createMatchStartMatch;

  // Innings Init
  static const String initInningsTitle = "Let's Start The Innings";
  static const String initInningsStriker = "Striker";
  static const String initInningsNonStriker = "Non-Striker";
  static const String initInningsBowler = "Bowler";
  static const String initInningsChooseBatter = "Choose Openers";
  static const String initInningsChooseBatterHint = "It's scorin' time!";
  static const String initInningsChooseBowler = "Choose a Bowler";
  static const String initInningsChooseBowlerHint = "It's wicketin' time!";
  static const String initInningsStartInnings = "Start Innings";

  // Scorecard
  static const String scorecardFirstInnings = "First Innings";
  static const String scorecardSecondInnings = "Second Innings";
  static const String scorecardBatting = "Batting";
  static const String scorecardBowling = "Bowling";
  static const String scorecardInningsWithSpace = " Innings";
  static const String scorecardFallOfWickets = "Fall Of Wickets";
  static const String scorecardYetToBat = "Yet to bat";

  static const String goToTimeline = "View Timeline";
  static const String innings = "Innings";

  static const String extras = "Extras";
  static const String total = "Total";

  static String getInningsHeaderForIndex(int i) {
    if (i == 1) return "First Innings";
    if (i == 2) return "Second Innings";
    return "Innings";
  }

  static String getExtrasForInnings(
      int wides, int noBalls, int byes, int legByes) {
    return "($wides wd, $noBalls nb, $byes b, $legByes lb)";
  }

  // Choose
  static const String choosePlayer = "Choose a Player";
  static const String chooseTeam = "Choose a Team";

  // Match Screen
  static const String matchScreenAddWicket = "Add Wicket";
  static const String matchScreenAddWicketHint = "Specify wicket details";
  static const String matchScreenEndInnings = "End Innings";
  static const String matchScreenEndInningsShort = "End";
  static const String matchScreenEndInningsLongPressToEnd =
      "Long press the button to end innings";
  static const String matchScreenUndo = "Undo";
  static const String matchScreenChooseBatter = "Choose Batter";
  static const String matchScreenChooseBowler = "Choose Bowler";
  static const String matchScreenMatchTied = "The match has ended in a TIE!";
  static const String matchScreenMatchTiedHint =
      "What would you like to do now?";
  static const String matchScreenEndTiedMatch = "End Match as Tie";
  static const String matchScreenEndTiedMatchHint =
      "The teams were quite evenly matched, weren't they?";
  static const String matchScreenSuperOver = "Super Over";
  static const String matchScreenSuperOverHint =
      "A quick one-over game to settle the scores.";
  static const String matchScreenAddBall = "Add Ball";
  static const String matchScreenReplaceBatterError =
      "Only a batter who has not lost their wicket and has not faced a single delivery can be replaced.";

  // Ball Selector
  static const String extraEventBall = "Event";

  // Pick Batter
  static const String pickBatterTitle = "Pick the next batter";
  static const String pickBatterLastMan = "Continue as Last Man";

  // Pick Bowler
  static const String pickBowlerTitle = "Pick the next bowler";

  // Players in Action
  static const String playersInAction = "Players in Action";

  // Recent Balls (Innings Timeline)
  static const String inningsTimelineTitle = "Innings Timeline";

  static String getBallIndex(Ball ball) {
    return "${ball.overIndex}.${ball.ballIndex}";
  }

  static String getDeliveryHeadline(Ball ball) {
    return "${ball.bowler.name} to ${ball.batter.name}";
  }

  // Sharing
  static const String share = "Share";
  static const String sharePlayerHint = "Share this player as a JSON file";
  static const String exportAllPlayers = "Export all Players";
  static const String exportAllPlayersHint = "As a handy JSON file";

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
      // case Dismissal.hitTwice:
      //   return "Hit Twice";
      // case Dismissal.obstructingField:
      //   return "Obstructing The Field";
      // case Dismissal.timedOut:
      //   return "Timed Out";
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

  // Wickets
  static const String chooseWicket = "Choose a Wicket";
  static const String selectDismissal = "Select a Dismissal";
  static const String selectDismissalHint = "How did the batter get out?";
  static const String selectBatter = "Select a Batter";
  static const String selectBatterHint = "Which batter got out?";
  static const String selectFielder = "Select a Fielder";
  static const String selectFielderHint = "Which fielder gave their hand?";

  // Settings
  static const String settingsAppVersion = "App Version";

  static String getWicketDescription(Wicket? wicket) {
    if (wicket == null) {
      // return wicketNotOut;
      return "not out";
    }
    switch (wicket.dismissal) {
      case Dismissal.runout:
        // return wicketRunout + wicket.fielder!.name;
        return "run-out ${wicket.fielder!.name}";

      case Dismissal.caught:
        if (wicket.bowler == wicket.fielder) {
          // return wicketCaughtAndBowled + wicket.fielder!.name;
          return "c&b ${wicket.bowler!.name}";
        }
        return "c ${wicket.fielder!.name} b ${wicket.bowler!.name}";

      case Dismissal.stumped:
        return "st ${wicket.fielder!.name} b ${wicket.bowler!.name}";

      case Dismissal.lbw:
        return "lbw ${wicket.bowler!.name}";

      case Dismissal.hitWicket:
        return "hit-wicket b ${wicket.bowler!.name}";

      case Dismissal.bowled:
        return "b ${wicket.bowler!.name}";

      case Dismissal.retired:
      default:
        return "retired";
    }
  }

  /*
    static const String wicketBowled = "b ";
    static const String wicketCaught = "c ";
    static const String wicketCaughtAndBowled = "c&b ";
    static const String wicketLbw = "lbw ";
    static const String wicketHitWicket = "hit-wicket ";
    static const String wicketRunout = "run-out ";
    static const String wicketStumped = "st ";
    static const String wicketNotOut = "not out";
  */
}
