import 'package:scorecard/cache/player_cache.dart';
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
    final batters = innings.posts
        .whereType<NextBatter>()
        .map((nb) => BatterInnings.of(nb.nextId, innings))
        .toList(growable: false);
    return batters;
  }

  /// Lists all the bowlers and their scores
  List<BowlerInnings> getBowlers(QuickInnings innings) {
    final bowlers = innings.posts
        .whereType<NextBowler>()
        .map((nb) => BowlerInnings.of(nb.nextId, innings))
        .toList(growable: false);
    return bowlers;
  }

  Map<int, Iterable<InningsPost>> getOvers(QuickInnings innings) {
    if (innings.posts.isEmpty) return {};

    final overs = <int, List<InningsPost>>{};
    for (final post in innings.posts) {
      final overIndex = post.index.over + 1;
      if (!overs.containsKey(overIndex)) {
        overs[overIndex] = [];
      }
      overs[overIndex]!.add(post);
    }

    return overs;
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
      innings.matchId,
      innings.inningsNumber,
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
      innings.matchId,
      innings.inningsNumber,
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
    final post = BatterRetire(null, innings.matchId, innings.inningsNumber,
        index: _currentIndex(innings),
        timestamp: _defaultTimestamp(innings),
        retired: retired);
    await _postToInnings(innings, post);
  }

  /// Adds the given [batter] to the [innings]
  Future<void> nextBatter(QuickInnings innings,
      {required String nextId, required String? previousId}) async {
    final post = NextBatter(null, innings.matchId, innings.inningsNumber,
        index: _currentIndex(innings),
        timestamp: _defaultTimestamp(innings),
        nextId: nextId,
        previousId: previousId);

    // Add Post to Innings
    await _postToInnings(innings, post);
  }

  /// Creates a [Ball] of the given data and adds it to the innings
  Future<void> play(
    QuickInnings innings, {
    required String bowlerId,
    required String batterId,
    required int runs,
    required bool isBoundary,
    required Wicket? wicket,
    required BowlingExtraType? bowlingExtraType,
    required BattingExtraType? battingExtraType,
    // DateTime? datetime,
  }) async {
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
      innings.matchId,
      innings.inningsNumber,
      index: index,
      bowlerId: bowlerId,
      batterId: batterId,
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
      case RunoutBeforeDelivery():
        _handleRunoutBeforeDeliveryPost(innings, post);
    }

    // Update the innings in the Database
    await _matchRepository.saveInnings(innings);
  }

  void _handleBallPost(QuickInnings innings, Ball ball) {
    // Swap strike for odd number of runs
    if (ball.batterRuns % 2 == 1) swapStrike(innings);

    // Swap strike whenever an over completes
    if (ball.index.ball == innings.rules.ballsPerOver) swapStrike(innings);
  }

  void _undoBallPost(QuickInnings innings, Ball ball) {
    // Swap strike for odd number of runs
    if (ball.batterRuns % 2 == 1) swapStrike(innings);

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

  void _handleRunoutBeforeDeliveryPost(
      QuickInnings innings, RunoutBeforeDelivery post) {
    // Nothing to be done
  }

  void _undoRunoutBeforeDeliveryPost(
      QuickInnings innings, RunoutBeforeDelivery post) {
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
      case RunoutBeforeDelivery():
        _undoRunoutBeforeDeliveryPost(innings, post);
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
