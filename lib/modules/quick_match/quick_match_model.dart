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
  /// The ID of the Innings as in the database
  int? id;

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
    this.id, {
    required this.matchId,
    required this.inningsNumber,
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
  int get runs => balls.fold(0, (s, b) => s + b.totalRuns);

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

  Score plus(Ball ball) {
    final runs = this.runs + ball.totalRuns;
    if (ball.isWicket) {
      return Score(runs, wickets + 1);
    } else {
      return Score(runs, wickets);
    }
  }
}

class BatterInnings {
  /// The ID of this Batter as in the database
  final String batterId;

  /// All balls played by this Batter or involve their wicket
  final List<InningsPost> _posts;
  UnmodifiableListView<Ball> get allBalls =>
      UnmodifiableListView(_posts.whereType<Ball>());

  /// All balls played by this Batter
  UnmodifiableListView<Ball> get balls =>
      UnmodifiableListView(allBalls.where((b) => b.batterId == batterId));

  BatterInnings._(this.batterId, this._posts);

  BatterInnings.of(this.batterId, QuickInnings innings)
      : _posts = innings.posts
            .where((post) => switch (post) {
                  Ball() => post.batterId == batterId ||
                      post.wicket?.batterId == batterId,
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

class FallOfWickets {
  final List<FallOfWicket> _all;
  UnmodifiableListView<FallOfWicket> get all => UnmodifiableListView(_all);

  FallOfWickets._(this._all);

  factory FallOfWickets.of(QuickInnings innings) {
    final balls = innings.balls;
    final fow = <FallOfWicket>[];
    Score score = Score.zero();
    for (final ball in balls) {
      score = score.plus(ball);
      if (ball.isWicket) {
        fow.add(FallOfWicket(
          ball.wicket!,
          postIndex: ball.index,
          scoreAt: score,
        ));
      }
    }
    return FallOfWickets._(fow);
  }
}

class FallOfWicket {
  final Wicket wicket;
  final PostIndex postIndex;
  final Score scoreAt;

  FallOfWicket(this.wicket, {required this.postIndex, required this.scoreAt});
}

class Partnerships {
  final List<Partnership> _all;
  UnmodifiableListView<Partnership> get all => UnmodifiableListView(_all);

  Partnerships._(this._all);

  factory Partnerships.of(QuickInnings innings) {
    final posts = innings.posts;

    final firstTwo = posts.whereType<NextBatter>().take(2);
    if (firstTwo.length < 2) return Partnerships._([]);

    final partnerships = <Partnership>[
      Partnership(
        [],
        batter1Id: firstTwo.first.nextId,
        batter2Id: firstTwo.last.nextId,
      )
    ];

    for (final post in posts.sublist(posts.indexOf(firstTwo.last) + 1)) {
      final current = partnerships.last;
      switch (post) {
        case NextBatter():
          final existing = post.previousId == current.batter1Id
              ? current.batter2Id
              : current.batter1Id;
          partnerships.add(
              Partnership([], batter1Id: existing, batter2Id: post.nextId));
        default:
          current._posts.add(post);
      }
    }

    return Partnerships._(partnerships);
  }
}

class Partnership {
  final String batter1Id;
  final String batter2Id;

  final List<InningsPost> _posts;
  UnmodifiableListView<Ball> get balls =>
      UnmodifiableListView(_posts.whereType<Ball>());

  final BatterInnings batter1Innings;
  final BatterInnings batter2Innings;

  Partnership(this._posts, {required this.batter1Id, required this.batter2Id})
      : batter1Innings = BatterInnings._(batter1Id, _posts),
        batter2Innings = BatterInnings._(batter2Id, _posts);

  int get runs => balls.fold(0, (s, b) => s + b.totalRuns);
  int get numBalls => balls.where((b) => !b.isBowlingExtra).length;
}

class Over {
  final List<InningsPost> _posts = [];
  UnmodifiableListView<InningsPost> get posts => UnmodifiableListView(_posts);
  UnmodifiableListView<Ball> get balls =>
      UnmodifiableListView(_posts.whereType<Ball>());

  int get runs => balls.fold(0, (s, b) => s + b.totalRuns);

  static Map<int, Over> of(QuickInnings innings) {
    if (innings.posts.isEmpty) return {};

    final overs = <int, Over>{};

    for (final post in innings.posts) {
      final key = post.index.over + 1;
      if (!overs.containsKey(key)) {
        overs[key] = Over();
      }
      overs[key]!._posts.add(post);
    }

    return overs;
  }
}
