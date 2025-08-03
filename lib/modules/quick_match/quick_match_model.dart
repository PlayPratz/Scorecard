import 'dart:collection';
import 'dart:math';

import 'package:scorecard/modules/quick_match/ball_and_extras_model.dart';
import 'package:scorecard/modules/quick_match/match_rules_model.dart';
import 'package:scorecard/util/number_utils.dart';

class QuickMatch {
  /// The ID of this Match as in the database
  final String id;

  /// The set of rules that define the play of this Match
  final QuickMatchRules rules;

  /// The date and time at which the Match starts
  final DateTime startsAt;

  QuickMatch(this.id, {required this.rules, required this.startsAt});
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
  int? target;

  QuickInnings(this.matchId, this.inningsNumber,
      {required this.rules, this.target});

  QuickInnings.of(QuickMatch match, this.inningsNumber)
      : matchId = match.id,
        rules = match.rules;

  final List<InningsPost> posts = [];
  UnmodifiableListView<Ball> get balls =>
      UnmodifiableListView(posts.whereType<Ball>());

  /// The total runs scored by the batters
  int get runs => balls.fold(0, (s, b) => s + b.runs);

  /// The total wickets taken by the bowlers
  int get wickets => balls.where((b) => b.isWicket).length;

  /// The total number of balls bowled
  int get numBalls => balls.where((b) => !b.isBowlingExtra).length;

  /// The average runs scored per over in this innings
  double get currentRunRate =>
      handleDivideByZero(runs.toDouble() * 6, numBalls.toDouble());

  // On Crease

  String? batter1Id;
  String? batter2Id;
  String? bowlerId;

  // Target

  /// The runs required to win the match
  int get runsRequired => target == null ? -1 : max(target! - runs, 0);

  /// The balls left to win the match
  int get ballsLeft => rules.maxBalls - numBalls;

  /// Conditions for considering an Innings as ended
  bool get isEnded => isDeclared || ballsLeft == 0 || runsRequired == 0;
}

class BatterInnings {
  /// The ID of this Batter as in the database
  final String batterId;

  /// All balls played by this Batter
  final List<Ball> _balls;
  UnmodifiableListView<Ball> get balls => UnmodifiableListView(_balls);

  BatterInnings._(this.batterId, this._balls);

  BatterInnings.of(this.batterId, QuickInnings innings)
      : _balls = innings.balls.where((b) => b.batterId == batterId).toList();

  /// The total runs scored by this Batter
  int get runs => balls.fold(0, (s, b) => s + b.batterRuns);

  /// The total number of balls played by this Batter
  int get numBalls => balls.where((b) => b.bowlingExtra is! Wide).length;

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

  /// All balls bowled by this Bowler
  final List<Ball> _balls;
  UnmodifiableListView<Ball> get balls => UnmodifiableListView(_balls);

  BowlerInnings._(this.bowlerId, this._balls);

  BowlerInnings.of(this.bowlerId, QuickInnings innings)
      : _balls = innings.balls.where((b) => b.bowlerId == bowlerId).toList();

  /// The total runs conceded by this Bowler
  int get runs =>
      balls.fold(0, (s, b) => s + b.batterRuns + b.bowlingExtraRuns);

  /// The total number of balls bowler by this Bowler
  int get numBalls => balls.where((b) => !b.isBowlingExtra).length;
}
