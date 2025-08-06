import 'dart:collection';
import 'dart:math';

import 'package:scorecard/modules/quick_match/post_ball_and_extras_model.dart';
import 'package:scorecard/modules/quick_match/wicket_model.dart';
import 'package:scorecard/util/number_utils.dart';

class QuickMatch {
  /// The ID of this Match as in the database
  final String id;

  /// The set of rules that define the play of this Match
  final QuickMatchRules rules;

  /// The date and time at which the Match starts
  final DateTime startsAt;

  /// Whether the match is completed
  bool isCompleted;

  QuickMatch(
    this.id, {
    required this.rules,
    required this.startsAt,
    this.isCompleted = false,
  });
}

class QuickMatchRules {
  final int ballsPerOver;
  // final int oversPerBowler;
  final int ballsPerInnings;

  final int noBallPenalty;
  final int widePenalty;

  final bool onlySingleBatter;
  // final bool lastWicketBatter;

  QuickMatchRules({
    required this.ballsPerOver,
    required this.ballsPerInnings,
    required this.noBallPenalty,
    required this.widePenalty,
    required this.onlySingleBatter,
    // required this.lastWicketBatter,
  });
}

class QuickInnings {
  /// The ID of the Match as in the database
  final String matchId;

  /// The ordinal number of this Innings in the Match
  final int inningsNumber;

  /// The set of rules that define the play of this Innings
  final QuickMatchRules rules;

  /// Whether the batting team has declared play
  bool isDeclared = false;

  /// The target runs of this Innings, if any
  /// This is not 'final' so that we can change targets in the future (DLS)
  int? target;

  QuickInnings(this.matchId, this.inningsNumber,
      {required this.rules, this.target});

  QuickInnings.load(
    this.matchId,
    this.inningsNumber, {
    required this.rules,
    required this.target,
    required this.batter1Id,
    required this.batter2Id,
    required this.strikerId,
    required this.bowlerId,
  });

  QuickInnings.of(QuickMatch match, this.inningsNumber)
      : matchId = match.id,
        rules = match.rules;

  final List<InningsPost> posts = [];
  UnmodifiableListView<Ball> get balls =>
      UnmodifiableListView(posts.whereType<Ball>());

  /// The runs scored by the batters
  int get runs => balls.fold(0, (s, b) => s + b.runs);

  /// The wickets taken by the bowlers
  int get wickets => balls.where((b) => b.isWicket).length;

  Score get score => Score(runs, wickets);

  /// The number of balls bowled
  int get numBalls => balls.where((b) => !b.isBowlingExtra).length;

  /// The average runs scored per over in this innings
  double get currentRunRate => handleDivideByZero(
      runs.toDouble() * rules.ballsPerOver, numBalls.toDouble());

  // On Crease

  String? batter1Id;
  String? batter2Id;

  String? strikerId;
  String? get nonStrikerId => batter2Id == strikerId
      ? batter1Id
      : batter1Id == strikerId
          ? batter2Id
          : null;

  String? bowlerId;

  // Target

  /// The runs required to win the match
  int? get runsRequired => target == null ? null : max(target! - runs, 0);

  /// The balls left to win the match
  int get ballsLeft => rules.ballsPerInnings - numBalls;

  double? get requiredRunRate => runsRequired == null
      ? null
      : handleDivideByZero(
          runsRequired!.toDouble() * rules.ballsPerOver, ballsLeft.toDouble());

  /// Conditions for considering an Innings as ended
  bool get hasEnded => isDeclared || ballsLeft == 0 || runsRequired == 0;

