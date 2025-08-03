import 'dart:collection';

import 'package:scorecard/modules/quick_match/ball_and_extras_model.dart';

class QuickMatch {
  final String id;

  final DateTime startsAt;

  QuickMatch(this.id, {required this.startsAt});
}

class QuickInnings {
  /// The ID of the Match as in the database
  final String matchId;

  /// The ordinal number of this Innings in the Match
  final int inningsNumber;

  /// The target runs of this Innings, if any
  final int? target;

  QuickInnings(this.matchId, this.inningsNumber, {this.target});

  final List<InningsPost> _posts = [];
  UnmodifiableListView<InningsPost> get posts => UnmodifiableListView(_posts);
}

class BatterInnings {
  /// The ID of this Batter as in the database
  final String batterId;

  /// All balls played by this Batter
  final List<Ball> _balls;
  UnmodifiableListView<Ball> get balls => UnmodifiableListView(_balls);

  BatterInnings._(this.batterId, this._balls);

  BatterInnings.of(this.batterId, QuickInnings innings)
      : _balls = innings.posts
            .whereType<Ball>()
            .where((b) => b.batterId == batterId)
            .toList();

  /// The total runs scored by this Batter
  int get runs => balls.fold(0, (s, b) => s + b.batterRuns);

  /// The total number of balls played by this Batter
  int get numBalls => balls.length;

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
      : _balls = innings.posts
            .whereType<Ball>()
            .where((b) => b.bowlerId == bowlerId)
            .toList();

  /// The total runs conceded by this Bowler
  int get runs =>
      balls.fold(0, (s, b) => s + b.batterRuns + b.bowlingExtraRuns);

  /// The total number of balls bowler by this Bowler
  int get numBalls => balls.length;
}
