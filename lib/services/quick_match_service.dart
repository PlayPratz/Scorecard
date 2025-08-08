import 'package:scorecard/modules/quick_match/post_ball_and_extras_model.dart';
import 'package:scorecard/modules/quick_match/quick_match_model.dart';
import 'package:scorecard/modules/quick_match/wicket_model.dart';
import 'package:scorecard/repositories/quick_match_repository.dart';
import 'package:scorecard/services/player_service.dart';

class QuickMatchService {
  final QuickMatchRepository _matchRepository;
  final PlayerService _playerService;

  QuickMatchService(this._matchRepository, this._playerService);

  Future<QuickMatch> createQuickMatch(QuickMatchRules rules) async {
    final match = await _matchRepository.createMatch(rules);
    return match;
  }

  Future<List<QuickMatch>> loadAllQuickMatches() async {
    final matches = await _matchRepository.getAllMatches();
    return matches;
  }

  Future<QuickInnings?> loadLastInnings(QuickMatch match) async {
    final innings = await _matchRepository.loadLastInnings(match);

    if (innings != null) {
      // Load players in match
      final players = await _playerService.loadPlayersForMatch(match);
    }

    return innings;
  }

  Future<List<QuickInnings>> loadAllInnings(QuickMatch match) async {
    // print(innings.first.posts.length);
    final innings = await _matchRepository.loadAllInnings(match);

    if (innings.isNotEmpty) {
      // Load players in match
      final players = await _playerService.loadPlayersForMatch(match);
    }

    return innings;
  }

  Future<QuickInnings> createFirstInnings(QuickMatch match) async {
    final innings = QuickInnings.of(match, 1);

    await _matchRepository.createInnings(innings);

    return innings;
  }

  Future<QuickInnings> createSecondInnings(
      QuickMatch match, QuickInnings firstInnings) async {
    firstInnings.isDeclared = true;
    await _matchRepository.saveInnings(firstInnings);

    final innings = QuickInnings.of(match, 2);
    innings.target = firstInnings.runs + 1;

    await _matchRepository.createInnings(innings);

    return innings;
  }

  Future<void> endMatch(QuickMatch match, QuickInnings secondInnings) async {
    secondInnings.isDeclared = true;
    await _matchRepository.saveInnings(secondInnings);

    match.isCompleted = true;
    await _matchRepository.saveMatch(match);
  }

  // Scorecard

  /// Lists all the batters and their scores
  List<BatterInnings> getBatters(QuickInnings innings) {
    final battersIds =
        innings.posts.whereType<NextBatter>().map((nb) => nb.nextId);

    final postToBatters = {for (final id in battersIds) id: <InningsPost>[]};

    for (final post in innings.posts) {
      switch (post) {
        case Ball():
          postToBatters[post.batterId]!.add(post);
          if (post.isWicket && post.batterId != post.wicket!.batterId) {
            postToBatters[post.wicket!.batterId]!.add(post);
          }
        case BatterRetire():
          postToBatters[post.batterId]!.add(post);
        case NextBatter():
          postToBatters[post.nextId]!.add(post);
          if (post.previousId != null) {
            postToBatters[post.previousId]!.add(post);
          }
        case WicketBeforeDelivery():
          postToBatters[post.batterId]!.add(post);
        case BowlerRetire():
        case NextBowler():
        // Do nothing
      }
    }
    final batters = <BatterInnings>[
      for (final entry in postToBatters.entries)
        BatterInnings(entry.key, entry.value)
    ];

    return batters;
  }

  BatterInnings getBatterInningsOf(QuickInnings innings, String batterId) {
    final posts = <InningsPost>[];
    for (final post in innings.posts) {
      switch (post) {
        case Ball():
          if (post.batterId == batterId) {
            posts.add(post);
          }
          if (post.isWicket && post.batterId != post.wicket!.batterId) {
            posts.add(post);
          }
        case BatterRetire():
          if (post.batterId == batterId) {
            posts.add(post);
          }
        case NextBatter():
          if (post.nextId == batterId) {
            posts.add(post);
          } else if (post.previousId == batterId) {
            posts.add(post);
          }
        case WicketBeforeDelivery():
          if (post.batterId == batterId) {
            posts.add(post);
          }
        case BowlerRetire():
        case NextBowler():
        // Do nothing
      }
    }
    final batterInnings = BatterInnings(batterId, posts);
    return batterInnings;
  }