  Map<String, int> get extras {
    final extras = balls.where((b) => b.isBowlingExtra || b.isBattingExtra);
    final counts = <String, int>{
      "wd": 0,
      "nb": 0,
      "b": 0,
      "lb": 0,
    };

    for (final extra in extras) {
      if (extra.bowlingExtra is Wide) {
        counts["wd"] = counts["wd"]! + extra.bowlingExtraRuns;
      }
      if (extra.bowlingExtra is NoBall) {
        counts["nb"] = counts["nb"]! + extra.bowlingExtraRuns;
      }

      if (extra.battingExtra is Bye) {
        counts["b"] = counts["b"]! + extra.battingExtraRuns;
      }
      if (extra.bowlingExtra is LegBye) {
        counts["lb"] = counts["lb"]! + extra.battingExtraRuns;
      }
    }

    return counts;
  }
}

class Score {
  final int runs;
  final int wickets;

  Score(this.runs, this.wickets);

  Score.zero()
      : runs = 0,
        wickets = 0;

// Score plus(Ball ball) {
//   final runs = this.runs + ball.runs;
//   if (ball.isWicket) {
//     return Score(runs, wickets + 1);
//   } else {
//     return Score(runs, wickets);
//   }
// }
}

class BatterInnings {
  /// The ID of this Batter as in the database
  final String batterId;

  /// All balls played by this Batter
  final List<InningsPost> _posts;
  UnmodifiableListView<Ball> get balls =>
      UnmodifiableListView(_posts.whereType<Ball>());

  BatterInnings._(this.batterId, this._posts);

  BatterInnings.of(this.batterId, QuickInnings innings)
      : _posts = innings.posts
            .where((post) => switch (post) {
                  Ball() => post.batterId == batterId,
                  BowlerRetire() => false,
                  NextBowler() => false,
                  BatterRetire() => post.batterId == batterId,
                  NextBatter() => post.nextId == batterId,
                  RunoutBeforeDelivery() => post.batterId == batterId,
                })
            .toList();

  /// The runs scored by this Batter
  int get runs => balls.fold(0, (s, b) => s + b.batterRuns);

  /// The number of balls played by this Batter
  int get numBalls => balls.where((b) => b.bowlingExtra is! Wide).length;

  double get strikeRate => handleDivideByZero(runs * 100, numBalls.toDouble());

  Wicket? get wicket {
    if (balls.isNotEmpty) return balls.last.wicket;
    return null;
  }

  Retired? get retired {
    final last = _posts.lastOrNull;
    if (last is BatterRetire) return last.retired;
    return null;
  }

  bool get isOut => wicket != null || retired is RetiredDeclared;

  UnmodifiableListView<Ball> get boundaries =>
      UnmodifiableListView(balls.where((b) => b.isBoundary));

  Map<int, int> get boundaryCount {
    final boundaries = this.boundaries;
    final counts = <int, int>{};

    for (int i = 1; i <= 6; i++) {
      counts[i] = boundaries.where((b) => b.batterRuns == i).length;
    }
    return counts;
  }
}

class BowlerInnings {
  /// The ID of this Bowler as in the database
  final String bowlerId;

  final int ballsPerOver;

  /// All balls bowled by this Bowler
  final List<Ball> _balls;
  UnmodifiableListView<Ball> get balls => UnmodifiableListView(_balls);

  BowlerInnings._(this.bowlerId, this._balls, this.ballsPerOver);

  BowlerInnings.of(this.bowlerId, QuickInnings innings)
      : _balls = innings.balls.where((b) => b.bowlerId == bowlerId).toList(),
        ballsPerOver = innings.rules.ballsPerOver;

  /// The runs conceded by this Bowler
  int get runs =>
      balls.fold(0, (s, b) => s + b.batterRuns + b.bowlingExtraRuns);

  /// The number of balls bowler by this Bowler
  int get numBalls => balls.where((b) => !b.isBowlingExtra).length;

  /// The number of wickets
  int get numWickets => balls.where((b) => b.wicket is BowlerWicket).length;

  double get economy =>
      handleDivideByZero(runs.toDouble() * ballsPerOver, numBalls.toDouble());
  double get average => handleDivideByZero(runs * 100, numWickets.toDouble());
  double get strikeRate =>
      handleDivideByZero(numBalls.toDouble(), numWickets.toDouble());
}
