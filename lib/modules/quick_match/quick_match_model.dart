import 'dart:collection';
import 'dart:math';

import 'package:scorecard/modules/quick_match/post_ball_and_extras_model.dart';
import 'package:scorecard/modules/quick_match/wicket_model.dart';
import 'package:scorecard/util/number_utils.dart';

class QuickMatch {
  /// The ID of this Match as in the database
  final int? id;

  /// The globally unique key of a player
  /// ex: #01KC1WJYQSY11J51V7DGGDJKPF ('#' is not a part of the handle)
  final String handle;

  /// The set of rules that define the play of this Match
  final QuickMatchRules rules;

  /// The date and time at which the Match starts
  final DateTime startsAt;

  /// The current stage of the match
  int stage;

  // QuickMatchResult? result;

  QuickMatch({
    required this.id,
    required this.handle,
    required this.rules,
    required this.startsAt,
    required this.stage,
  });
}

class QuickMatchRules {
  final int oversPerInnings;
  final int ballsPerOver;

  QuickMatchRules({
    required this.oversPerInnings,
    required this.ballsPerOver,
  });
}

class QuickInnings {
  /// The ID of the Innings as in the database
  final int? id;

  /// The ID of the Match as in the database
  final int matchId;

  /// The ordinal number of this Innings in the Match
  final int inningsNumber;

  /// The type of innings, such as super over
  final int type;

  /// The status of the innings: not-started, in-progress, completed, forfeited, declared, etc.
  int status;

  /// The target runs of this Innings, if any
  /// This is not 'final' so that we can change targets in the future (DLS)
  int? target;

  QuickInnings({
    required this.id,
    required this.matchId,
    required this.inningsNumber,
    required this.type,
    required this.status,
    required this.overLimit,
    required this.ballsPerOver,
    required this.target,
    required this.runs,
    required this.wickets,
    required this.balls,
    required this.extras,
    required this.batter1Id,
    required this.batter2Id,
    required this.striker,
    required this.bowlerId,
  });

  QuickInnings.first(QuickMatch match)
      : id = null,
        matchId = match.id!,
        inningsNumber = 1,
        type = 1,
        status = -1,
        runs = 0,
        wickets = 0,
        balls = 0,
        ballsPerOver = match.rules.ballsPerOver,
        overLimit = match.rules.oversPerInnings,
        extras = Extras.zero();

  QuickInnings.next(QuickInnings previous)
      : id = null,
        matchId = previous.matchId,
        inningsNumber = previous.inningsNumber + 1,
        target = previous.runs + 1,
        type = 1,
        status = -1,
        runs = 0,
        wickets = 0,
        balls = 0,
        ballsPerOver = previous.ballsPerOver,
        overLimit = previous.overLimit,
        extras = Extras.zero();

  QuickInnings.nextSuperOver(QuickInnings previous)
      : id = null,
        matchId = previous.matchId,
        inningsNumber = previous.inningsNumber + 1,
        target = previous.isSuperOver ? previous.runs + 1 : null,
        type = 2,
        status = -1,
        runs = 0,
        wickets = 0,
        balls = 0,
        ballsPerOver = previous.ballsPerOver,
        overLimit = 1,
        extras = Extras.zero();

  /// The runs scored by the batters
  final int runs;

  /// The wickets taken by the bowlers
  final int wickets;

  Score get score => Score(runs, wickets);

  /// The number of legal balls bowled
  final int balls;

  /// The number of legal balls in an over
  final int ballsPerOver;

  /// The number of overs that are to be bowled in this innings
  final int overLimit;
  int get ballLimit => overLimit * ballsPerOver;

  bool get isSuperOver => false; //TODO

  /// The balls left to win the match
  int get ballsLeft => ballLimit - balls;

  /// The average runs scored per over in this innings
  double get currentRunRate =>
      handleDivideByZero(runs.toDouble() * ballsPerOver, balls.toDouble());

  // On Crease
  int? batter1Id;
  int? batter2Id;
  int striker = 1;

  int? get strikerId => striker == 1
      ? batter1Id
      : striker == 2
          ? batter2Id
          : null;

  int? get nonStrikerId => striker == 1
      ? batter2Id
      : striker == 2
          ? batter1Id
          : null;

  int? bowlerId;

  // Target
  int? get runsRequired => target == null ? null : max(target! - runs, 0);
  double? get requiredRunRate => runsRequired == null
      ? null
      : handleDivideByZero(
          runsRequired!.toDouble() * ballsPerOver, ballsLeft.toDouble());

  final Extras extras;

  bool get isEnded => [
        InningsStatus.calledOff,
        InningsStatus.allOut,
        InningsStatus.batterUnavailable,
        InningsStatus.declared,
        InningsStatus.forfeited,
        InningsStatus.mutualAgreement,
        InningsStatus.outOfOvers,
        InningsStatus.outOfTime,
      ].contains(status);
}

enum InningsStatus {
  scheduled("scheduled"),
  inProgress("in progress"),
  inningsBreak("innings break"),
  drinksBreak("drinks break"),
  mealBreak("meal break"),
  lunchBreak("lunch break"),
  teaBreak("tea break"),
  suspended("suspended"),
  calledOff("called off"),
  allOut("all out"),
  batterUnavailable("batter unavailable"),
  declared("declared"),
  forfeited("forfeited"),
  mutualAgreement("mutual agreement"),
  outOfOvers("out of overs"),
  outOfTime("out of time"),
  targetAchieved("target achieved");

