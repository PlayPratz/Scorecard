import 'dart:collection';

import 'package:scorecard/handlers/ulid_handler.dart';
import 'package:scorecard/modules/quick_match/post_ball_and_extras_model.dart';
import 'package:scorecard/modules/quick_match/quick_match_model.dart';
import 'package:scorecard/modules/quick_match/wicket_model.dart';
import 'package:scorecard/repositories/quick_match_repository.dart';

class QuickMatchService {
  final IQuickMatchRepository _matchRepository;

  QuickMatchService(this._matchRepository);

  Future<QuickMatch> createQuickMatch(QuickMatchRules rules) async {
    final match = QuickMatch(
      id: null,
      handle: UlidHandler.generate(),
      startsAt: DateTime.now(),
      rules: rules,
      stage: 0, // TODO
    );

    final newMatch = await _matchRepository.createMatch(match);
    return newMatch;
  }

  Future<void> deleteQuickMatch(QuickMatch match) async {
    await _matchRepository.deleteMatch(match);
  }

  Future<List<QuickMatch>> getAllQuickMatches() async {
    final matches = await _matchRepository.loadAllMatches();
    return matches;
  }

  Future<QuickMatch> getMatch(int matchId) async {
    final match = await _matchRepository.loadMatch(matchId);
    return match;
  }

  Future<List<QuickInnings>> getAllInningsOf(int matchId) async {
    final innings = await _matchRepository.loadAllInningsOf(matchId);
    return innings;
  }

  Future<QuickInnings> getInnings(int id) async {
    final innings = await _matchRepository.loadInnings(id);
    return innings;
  }

  Future<UnmodifiableListView<InningsPost>> getAllPostsOf(
      QuickInnings innings) async {
    final posts = await _matchRepository.loadAllPostsOf(innings);
    return posts;
  }

  Future<InningsPost?> getLastPostOf(QuickInnings innings) async {
    final post = await _matchRepository.loadLastPostOf(innings);
    return post;
  }

  Future<UnmodifiableListView<Ball>> getAllBallsOf(QuickInnings innings) async {
    final posts = await _matchRepository.loadAllBallsOf(innings);
    return posts;
  }

  Future<UnmodifiableListView<Ball>> getRecentBallsOf(
      QuickInnings innings) async {
    final posts = await _matchRepository.loadRecentBallsOf(innings, 10);
    return posts;
  }

  Future<QuickInnings> createFirstInnings(QuickMatch match) async {
    final innings =
        await _matchRepository.createInnings(QuickInnings.first(match));
    return innings;
  }

  Future<QuickInnings> createNextInnings(QuickInnings previous) async {
    if (previous.type == 6) {
      return createSuperOver(previous);
    }
    await _matchRepository.updateInnings(previous);
    final innings =
        await _matchRepository.createInnings(QuickInnings.next(previous));
    return innings;
  }