  /// Lists all the bowlers and their scores
  List<BowlerInnings> getBowlers(QuickInnings innings) {
    final bowlers = innings.posts
        .whereType<NextBowler>()
        .map((nb) => BowlerInnings.of(nb.nextId, innings))
        .toList(growable: false);
    return bowlers;
  }

  /// Creates a map of overs in the innings
  /// Note: The first over is index 1
  Map<int, Over> getOvers(QuickInnings innings) {
    final overs = <int, Over>{};
    for (final post in innings.posts) {
      final key = post.index.over + 1;
      if (!overs.containsKey(key)) {
        overs[key] = Over();
      }
      overs[key]!.posts.add(post);
    }
    return overs;
  }

  /// Lists all fall of wickets in the innings
  List<FallOfWicket> getFallOfWickets(QuickInnings innings) {
    final posts = innings.posts;
    final fallOfWickets = <FallOfWicket>[];
    Score score = Score.zero();
    for (final post in posts) {
      if (post is Ball) {
        score = score.plus(post);
        if (post.isWicket) {
          fallOfWickets.add(FallOfWicket(
            post.wicket!,
            postIndex: post.index,
            scoreAt: score,
          ));
        }
      } else if (post is WicketBeforeDelivery) {
        fallOfWickets.add(FallOfWicket(
          post.wicket,
          postIndex: post.index,
          scoreAt: score,
        ));
      }
    }
    return fallOfWickets;
  }

  // bool _isWicket(InningsPost post) => switch (post) {
  //       WicketBeforeDelivery() => true,
  //       Ball() => post.isWicket,
  //       _ => false
  //     };

