import 'dart:collection';

import 'package:scorecard/modules/cricket_match/models/cricket_match_model.dart';
import 'package:scorecard/modules/cricket_match/models/cricket_match_rules_model.dart';
import 'package:scorecard/modules/cricket_match/models/innings_model.dart';
import 'package:scorecard/modules/player/player_model.dart';

/// Represents a FRIENDLY Cricket Match
///
/// What's the difference between a [CricketMatch] and a [CricketFriendly]
///
/// As you may notice below, a CricketFriendly does NOT include any teams.
/// That's right. You may wonder how can a game of cricket ever take place
/// without two teams. You see, this is what happens most of the time among
/// friends. Teams are made arbitrarily and may change during the course
/// of the match. The solution? Ignore teams! Any player from the entire
/// database can play any CricketFriendly at any time. Someone joins midway?
/// No problem; just add them to the list of players and you're good to go.
///
/// As a rule of thumb, a CricketFriendly is necessarily LimitedOvers.
class CricketFriendly {
  /// Predictably, a unique identifier for this CricketMatch
  final String id;

  /// The format and rules that will be followed for this match.
  final GameRules rules;

  final DateTime startsAt;

  CricketFriendly({
    required this.id,
    required this.rules,
    required this.startsAt,
  });
}

/// A CricketFriendly that has completed and can show a result.
class CompletedCricketFriendly extends CricketFriendly {
  final LimitedOversMatchResult result;

  CompletedCricketFriendly({
    required super.id,
    required super.rules,
    required this.result,
    required super.startsAt,
  });
}

/// Represents an Innings in a Cricket Friendly
class CricketFriendlyInnings {
  /// The unique identifier of the friendly in which this innings takes place
  final String friendlyId;

  /// The ordinal number of the innings in the Cricket Game
  final int inningsNumber;

  /// List of posts that happen throughout
  final List<InningsPost> posts = [];
  UnmodifiableListView<Ball> get balls =>
      UnmodifiableListView(posts.whereType<Ball>());

  /// Total runs awarded to the batting team
  int get runs => balls.fold(0, (value, ball) => value + ball.runs);

  /// Total wickets taken by the bowling team
  int get wickets => wicketBalls.length;
  Iterable<Ball> get wicketBalls => balls.where((ball) => ball.isWicket);

  /// All batters that walk out to the pitch
  ///
  /// Since a player can bat only once in an innings, a map is used.
  /// The given literal produces a [LinkedHashMap], so insertion order is
  /// preserved.
  final Map<Player, BatterInnings> batters = {};

  /// All bowlers that roll their arms
  final Map<Player, BowlerInnings> bowlers = {};

  /// A batter who is on the pitch
  BatterInnings? batter1;

  /// A batter who is on the pitch
  BatterInnings? batter2;

  /// The batter who is on strike, facing the upcoming delivery.
  ///
  /// Must be either [batter1] or [batter2]
  BatterInnings? striker;

  /// The batter who is on the pitch but not on strike, i.e. at the
  /// non-striker's end.
  ///
  /// Must be either [batter1] or [batter2]
  BatterInnings? get nonStriker => batter1 == striker ? batter2 : batter1;

  /// The bowler who is bowling the current over
  BowlerInnings? bowler;

  /// Has the innings completed naturally
  bool isCompleted = false;

  /// Has the innings been forced to end by the user
  bool isEnded = false;

  CricketFriendlyInnings(
      {required this.friendlyId, required this.inningsNumber});

  Map<int, Iterable<InningsPost>> get overs {
    if (posts.isEmpty) return {};

    final map = <int, List<InningsPost>>{};
    for (final post in posts) {
      final overIndex = post.index.over + 1;
      if (!map.containsKey(overIndex)) {
        map[overIndex] = [];
      }
      map[overIndex]!.add(post);
    }

    return map;
  }
}
