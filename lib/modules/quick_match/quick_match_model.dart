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

  /// Whether the match is completed
  bool isCompleted;

  // QuickMatchResult? result;

  QuickMatch({
    this.id,
    required this.handle,
    required this.rules,
    required this.startsAt,
    this.isCompleted = false,
  });
}

class QuickMatchRules {
  final int oversPerInnings;
  final int ballsPerOver;

  final int noBallPenalty;
  final int widePenalty;

  QuickMatchRules({
    required this.oversPerInnings,
    required this.ballsPerOver,
    required this.noBallPenalty,
    required this.widePenalty,
  });
}

class QuickInnings {
  /// The ID of the Innings as in the database
  int? id;

  /// The ID of the Match as in the database
  final int matchId;

  /// The ordinal number of this Innings in the Match
  final int inningsNumber;

  /// The set of rules that define the play of this Innings
  final QuickMatchRules _rules;

  /// Whether the batting team has declared play
  bool isDeclared = false;

  /// Whether this innings is a super over
  final bool isSuperOver;

  /// Whether the Innings has ended
  bool get isEnded => isCompleted; // || isForfeited || isDeclared TODO;

  /// Whether the Innings has achieved completion either by losing all wickets,
  /// reaching the over limit or chasing down the target.
  bool isCompleted;

  /// The target runs of this Innings, if any
  /// This is not 'final' so that we can change targets in the future (DLS)
  int? target;

  // QuickInnings(this.matchId, this.inningsNumber,
  //     {required this.rules, this.target});

  QuickInnings.load(
    this.id, {
    required this.matchId,
    required this.inningsNumber,
    required QuickMatchRules rules,
    required this.isCompleted,
    required this.target,
    required this.runs,
    required this.wickets,
    required this.balls,
    required this.extras,
    required this.batter1Id,
    required this.batter2Id,
    required this.strikerId,
    required this.bowlerId,
    required this.isDeclared,
    required this.isSuperOver,
  }) : _rules = rules;

  QuickInnings.of(QuickMatch match, this.inningsNumber)
      : matchId = match.id!,
        _rules = match.rules,
        isSuperOver = false,
        isCompleted = false,
        runs = 0,
        wickets = 0,
        balls = 0,
        extras = Extras.zero();

  QuickInnings.superOverOf(QuickMatch match, this.inningsNumber)
      : matchId = match.id!,
        _rules = match.rules,
        isSuperOver = true,
        isCompleted = false,
        runs = 0,
        wickets = 0,
        balls = 0,
        extras = Extras.zero();

  /// The runs scored by the batters
  final int runs;

  /// The wickets taken by the bowlers
  final int wickets;

  Score get score => Score(runs, wickets);

  /// The number of balls bowled
  final int balls;

  /// The number of legal balls in an over
  int get ballsPerOver => _rules.ballsPerOver;

  /// The number of overs that are to be bowled in this innings
  int get overLimit => _rules.oversPerInnings;
  int get ballLimit =>
      isSuperOver ? ballsPerOver : _rules.oversPerInnings * _rules.ballsPerOver;

  /// The balls left to win the match
  int get ballsLeft => ballLimit - balls;

  /// The average runs scored per over in this innings
  double get currentRunRate =>
      handleDivideByZero(runs.toDouble() * ballsPerOver, balls.toDouble());

  /// Penalty for a no-ball
  int get noBallPenalty => _rules.noBallPenalty;

  /// Penalty for a wide
  int get widePenalty => _rules.widePenalty;

  // On Crease
  int? batter1Id;
  int? batter2Id;
  int? strikerId;
  int? get nonStrikerId => batter2Id == strikerId
      ? batter1Id
      : batter1Id == strikerId
          ? batter2Id
          : null;
  int? bowlerId;

  // Target
  int? get runsRequired => target == null ? null : max(target! - runs, 0);
  double? get requiredRunRate => runsRequired == null
      ? null
      : handleDivideByZero(
          runsRequired!.toDouble() * ballsPerOver, ballsLeft.toDouble());

  final Extras extras;

  // Extras get extras {
  //   final extras = balls.where((b) => b.isExtra);
  //
  //   int noBalls = 0;
  //   int wides = 0;
  //   int byes = 0;
  //   int legByes = 0;
  //   int penalties = 0; // TODO Handle
  //
  //   for (final extra in extras) {
  //     if (extra.bowlingExtra is NoBall) {
  //       noBalls += extra.bowlingExtraRuns;
  //     } else if (extra.bowlingExtra is Wide) {
  //       wides += extra.bowlingExtraRuns;
  //     }
  //
  //     if (extra.battingExtra is Bye) {
  //       byes += extra.battingExtraRuns;
  //     } else if (extra.battingExtra is LegBye) {
  //       legByes += extra.battingExtraRuns;
  //     }
  //   }
  //
  //   return Extras(
  //       noBalls: noBalls,
  //       wides: wides,
  //       byes: byes,
  //       legByes: legByes,
  //       penalties: penalties);
  // }
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

  Score plus(Ball ball) {
    final runs = this.runs + ball.totalRuns;
    if (ball.isWicket) {
      return Score(runs, wickets + 1);
    } else {
      return Score(runs, wickets);
    }
  }
}

/// Represents the score of a batter within an innings
class BattingScore {
  /// The ID of this BattingScore as in the DB
  final int id;

  /// The ID of the match
  final String matchId;

  /// The ID of the innings
  final int inningsId;

  /// The cardinal number of the Innings
  final int inningsNumber;

  /// The ID of the batter who scored the runs
  final int batterId;

  /// The runs scored by this batter
  final int runsScored;

  /// The balls faced by this batter
  final int ballsFaced;

  /// Whether the batter is not out (*)
  final bool isNotOut;

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
    required this.batterId,
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
  final String batter1Id;
  final String batter2Id;

  final List<InningsPost> posts;
  UnmodifiableListView<Ball> get balls =>
      UnmodifiableListView(posts.whereType<Ball>());

  final BatterInnings batter1Innings;
  final BatterInnings batter2Innings;

  Partnership(this.posts, {required this.batter1Id, required this.batter2Id})
      : batter1Innings = BatterInnings(batter1Id, posts),
        batter2Innings = BatterInnings(batter2Id, posts);

  int get runs => balls.fold(0, (s, b) => s + b.totalRuns);
  int get numBalls => balls.where((b) => !b.isBowlingExtra).length;
}

class Over {
  final List<InningsPost> posts = [];
  UnmodifiableListView<Ball> get balls =>
      UnmodifiableListView(posts.whereType<Ball>());

  int get runs => balls.fold(0, (s, b) => s + b.totalRuns);
}