  /// Lists all partnerships in the innings
  List<Partnership> getPartnerships(QuickInnings innings) {
    final posts = innings.posts;

    final firstTwo = posts.whereType<NextBatter>().take(2);
    if (firstTwo.length < 2) return [];

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
          current.posts.add(post);
      }
    }
    return partnerships;
  }

  // Innings and Posts

  /// Sets the given [batter] on strike.
  void setStrike(QuickInnings innings, String batterId) {
    if (innings.batter1Id == batterId || innings.batter2Id == batterId) {
      innings.strikerId = batterId;
    }
  }

  /// Swaps strike between the two batters.
  /// Does nothing if [innings.rules.onlySingleBatter] is set or if the last man
  /// is batting
  void swapStrike(QuickInnings innings) {
    if (innings.rules.onlySingleBatter) {
      return;
    }
    if (innings.strikerId == innings.batter1Id) {
      innings.strikerId = innings.batter2Id;
    } else {
      // Defaults to batter1 just in case none of the two batters
      // are set on strike
      innings.strikerId = innings.batter1Id;
    }
  }

  /// Retires the bowler.
  ///
  /// Call this function when a bowler retires mid-over and walks back
  /// to the pavilion.
  Future<void> retireBowler(QuickInnings innings) async {
    if (innings.bowlerId == null) return;

    final post = BowlerRetire(
      null,
      matchId: innings.matchId,
      inningsId: innings.id!,
      index: _currentIndex(innings),
      timestamp: _defaultTimestamp(innings),
      bowlerId: innings.bowlerId!,
      // retired: retired,
    );
    await _postToInnings(innings, post);
  }

  /// Adds the given [bowlerId] to the [innings]
  Future<void> nextBowler(QuickInnings innings, String nextId) async {
    // Index according to mid-over change
    final index =
        innings.balls.isEmpty || innings.posts.lastOrNull is BowlerRetire
            ? _currentIndex(innings)
            : _nextIndex(innings);

    final post = NextBowler(
      null,
      matchId: innings.matchId,
      inningsId: innings.id!,
      index: index,
      previousId: innings.bowlerId,
      timestamp: _defaultTimestamp(innings),
      nextId: nextId,
    );

    // Add post to Innings
    await _postToInnings(innings, post);
  }

  /// Retires the batter
  ///
  /// Call this function when a batter retires their innings and walks back
  /// to the pavilion.
  Future<void> retireDeclareBatter(
      QuickInnings innings, String batterId) async {
    final retired = RetiredDeclared(batterId: batterId);
    final post = BatterRetire(
      null,
      matchId: innings.matchId,
      inningsId: innings.id!,
      index: _currentIndex(innings),
      timestamp: _defaultTimestamp(innings),
      retired: retired,
    );
    await _postToInnings(innings, post);
  }

  /// Adds the given [batter] to the [innings]
  Future<void> nextBatter(QuickInnings innings,
      {required String nextId, required String? previousId}) async {
    final post = NextBatter(
      null,
      matchId: innings.matchId,
      inningsId: innings.id!,
      index: _currentIndex(innings),
      timestamp: _defaultTimestamp(innings),
      nextId: nextId,
      previousId: previousId,
    );

    // Add Post to Innings
    await _postToInnings(innings, post);
  }

  /// Creates a [Ball] of the given data and adds it to the innings
  Future<void> play(
    QuickInnings innings, {
    required int runs,
    required bool isBoundary,
    required Wicket? wicket,
    required BowlingExtraType? bowlingExtraType,
    required BattingExtraType? battingExtraType,
    // DateTime? datetime,
  }) async {
    if (innings.strikerId == null) {
      throw StateError(
          "Attempted to play ball without setting striker (matchId: ${innings.matchId}, inningsNumber: ${innings.inningsNumber})");
    }

    if (innings.bowlerId == null) {
      throw StateError(
          "Attempted to play ball without setting bowler (matchId: ${innings.matchId}, inningsNumber: ${innings.inningsNumber})");
    }

    final datetime = _defaultTimestamp(innings);

    final BowlingExtra? bowlingExtra = switch (bowlingExtraType) {
      null => null,
      BowlingExtraType.noBall => NoBall(innings.rules.noBallPenalty),
      BowlingExtraType.wide => Wide(innings.rules.widePenalty + runs),
    };

    final BattingExtra? battingExtra = switch (battingExtraType) {
      null => null,
      BattingExtraType.bye => Bye(runs),
      BattingExtraType.legBye => LegBye(runs),
    };

    // This ensures that only the runs awarded to the batter are accounted for
    // in this variable
    final int batterRuns =
        battingExtra != null || bowlingExtra is Wide ? 0 : runs;

    final index =
        bowlingExtra != null ? _currentIndex(innings) : _nextIndex(innings);

    final ball = Ball(
      null,
      matchId: innings.matchId,
      inningsId: innings.id!,
      index: index,
      bowlerId: innings.bowlerId!,
      batterId: innings.strikerId!,
      batterRuns: batterRuns,
      isBoundary: isBoundary,
      wicket: wicket,
      bowlingExtra: bowlingExtra,
      battingExtra: battingExtra,
      timestamp: datetime,
    );

    // Add Post to Innings
    await _postToInnings(innings, ball);
  }

  Future<void> _postToInnings(
      QuickInnings innings, InningsPost postWithoutId) async {
    // Create post in repository
    final post = await _matchRepository.createPost(postWithoutId);

    if (post.id == null) {
      throw StateError(
          "Attempted to insert InningsPost without an ID. (matchId: ${innings.matchId}, inningsNumber: ${innings.inningsNumber})");
    }

    // Add post to innings
    innings.posts.add(post);

    switch (post) {
      case Ball():
        _handleBallPost(innings, post);
      case BowlerRetire():
        _handleBowlerRetirePost(innings, post);
      case NextBowler():
        _handleNextBowlerPost(innings, post);
      case BatterRetire():
        _handleBatterRetirePost(innings, post);
      case NextBatter():
        _handleNextBatterPost(innings, post);
      case WicketBeforeDelivery():
        _handleWicketBeforeDeliveryPost(innings, post);
    }

    // Update the innings in the Database
    await _matchRepository.saveInnings(innings);
  }

  void _handleBallPost(QuickInnings innings, Ball ball) {
    // Swap strike for odd number of runs
    if (ball.batterRuns % 2 == 1 || ball.battingExtraRuns % 2 == 1) {
      swapStrike(innings);
    }

    // Swap strike whenever an over completes
    if (ball.index.ball == innings.rules.ballsPerOver) swapStrike(innings);
  }

  void _undoBallPost(QuickInnings innings, Ball ball) {
    // Swap strike for odd number of runs
    if (ball.batterRuns % 2 == 1 || ball.battingExtraRuns % 2 == 1) {
      swapStrike(innings);
    }

    // Swap strike whenever an over completes
    if (ball.index.ball == innings.rules.ballsPerOver) swapStrike(innings);
  }

  void _handleBowlerRetirePost(QuickInnings innings, BowlerRetire post) {
    // Nothing to be done
  }

  void _undoBowlerRetirePost(QuickInnings innings, BowlerRetire post) {
    // Nothing to be done
  }

  void _handleNextBowlerPost(QuickInnings innings, NextBowler post) {
    // Change the current bowler
    innings.bowlerId = post.nextId;
  }

  void _undoNextBowlerPost(QuickInnings innings, NextBowler post) {
    // Set the correct bowler in the innings
    //
    // If a previous bowler exists, they will be set
    // If not, null is set, which means the user will pick a bowler
    innings.bowlerId = post.previousId;
  }

  void _handleBatterRetirePost(QuickInnings innings, BatterRetire post) {
    if (innings.strikerId == post.batterId) {
      innings.strikerId = null;
    }
  }

  void _undoBatterRetirePost(QuickInnings innings, BatterRetire post) {
    innings.strikerId ??= post.batterId;
  }

  void _handleNextBatterPost(QuickInnings innings, NextBatter post) {
    if (innings.batter1Id == null || innings.batter1Id == post.previousId) {
      // If batter1 is not set or batter1 is replaced
      innings.batter1Id = post.nextId;
    } else if (!innings.rules.onlySingleBatter &&
        (innings.batter2Id == null || innings.batter2Id == post.previousId)) {
      // If batter2 is allowed and (batter2 is not set or batter2 is replaced)
      innings.batter2Id = post.nextId;
    } else {
      throw StateError(
          "Attempted to add a new batter without replacing existing");
    }

    // Set strike

    // if(post.previousId == innings.strikerId) {
    //   innings.strikerId = post.nextId;
    // }

    if (innings.strikerId == null ||
        innings.strikerId != innings.batter1Id &&
            innings.strikerId != innings.batter2Id) {
      setStrike(innings, post.nextId);
    }
  }

  void _undoNextBatterPost(QuickInnings innings, NextBatter post) {
    // Set the correct batter in the innings
    if (post.nextId == innings.batter1Id) {
      innings.batter1Id = post.previousId;
    } else if (post.nextId == innings.batter2Id) {
      innings.batter2Id = post.previousId;
    }
  }

  void _handleWicketBeforeDeliveryPost(
      QuickInnings innings, WicketBeforeDelivery post) {
    // Nothing to be done
  }

  void _undoWicketBeforeDeliveryPost(
      QuickInnings innings, WicketBeforeDelivery post) {
    // Nothing to be done
  }

  Future<void> undoPostFromInnings(QuickInnings innings) async {
    if (innings.posts.isEmpty) return;

    final post = innings.posts.removeLast();

    if (post.id == null) {
      throw StateError(
          "Attempted to delete InningsPost without an ID. (matchId: ${innings.matchId}, inningsNumber: ${innings.inningsNumber})");
    }

    await _matchRepository.deletePost(post.id!);

    switch (post) {
      case Ball():
        _undoBallPost(innings, post);
      case BowlerRetire():
        _undoBowlerRetirePost(innings, post);
      case NextBowler():
        _undoNextBowlerPost(innings, post);
      case BatterRetire():
        _undoBatterRetirePost(innings, post);
      case NextBatter():
        _undoNextBatterPost(innings, post);
      case WicketBeforeDelivery():
        _undoWicketBeforeDeliveryPost(innings, post);
    }
  }

  DateTime _defaultTimestamp(QuickInnings innings) => DateTime.timestamp();

  PostIndex _currentIndex(QuickInnings innings) {
    if (innings.posts.isEmpty) {
      // First post
      return const PostIndex.zero();
    }
    return innings.posts.last.index;
  }

  PostIndex _nextIndex(QuickInnings innings) {
    final currentIndex = _currentIndex(innings);

    if (currentIndex.ball == innings.rules.ballsPerOver) {
      return PostIndex(currentIndex.over + 1, 0);
    } else {
      return PostIndex(currentIndex.over, currentIndex.ball + 1);
    }
  }
}

/// Types of Bowling Extras
enum BowlingExtraType { noBall, wide }

/// Types of Batting Extras
enum BattingExtraType { bye, legBye }
