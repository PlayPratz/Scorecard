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

  Future<QuickInnings> createInnings(QuickMatch match,
      {QuickInnings? previous}) async {
    if (previous != null && !previous.hasEnded) {
      throw StateError(
          "Attempted to create new innings without ending previous (matchId: ${match.id} inningsId: ${previous.id}");
    }

    if (previous != null) {
      await _matchRepository.saveInnings(previous);
    }

    final inningsNumber = previous != null ? previous.inningsNumber + 1 : 1;

    final innings = QuickInnings.of(match, inningsNumber);

    if (previous != null && previous.target == null) {
      innings.target = previous.runs + 1;
    }

    await _matchRepository.createInnings(innings);

    return innings;
  }

  Future<NextStage> declareInnings(QuickInnings innings) async {
    innings.isDeclared = true;
    await _matchRepository.saveInnings(innings);

    return getNextState(innings);
  }

  NextStage getNextState(QuickInnings innings) {
    if (innings.target == null) {
      return NextStage.nextInnings;
    } else if (innings.runs == innings.target! - 1) {
      return NextStage.superOver;
    } else {
      return NextStage.endMatch;
    }
  }

  Future<QuickInnings> createSuperOver(QuickMatch match,
      {required QuickInnings previous}) async {
    if (!previous.hasEnded) {
      throw StateError(
          "Attempted to create new innings without ending previous (matchId: ${match.id} inningsId: ${previous.id})");
    }
    final innings = QuickInnings.superOverOf(match, previous.inningsNumber + 1);
    if (previous.isSuperOver && previous.target == null) {
      innings.target = previous.runs + 1;
    }
    await _matchRepository.createInnings(innings);
    return innings;
  }

  Future<void> endMatch(QuickMatch match, {required QuickInnings last}) async {
    if (!last.hasEnded) {
      throw StateError(
          "Attempted to end match without ending last innings (matchId: ${match.id} inningsId: ${last.id})");
    }

    await _matchRepository.saveInnings(last);

    match.isCompleted = true;
    await _matchRepository.saveMatch(match);
  }

  QuickMatchResult generateResult(QuickMatch match,
      {required QuickInnings last}) {
    // if (match.isCompleted == false) {
    //   throw StateError(
    //       "Attempted to generate result for an incomplete match (matchId: ${match.id} inningsId: ${last.id})");
    // }

    if (last.target == null) {
      throw StateError(
          "Last Innings does not have target (matchId: ${match.id} inningsId: ${last.id})");
    }

    final firstRuns = last.target! - 1;

    if (firstRuns > last.runs) {
      return QuickMatchDefendedResult(firstRuns - last.runs);
    } else if (firstRuns < last.runs) {
      return QuickMatchChasedResult(last.ballsLeft);
    } else {
      return QuickMatchTieResult();
    }
  }

  // Scorecard

  /// Lists all the batters and their scores
  List<BatterInnings> getBatters(QuickInnings innings, {combine = true}) {
    final batters = <BatterInnings>[];

    final batterMap = <String, List<InningsPost>>{};

    for (final post in innings.posts) {
      switch (post) {
        case NextBatter():
          if (!combine || !batterMap.containsKey(post.nextId)) {
            batterMap[post.nextId] = <InningsPost>[];
            batters.add(BatterInnings(post.nextId, batterMap[post.nextId]!));
          }

          batterMap[post.nextId]!.add(post);
          if (post.previousId != null) {
            batterMap[post.previousId]!.add(post);
          }
        case Ball():
          batterMap[post.batterId]!.add(post);
          if (post.isWicket && post.batterId != post.wicket!.batterId) {
            batterMap[post.wicket!.batterId]!.add(post);
          }
        case BatterRetire():
          batterMap[post.batterId]!.add(post);

        case WicketBeforeDelivery():
          batterMap[post.batterId]!.add(post);
        case BowlerRetire():
        case NextBowler():
        case Penalty():
        // Do nothing
      }
    }
    /*   final batters = <BatterInnings>[
      for (final entry in batterMap.entries)
        BatterInnings(entry.key, entry.value)
    ];
*/
    return batters;
  }

  // List<BatterInnings> getBatters(QuickInnings innings) {
  //   final battersIds =
  //   innings.posts.whereType<NextBatter>().map((nb) => nb.nextId);
  //
  //   final postToBatters = {for (final id in battersIds) id: <InningsPost>[]};
  //
  //   for (final post in innings.posts) {
  //     switch (post) {
  //       case Ball():
  //         postToBatters[post.batterId]!.add(post);
  //         if (post.isWicket && post.batterId != post.wicket!.batterId) {
  //           postToBatters[post.wicket!.batterId]!.add(post);
  //         }
  //       case BatterRetire():
  //         postToBatters[post.batterId]!.add(post);
  //       case NextBatter():
  //         postToBatters[post.nextId]!.add(post);
  //         if (post.previousId != null) {
  //           postToBatters[post.previousId]!.add(post);
  //         }
  //       case WicketBeforeDelivery():
  //         postToBatters[post.batterId]!.add(post);
  //       case BowlerRetire():
  //       case NextBowler():
  //       // Do nothing
  //     }
  //   }
  //   final batters = <BatterInnings>[
  //     for (final entry in postToBatters.entries)
  //       BatterInnings(entry.key, entry.value)
  //   ];
  //
  //   return batters;
  // }

  BatterInnings getLastBatterInningsOf(QuickInnings innings, String batterId) {
    final newBatterPostIndex = innings.posts
        .lastIndexWhere((b) => b is NextBatter && b.nextId == batterId);

    if (newBatterPostIndex == 1) return BatterInnings(batterId, []);

    final posts = <InningsPost>[];

    for (final post in innings.posts.sublist(newBatterPostIndex)) {
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
        case Penalty():
        // Do nothing
      }
    }

    final batterInnings = BatterInnings(batterId, posts);
    return batterInnings;
  }

  /// Lists all the bowlers and their scores
  List<BowlerInnings> getBowlers(QuickInnings innings) {
    final bowlerMap = <String, List<Ball>>{};
    for (final ball in innings.balls) {
      final bowlerId = ball.bowlerId;
      if (!bowlerMap.containsKey(bowlerId)) {
        bowlerMap[bowlerId] = <Ball>[];
      }
      bowlerMap[bowlerId]!.add(ball);
    }

    final bowlers = <BowlerInnings>[];
    for (final bowlerId in bowlerMap.keys) {
      bowlers.add(BowlerInnings(
        bowlerId,
        bowlerMap[bowlerId]!,
        ballsPerOver: innings.ballsPerOver,
      ));
    }
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
  /// Does nothing if [innings.rules.isSolo] is set or if the last man
  /// is batting
  void swapStrike(QuickInnings innings) {
    if (innings.batter1Id == null && innings.batter2Id == null) {
      return;
    }

    if (innings.batter2Id == null) {
      innings.strikerId = innings.batter2Id;
    } else if (innings.batter1Id == null) {
      innings.strikerId = innings.batter1Id;
    } else {
      // Both batters have been set

      if (innings.strikerId == innings.batter1Id) {
        innings.strikerId = innings.batter2Id;
      } else {
        // Defaults to batter1 just in case none of the two batters
        // are set on strike
        innings.strikerId = innings.batter1Id;
      }
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
      inningsNumber: innings.inningsNumber,
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
      inningsNumber: innings.inningsNumber,
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
      inningsNumber: innings.inningsNumber,
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
      inningsNumber: innings.inningsNumber,
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
    required bool autoRotateStrike,
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
      BowlingExtraType.noBall => NoBall(innings.noBallPenalty),
      BowlingExtraType.wide => Wide(innings.widePenalty + runs),
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
      inningsNumber: innings.inningsNumber,
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
      case Penalty():
        _handlePenaltyPost(innings, post);
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
    if (ball.index.ball == innings.ballsPerOver) swapStrike(innings);
  }

  void _undoBallPost(QuickInnings innings, Ball ball) {
    // Swap strike for odd number of runs
    if (ball.batterRuns % 2 == 1 || ball.battingExtraRuns % 2 == 1) {
      swapStrike(innings);
    }

    // Swap strike whenever an over completes
    if (ball.index.ball == innings.ballsPerOver) swapStrike(innings);
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
    } else if (innings.batter2Id == null ||
        innings.batter2Id == post.previousId) {
      // If batter2 is not set or batter2 is replaced
      innings.batter2Id = post.nextId;
    } else {
      throw StateError(
          "Attempted to add a new batter without replacing existing!");
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

  void _handlePenaltyPost(QuickInnings innings, Penalty post) {
    // Nothing to be done
  }

  void _undoPenaltyPost(QuickInnings innings, Penalty post) {
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
      case Penalty():
        _undoPenaltyPost(innings, post);
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

    if (currentIndex.ball == innings.ballsPerOver) {
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

/// Next State
enum NextStage { nextInnings, superOver, endMatch }