  final String code;
  const InningsStatus(this.code);
}

class Extras {
  final int noBalls;
  final int wides;
  final int byes;
  final int legByes;
  final int penalties;

  int get total => noBalls + wides + byes + legByes + penalties;

  Extras(
      {required this.noBalls,
      required this.wides,
      required this.byes,
      required this.legByes,
      required this.penalties});

  Extras.zero()
      : noBalls = 0,
        wides = 0,
        byes = 0,
        legByes = 0,
        penalties = 0;
}

sealed class QuickMatchResult {}

class QuickMatchDefendedResult extends QuickMatchResult {
  final int runs;

  QuickMatchDefendedResult(this.runs);
}

class QuickMatchChasedResult extends QuickMatchResult {
  final int ballsToSpare;

  QuickMatchChasedResult(this.ballsToSpare);
}

class QuickMatchTieResult extends QuickMatchResult {}

class Score {
  final int runs;
  final int wickets;

  Score(this.runs, this.wickets);

  Score.zero()
      : runs = 0,
        wickets = 0;

  Score plus(Score score) => Score(runs + score.runs, wickets + score.wickets);
  Score minus(Score score) => Score(runs - score.runs, wickets - score.wickets);
}

/// Represents the score of a bowler within an innings
class BowlingScore {
  /// The ID of this BowlingScore as in the DB
  final int? id;

  /// The ID of the match
  final int matchId;

  /// The ID of the innings
  final int inningsId;

  /// The cardinal number of the Innings
  final int inningsNumber;

  /// The type of the Innings
  final int inningsType;

  /// The ID of the batter who scored the runs
  final int bowlerId;

  /// The balls bowled by this bowler
  final int ballsBowled;

  /// The runs conceded by this bowler
  final int runsConceded;

  /// The wickets taken by this bowler
  final int wicketsTaken;

  /// The extras bowled by this bowler
  final int extrasBowled;
  final int noBallsBowled;
  final int widesBowled;

  /// The economy of this bowler
  final double economy;

  BowlingScore({
    required this.id,
    required this.matchId,
    required this.inningsId,
    required this.inningsNumber,
    required this.inningsType,
    required this.bowlerId,
    required this.ballsBowled,
    required this.runsConceded,
    required this.wicketsTaken,
    required this.noBallsBowled,
    required this.widesBowled,
    required this.extrasBowled,
    required this.economy,
  });
}

/// Represents the score of a batter within an innings
class BattingScore {
  /// The ID of this BattingScore as in the DB
  final int? id;

  /// The ID of the match
  final int matchId;

  /// The ID of the innings
  final int inningsId;

  /// The cardinal number of the Innings
  final int inningsNumber;

  /// The type of the Innings
  final int inningsType;

  /// The ID of the batter who scored the runs
  final int batterId;

  /// The batting number/position
  final int battingAt;

  /// The runs scored by this batter
  final int runsScored;

  /// The balls faced by this batter
  final int ballsFaced;

  /// Whether the batter is not out (*)
  final bool? isNotOut;
  // bool get isOut => !isNotOut;

  /// The wicket of this batter if any
  final Wicket? wicket;

  /// The number of fours scored by this batter
  final int fours;

  /// The number of sizes scored by this batter
  final int sixes;

  /// The total number of boundaries scored by this batter
  final int boundaries;

  /// The strike rate of this batter
  final double strikeRate;

  BattingScore({
    required this.id,
    required this.matchId,
    required this.inningsId,
    required this.inningsNumber,
    required this.inningsType,
    required this.batterId,
    required this.battingAt,
    required this.runsScored,
    required this.ballsFaced,
    required this.isNotOut,
    required this.wicket,
    required this.fours,
    required this.sixes,
    required this.boundaries,
    required this.strikeRate,
  });
}

class FallOfWicket {
  final Wicket wicket;
  final PostIndex postIndex;
  final Score scoreAt;

  FallOfWicket(this.wicket, {required this.postIndex, required this.scoreAt});
}

class Partnership {
  final int? id;

  final int matchId;
  final int inningsId;
  final int inningsNumber;
  final int inningsType;

  final int runs;
  final int balls;
  final int battingAt;

  final int batter1Id;
  final int batter1Runs;
  final int batter1Balls;

  final int batter2Id;
  final int batter2Runs;
  final int batter2Balls;

  final Extras extras;

  Partnership({
    required this.id,
    required this.matchId,
    required this.inningsId,
    required this.inningsNumber,
    required this.inningsType,
    required this.runs,
    required this.balls,
    required this.battingAt,
    required this.batter1Id,
    required this.batter1Runs,
    required this.batter1Balls,
    required this.batter2Id,
    required this.batter2Runs,
    required this.batter2Balls,
    required this.extras,
  });
}

class Over {
  final int overNumber;

  List<InningsPost> posts = [];

  Score get scoreIn {
    final first = posts.first;
    final last = posts.last;

    return last.scoreAt.minus(first.scoreAt);
  }

  Over(this.overNumber);
}