  Future<NextStage> declareInnings(QuickInnings innings) async {
    innings.status = 9; // TODO
    await _matchRepository.updateInnings(innings);
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

  Future<QuickInnings> createSuperOver(QuickInnings previous) async {
    final innings = QuickInnings.nextSuperOver(previous);
    if (previous.isSuperOver && previous.target == null) {
      innings.target = previous.runs + 1;
    }
    await _matchRepository.createInnings(innings);
    return innings;
  }

  Future<void> endMatch(QuickInnings last) async {
    await _matchRepository.updateInnings(last);
    final match = await _matchRepository.loadMatch(last.matchId);
    match.stage = 9; //TODO define
    await _matchRepository.updateMatch(match);
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
  Future<UnmodifiableListView<BattingScore>> getBatters(
      QuickInnings innings) async {
    final battingScores = await _matchRepository.loadBattersOf(innings);
    return battingScores;
  }

  Future<BattingScore?> getLastBattingScoreOf(
      QuickInnings innings, int playerId) async {
    final battingScore =
        await _matchRepository.loadLastBattingScoreOf(innings, playerId);

    return battingScore;
  }

  /// Lists all the bowlers and their scores
  Future<UnmodifiableListView<BowlingScore>> getBowlers(
      QuickInnings innings) async {
    final bowlingScores = await _matchRepository.loadBowlersOf(innings);
    return bowlingScores;
  }

  Future<BowlingScore?> getBowlingScoreOf(
      QuickInnings innings, int playerId) async {
    final bowlingScore =
        await _matchRepository.loadBowlingScoreOf(innings, playerId);
    return bowlingScore;
  }

  /// Creates a map of overs in the innings
  /// Note: The first over is index 1
  Future<Map<int, Over>> getOvers(QuickInnings innings) async {
    // final overs = await _matchRepository.loadOversOf(innings);
    // final map = <int, Over>{for (final o in overs) o.overNumber: o};
    // return map;

    final posts = await _matchRepository.loadAllPostsOf(innings);
    return getOversFromPosts(posts);
  }

  Map<int, Over> getOversFromPosts(Iterable<InningsPost> posts) {
    final overs = <int, Over>{};
    for (final post in posts) {
      final key = post.index.over + 1;
      if (!overs.containsKey(key)) {
        overs[key] = Over(key);
      }
      overs[key]!.posts.add(post);
    }
    return overs;
  }

  /// Lists all fall of wickets in the innings
  Future<UnmodifiableListView<FallOfWicket>> getWicketsOf(
      QuickInnings innings) async {
    final wickets = _matchRepository.loadWicketsOf(innings);
    return wickets;
  }

  /// Lists all partnerships in the innings
  Future<UnmodifiableListView<Partnership>> getPartnerships(
      QuickInnings innings) async {
    return UnmodifiableListView(
        await _generatePartnerships(innings)); // TODO temporary
  }

  Future<List<Partnership>> _generatePartnerships(QuickInnings innings) async {
    final balls = await _matchRepository.loadAllBallsOf(innings);

    final partnerships = <Partnership>[];
    final current = <Ball>[];

    for (final b in balls) {
      current.add(b);

      if (b.isWicket || b.id == balls.last.id) {
        final batter1 = current.first.batterId!;
        final batter2 = current.first.nonStrikerId;

        final batter1Balls = current.where((b) => b.batterId == batter1);
        final batter2Balls = batter2 == null
            ? null
            : current.where((b) => b.batterId == batter2);

        partnerships.add(
          Partnership(
            id: null,
            matchId: innings.matchId,
            inningsId: innings.id!,
            inningsNumber: innings.inningsNumber,
            inningsType: innings.type,
            runs: current.fold(0, (sum, b) => sum + b.totalRuns),
            balls: current.where((b) => !b.isBowlingExtra).length,
            partnershipNumber: partnerships.length + 1,
            batter1Id: current.first.batterId!,
            batter1Runs: batter1Balls.fold(0, (sum, b) => sum + b.batterRuns),
            batter1Balls:
                batter1Balls.where((b) => BowlingExtra is! Wide).length,
            batter2Id: batter2,
            batter2Runs: batter2 == null
                ? 0
                : batter2Balls!.fold(0, (sum, b) => sum + b.batterRuns),
            batter2Balls: batter2 == null
                ? 0
                : batter2Balls!.where((b) => BowlingExtra is! Wide).length,
            extras: Extras(
                noBalls: current.where((b) => b.bowlingExtra is NoBall).length,
                wides: current.where((b) => b.bowlingExtra is Wide).length,
                byes: current.where((b) => b.battingExtra is Bye).length,
                legByes: current.where((b) => b.battingExtra is LegBye).length,
                penalties: 0 // TODO
                ),
          ),
        );

        current.clear();
      }
    }

    return partnerships;
  }

  // List<Partnership> getPartnerships(QuickInnings innings) {
  //   final posts = innings.posts;
  //
  //   final firstTwo = posts.whereType<NextBatter>().take(2);
  //   if (firstTwo.length < 2) return [];
  //
  //   final partnerships = <Partnership>[
  //     Partnership(
  //       [],
  //       batter1Id: firstTwo.first.nextId,
  //       batter2Id: firstTwo.last.nextId,
  //     )
  //   ];
  //
  //   for (final post in posts.sublist(posts.indexOf(firstTwo.last) + 1)) {
  //     final current = partnerships.last;
  //     switch (post) {
  //       case NextBatter():
  //         final existing = post.previousId == current.batter1Id
  //             ? current.batter2Id
  //             : current.batter1Id;
  //         partnerships.add(
  //             Partnership([], batter1Id: existing, batter2Id: post.nextId));
  //       default:
  //         current.posts.add(post);
  //     }
  //   }
  //   return partnerships;
  // }

  // Innings and Posts

  Future<bool> canUndo(QuickInnings innings) async {
    final count = await _matchRepository.loadPostCount(innings);
    return count > 0;
  }

  /// Sets the given [batter] on strike.
  Future<void> setStrike(QuickInnings innings, int slot) async {
    innings.striker = slot;
    await _matchRepository.updateInnings(innings);
  }

  /// Swaps strike between the two batters.
  Future<void> swapStrike(QuickInnings innings) async {
    if (innings.batter2Id == null) {
      innings.striker = 1;
    } else {
      innings.striker = innings.striker % 2 + 1;
    }
    await _matchRepository.updateInnings(innings);
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
      bowlerId: innings.bowlerId,
      batterId: innings.strikerId,
      nonStrikerId: innings.nonStrikerId,
      scoreAt: Score.zero(),
    );
    await _postToInnings(innings, post);
  }

  /// Adds the given [bowlerId] to the [innings]
  Future<void> nextBowler(QuickInnings innings, int nextId) async {
    final post = NextBowler(
      null,
      matchId: innings.matchId,
      inningsId: innings.id!,
      inningsNumber: innings.inningsNumber,
      index: _currentIndex(innings),
      timestamp: _defaultTimestamp(innings),
      bowlerId: innings.bowlerId,
      batterId: innings.strikerId,
      nonStrikerId: innings.nonStrikerId,
      nextId: nextId,
      scoreAt: Score.zero(),
    );

    // Add post to Innings
    await _postToInnings(innings, post);
  }

  /// Retires the batter
  ///
  /// Call this function when a batter retires their innings and walks back
  /// to the pavilion.
  Future<void> retireBatter(QuickInnings innings, int batterId) async {
    final retired = RetiredNotOut(batterId: batterId);
    final post = BatterRetire(
      null,
      matchId: innings.matchId,
      inningsId: innings.id!,
      inningsNumber: innings.inningsNumber,
      index: _currentIndex(innings),
      timestamp: _defaultTimestamp(innings),
      bowlerId: innings.bowlerId!,
      batterId: innings.strikerId,
      nonStrikerId: innings.nonStrikerId,
      scoreAt: Score.zero(),
      retired: retired,
    );
    await _postToInnings(innings, post);
  }

  /// Adds the given [batter] to the [innings]
  Future<void> nextBatter(QuickInnings innings,
      {required int nextId, required int? previousId}) async {
    final post = NextBatter(null,
        matchId: innings.matchId,
        inningsId: innings.id!,
        inningsNumber: innings.inningsNumber,
        index: _currentIndex(innings),
        timestamp: _defaultTimestamp(innings),
        bowlerId: innings.bowlerId,
        batterId: innings.strikerId,
        nonStrikerId: innings.nonStrikerId,
        scoreAt: Score.zero(),
        nextId: nextId,
        previousId: previousId);

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
    int noBallPenalty = 1,
    // DateTime? datetime,
  }) async {
    final strikerId = switch (innings.striker) {
      1 => innings.batter1Id,
      2 => innings.batter2Id,
      _ => null,
    };

    if (strikerId == null) {
      throw StateError(
          "Attempted to play ball without setting striker (matchId: ${innings.matchId}, inningsNumber: ${innings.inningsNumber})");
    }

    if (innings.batter1Id == null && innings.batter2Id == null) {
      throw StateError(
          "Attempted to play ball without setting batter(s) (matchId: ${innings.matchId}, inningsNumber: ${innings.inningsNumber})");
    }

    if (innings.bowlerId == null) {
      throw StateError(
          "Attempted to play ball without setting bowler (matchId: ${innings.matchId}, inningsNumber: ${innings.inningsNumber})");
    }

    final BowlingExtra? bowlingExtra = switch (bowlingExtraType) {
      null => null,
      BowlingExtraType.noBall => NoBall(noBallPenalty),
      BowlingExtraType.wide => Wide(1 + runs),
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
      timestamp: _defaultTimestamp(innings),
      bowlerId: innings.bowlerId!,
      batterId: innings.strikerId,
      nonStrikerId: innings.nonStrikerId,
      scoreAt: Score.zero(),
      batterRuns: batterRuns,
      isBoundary: isBoundary,
      battingExtra: battingExtra,
      bowlingExtra: bowlingExtra,
      wicket: wicket,
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

    switch (post) {
      case Ball():
        await _handleBallPost(innings, post);
      case BowlerRetire():
        await _handleBowlerRetirePost(innings, post);
      case NextBowler():
        await _handleNextBowlerPost(innings, post);
      case BatterRetire():
        await _handleBatterRetirePost(innings, post);
      case NextBatter():
        await _handleNextBatterPost(innings, post);
      case WicketBeforeDelivery():
        await _handleWicketBeforeDeliveryPost(innings, post);
      case Penalty():
        await _handlePenaltyPost(innings, post);
      case Break():
    }

    await _matchRepository.updateInnings(innings);
  }

  Future<void> _handleBallPost(QuickInnings innings, Ball ball) async {
    // Swap strike for odd number of runs
    if (ball.batterRuns % 2 == 1 || ball.battingExtraRuns % 2 == 1) {
      await swapStrike(innings);
    }

    // Swap strike whenever an over completes
    if (ball.index.ball == innings.ballsPerOver) await swapStrike(innings);

    await _matchRepository.updateInnings(innings);
  }

  Future<void> _undoBallPost(QuickInnings innings, Ball ball) async {
    // Swap strike for odd number of runs
    if (ball.batterRuns % 2 == 1 || ball.battingExtraRuns % 2 == 1) {
      await swapStrike(innings);
    }

    // Swap strike whenever an over completes
    if (ball.index.ball == innings.ballsPerOver) await swapStrike(innings);

    await _matchRepository.updateInnings(innings);
  }

  Future<void> _handleBowlerRetirePost(
      QuickInnings innings, BowlerRetire post) async {
    // Nothing to be done
  }

  Future<void> _undoBowlerRetirePost(
      QuickInnings innings, BowlerRetire post) async {
    // Nothing to be done
  }

  Future<void> _handleNextBowlerPost(
      QuickInnings innings, NextBowler post) async {
    // Change the current bowler
    innings.bowlerId = post.nextId;
    await _matchRepository.updateInnings(innings);

    // Create Bowling Score
    final bowlingScore =
        await _matchRepository.loadBowlingScoreOf(innings, post.nextId);
    if (bowlingScore == null) {
      _matchRepository.createBowlingScore(BowlingScore(
        id: null,
        matchId: innings.matchId,
        inningsId: innings.id!,
        inningsNumber: innings.inningsNumber,
        inningsType: innings.type,
        bowlerId: post.nextId,
        ballsBowled: -1,
        runsConceded: -1,
        wicketsTaken: -1,
        noBallsBowled: -1,
        widesBowled: -1,
        extrasBowled: -1,
        economy: -1,
      ));
    }
  }

  Future<void> _undoNextBowlerPost(
      QuickInnings innings, NextBowler post) async {
    // Set the correct bowler in the innings
    //
    // If a previous bowler exists, they will be set
    // If not, null is set, which means the user will pick a bowler
    innings.bowlerId = post.bowlerId;
    await _matchRepository.updateInnings(innings);

    final bowlingScore =
        await _matchRepository.loadBowlingScoreOf(innings, post.nextId);
    if (bowlingScore != null) {
      _matchRepository.deleteBowlingScore(bowlingScore.id!);
    }
  }

  Future<void> _handleBatterRetirePost(
      QuickInnings innings, BatterRetire post) async {
    // Nothing to be done
  }

  Future<void> _undoBatterRetirePost(
      QuickInnings innings, BatterRetire post) async {
    // Nothing to be done
  }

  Future<void> _handleNextBatterPost(
      QuickInnings innings, NextBatter post) async {
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
    await _matchRepository.updateInnings(innings);

    // Create batting score
    final battingScore = BattingScore(
      id: null,
      matchId: innings.matchId,
      inningsId: innings.id!,
      inningsNumber: innings.inningsNumber,
      inningsType: innings.type,
      batterId: post.nextId,
      battingAt: -1,
      runsScored: -1,
      ballsFaced: -1,
      isNotOut: true,
      wicket: null,
      fours: -1,
      sixes: -1,
      boundaries: -1,
      strikeRate: -1,
    );
    await _matchRepository.createBattingScore(battingScore);

    // Create partnership
    // final partnership = Partnership(
    //   runs: -1,
    //   balls: -1,
    //   wicketNumber: -1,
    //   batter1Id: ,
    //   batter1Runs: -1,
    //   batter1Balls: -1,
    //   batter2Id: ,
    //   batter2Runs: -1,
    //   batter2Balls: -1,
    // );
  }

  Future<void> _undoNextBatterPost(
      QuickInnings innings, NextBatter post) async {
    // Set the correct batter in the innings
    if (post.nextId == innings.batter1Id) {
      innings.batter1Id = post.previousId;
    } else if (post.nextId == innings.batter2Id) {
      innings.batter2Id = post.previousId;
    }

    await _matchRepository.updateInnings(innings);

    final battingScore =
        await _matchRepository.loadLastBattingScoreOf(innings, post.nextId);
    if (battingScore != null) {
      await _matchRepository.deleteBattingScore(battingScore.id!);
    }
  }

  Future<void> _handleWicketBeforeDeliveryPost(
      QuickInnings innings, WicketBeforeDelivery post) async {
    // Nothing to be done
  }

  Future<void> _undoWicketBeforeDeliveryPost(
      QuickInnings innings, WicketBeforeDelivery post) async {
    // Nothing to be done
  }

  Future<void> _handlePenaltyPost(QuickInnings innings, Penalty post) async {
    // Nothing to be done
  }

  Future<void> _undoPenaltyPost(QuickInnings innings, Penalty post) async {
    // Nothing to be done
  }

  Future<void> undoPostFromInnings(
      QuickInnings innings, InningsPost post) async {
    await _matchRepository.deletePost(post);

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
      case Break():
    }
  }

  DateTime _defaultTimestamp(QuickInnings innings) => DateTime.timestamp();

  PostIndex _currentIndex(QuickInnings innings) =>
      PostIndex.of(innings.balls, innings.ballsPerOver);
  PostIndex _nextIndex(QuickInnings innings) {
    final current = _currentIndex(innings);
    return PostIndex(current.over, current.ball + 1);
  }
}

/// Types of Bowling Extras
enum BowlingExtraType { noBall, wide }

/// Types of Batting Extras
enum BattingExtraType { bye, legBye }

/// Next State
enum NextStage { nextInnings, superOver, endMatch }
