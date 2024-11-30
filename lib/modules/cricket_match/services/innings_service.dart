import 'package:scorecard/modules/cricket_match/models/innings_model.dart';
import 'package:scorecard/modules/cricket_match/models/wicket_model.dart';
import 'package:scorecard/modules/player/player_model.dart';

/// Handles the business logic for all operations related to an [Innings].
class InningsService {
  InningsService._();
  static final _instance = InningsService._();
  factory InningsService() => _instance;

  /// Sets the given [batter] on strike.
  void setStrike(Innings innings, BatterInnings batter) {
    if (innings.batter1 == batter || innings.batter2 == batter) {
      innings.striker = batter;
    }
  }

  /// Swaps strike between the two batters.
  /// Does nothing if [innings.rules.onlySingleBatter] is set or if the last man
  /// is batting
  void swapStrike(Innings innings) {
    if (innings.rules.onlySingleBatter) {
      return;
    }
    if (innings.striker == innings.batter1) {
      innings.striker = innings.batter2;
    } else {
      // Defaults to batter1 just in case none of the two batters
      // are set on strike
      innings.striker = innings.batter1;
    }
  }

  /// Retires the [bowlerInnings].
  ///
  /// Call this function when a bowler retires mid-over and walks back
  /// to the pavilion.
  void retireBowlerInnings(Innings innings, BowlerInnings bowlerInnings) {
    _postToInnings(
      innings,
      BowlerRetire(
        index: _currentIndex(innings),
        bowler: bowlerInnings.player,
        // retired: retired,
      ),
    );
  }

  /// Adds the given [bowler] to the [innings]
  void nextBowler(Innings innings, Player bowler) {
    // Index according to mid-over change
    final index =
        innings.balls.isEmpty || innings.posts.lastOrNull is BowlerRetire
            ? _currentIndex(innings)
            : _nextIndex(innings);

    // Add post to Innings
    _postToInnings(
        innings,
        NextBowler(
          index: index,
          previous: innings.bowler?.player,
          next: bowler,
          // isMidOverChange: innings.posts.last is BowlerRetire,
        ));
  }

  /// Creates a new [BowlerInnings] in the given [innings].
  ///
  /// Call this function when a new bowler is set to bowl.
  BowlerInnings _createBowlerInnings(Innings innings, Player bowler) {
    final bowlerInnings =
        BowlerInnings(bowler, ballsPerOver: innings.rules.ballsPerOver);
    innings.bowlers[bowler] = bowlerInnings;
    return bowlerInnings;
  }

  BowlerInnings? getBowlerInningsOfPlayer(Innings innings, Player player) {
    final bowlerInnings = innings.bowlers[player];
    return bowlerInnings;
  }

  /// Deletes the last bowler innings of the player
  BowlerInnings? deleteBowlerInningsOfPlayer(Innings innings, Player player) {
    final bowlerInnings = innings.bowlers.remove(player);
    return bowlerInnings;
  }

  /// Retires the [BatterInnings] from the innings.
  ///
  /// Call this function when a batter retires their innings and walks back
  /// to the pavilion.
  void retireBatterInnings(
      Innings innings, BatterInnings batterInnings, Retired retired) {
    _postToInnings(
      innings,
      BatterRetire(
        index: _currentIndex(innings),
        // batter: batterInnings.player,
        retired: retired,
      ),
    );
  }

  void nextBatter(Innings innings, Player nextBatter) {
    final BatterInnings? previous;

    if (_isBatterToBeReplaced(innings.batter1)) {
      previous = innings.batter1;
    } else if (!innings.rules.onlySingleBatter &&
        _isBatterToBeReplaced(innings.batter2)) {
      previous = innings.batter2;
    } else {
      throw StateError("Attempted to add new batter without retiring previous");
    }

    final post = NextBatter(
        index: _currentIndex(innings),
        next: nextBatter,
        previous: previous?.player);

    // Add Post to Innings
    _postToInnings(innings, post);
  }

  bool _isBatterToBeReplaced(BatterInnings? batterInnings) =>
      batterInnings == null || batterInnings.isOut || batterInnings.isRetired;

  /// Creates a new [BatterInnings] and adds it to the given [Innings]
  ///
  /// Call this function when a new batter walks out to bat.
  BatterInnings _createBatterInnings(Innings innings, Player batter) {
    final batterInnings = BatterInnings(batter);
    innings.batters[batter] = batterInnings;
    return batterInnings;
  }

  /// Fetches the [BatterInnings] of the given [player]. Returns `null`
  /// if the player hasn't batted.
  BatterInnings? getBatterInningsOfPlayer(Innings innings, Player player) {
    final batterInnings = innings.batters[player];
    return batterInnings;
  }

  /// Deletes the [BatterInnings] of the given [player].
  BatterInnings? deleteBatterInningsOfPlayer(Innings innings, Player player) {
    final batterInnings = innings.batters.remove(player);
    return batterInnings;
  }

  /// Creates a [Ball] of the given data and adds it to the innings
  void play(
    Innings innings, {
    required Player bowler,
    required Player batter,
    required int runsScored,
    required Wicket? wicket,
    required BowlingExtraType? bowlingExtraType,
    required BattingExtraType? battingExtraType,
    DateTime? datetime,
  }) {
    datetime ??= DateTime.now();

    final BowlingExtra? bowlingExtra = switch (bowlingExtraType) {
      null => null,
      BowlingExtraType.noBall => NoBall(innings.rules.noBallPenalty),
      BowlingExtraType.wide => Wide(innings.rules.widePenalty),
    };

    final BattingExtra? battingExtra = switch (battingExtraType) {
      null => null,
      BattingExtraType.bye => Bye(runsScored),
      BattingExtraType.legBye => LegBye(runsScored),
    };

    // This ensures that only the runs awarded to the batter are accounted for
    // in this variable
    final int runsScoredByBatter = battingExtra != null ? 0 : runsScored;

    final index =
        bowlingExtra != null ? _currentIndex(innings) : _nextIndex(innings);

    final ball = Ball(
      index: index,
      bowler: bowler,
      batter: batter,
      runsScoredByBatter: runsScoredByBatter,
      wicket: wicket,
      bowlingExtra: bowlingExtra,
      battingExtra: battingExtra,
      timestamp: datetime,
    );

    // Add Post to Innings
    _postToInnings(innings, ball);
  }

  void loadInnings(Innings innings, Iterable<InningsPost> posts) {
    for (final post in posts) {
      _postToInnings(innings, post);
    }
  }

  // void forfeitInnings(Innings innings) {
  //   innings.isForfeited = true;
  // }

  void _postToInnings(Innings innings, InningsPost post) {
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
  }

  void _handleBallPost(Innings innings, Ball ball) {
    // Post to Bowler Innings
    _postToBowlerInningsOfPlayer(innings, ball, ball.bowler);
    // Post to Batter Innings
    _postToBatterInningsOfPlayer(innings, ball, ball.batter);

    // Add wicket if required
    if (ball.isWicket) {
      final batterInnings =
          getBatterInningsOfPlayer(innings, ball.wicket!.batter);
      batterInnings?.wicket = ball.wicket;
    }

    // Swap strike for odd number of runs
    if (ball.runsScoredByBatter % 2 == 1) swapStrike(innings);

    // Swap strike whenever an over completes
    if (ball.index.ball == innings.rules.ballsPerOver) swapStrike(innings);
  }

  void _undoBallPost(Innings innings, Ball ball) {
    // Remove from BowlerInnings
    final bowlerInnings = getBowlerInningsOfPlayer(innings, ball.bowler);
    bowlerInnings?.posts.remove(ball);

    // Remove post from BatterInnings
    final batterInnings = getBatterInningsOfPlayer(innings, ball.batter);
    batterInnings?.posts.remove(ball);
    if (ball.isWicket) {
      batterInnings?.wicket = null;
    }

    // Swap strike
    if (ball.runsScoredByBatter % 2 == 1) swapStrike(innings); // Odd runs
    // Over complete
    if (ball.index.ball == innings.rules.ballsPerOver) swapStrike(innings);
  }

  void _handleBowlerRetirePost(Innings innings, BowlerRetire post) {
    _postToBowlerInningsOfPlayer(innings, post, post.bowler);
  }

  void _undoBowlerRetirePost(Innings innings, BowlerRetire post) {
    _unpostFromBowlerInningsOfPlayer(innings, post, post.bowler);
  }

  void _handleNextBowlerPost(Innings innings, NextBowler post) {
    final bowler = post.next;

    // Find or create [BowlerInnings] for player
    final bowlerInnings = getBowlerInningsOfPlayer(innings, bowler) ??
        _createBowlerInnings(innings, bowler);

    // Change the current bowler
    innings.bowler = bowlerInnings;
  }

  void _undoNextBowlerPost(Innings innings, NextBowler post) {
    // Set the correct bowler in the innings
    if (post.previous != null) {
      // Set innings.bowler to previous bowler
      innings.bowler = getBowlerInningsOfPlayer(innings, post.previous!);
    } else {
      // First bowler to be selected, can be cleared
      innings.bowler = null;
    }

    // Remove any ghost BowlerInnings from Innings
    final bowlerInnings = getBowlerInningsOfPlayer(innings, post.next);
    if (bowlerInnings != null && bowlerInnings.posts.isEmpty) {
      deleteBowlerInningsOfPlayer(innings, post.next);
    }
  }

  void _handleBatterRetirePost(Innings innings, BatterRetire post) {
    final batterInnings = getBatterInningsOfPlayer(innings, post.batter);
    batterInnings?.posts.add(post);
    batterInnings?.retired = post.retired;
  }

  void _undoBatterRetirePost(Innings innings, BatterRetire post) {
    final batterInnings = getBatterInningsOfPlayer(innings, post.batter);
    batterInnings?.posts.remove(post);
    batterInnings?.retired = null;
  }

  void _handleNextBatterPost(Innings innings, NextBatter post) {
    final nextBatterInnings = getBatterInningsOfPlayer(innings, post.next) ??
        _createBatterInnings(innings, post.next);

    // Remove retirement, if any
    nextBatterInnings.retired = null;
    // Remove wicket, if any
    nextBatterInnings.wicket = null;

    // Figure nextBatterInnings slot
    if (innings.batter1 == null || innings.batter1!.player == post.previous) {
      innings.batter1 = nextBatterInnings;
    } else if (!innings.rules.onlySingleBatter &&
        (innings.batter2 == null || innings.batter2!.player == post.previous)) {
      innings.batter2 = nextBatterInnings;
    } else {
      throw StateError("Attempted to add new batter without retiring previous");
    }

    // Set strike
    if (innings.striker == null ||
        innings.striker != innings.batter1 &&
            innings.striker != innings.batter2) {
      setStrike(innings, nextBatterInnings);
    }
  }

  void _undoNextBatterPost(Innings innings, NextBatter post) {
    // Remove ghost BatterInnings from Innings
    final batterInnings = deleteBatterInningsOfPlayer(innings, post.next);
    final BatterInnings? restoredBatterInnings;

    // Set the correct batter in the innings
    if (post.previous != null) {
      // Set innings.batter to previous batter
      restoredBatterInnings = getBatterInningsOfPlayer(innings, post.previous!);
    } else {
      // First bowler to be selected, can be cleared
      restoredBatterInnings = null;
    }
    // Figure out whether batter1 was replaced or batter2 was
    if (innings.batter1 == batterInnings) {
      innings.batter1 = restoredBatterInnings;
    } else if (innings.batter2 == batterInnings) {
      innings.batter2 = restoredBatterInnings;
    }
  }

  void _handleRunoutBeforeDeliveryPost(
      Innings innings, RunoutBeforeDelivery post) {
    final batterInnings = getBatterInningsOfPlayer(innings, post.batter);
    batterInnings?.posts.add(post);
    batterInnings?.wicket = post.wicket;
  }

  void _undoRunoutBeforeDeliveryPost(
      Innings innings, RunoutBeforeDelivery post) {
    final batterInnings = getBatterInningsOfPlayer(innings, post.batter);
    batterInnings?.posts.remove(post);
    batterInnings?.wicket = null;
  }

  void _postToBowlerInningsOfPlayer(
      Innings innings, InningsPost post, Player bowler) {
    // Get BowlerInnings
    final bowlerInnings = getBowlerInningsOfPlayer(innings, bowler);
    // Add Post
    bowlerInnings?.posts.add(post);
  }

  void _unpostFromBowlerInningsOfPlayer(
      Innings innings, InningsPost post, Player bowler) {
    // Get BowlerInnings
    final bowlerInnings = getBowlerInningsOfPlayer(innings, bowler);
    // Remove Post
    bowlerInnings?.posts.remove(post);
  }

  void _postToBatterInningsOfPlayer(
      Innings innings, InningsPost post, Player batter) {
    // Get BatterInnings
    final batterInnings = getBatterInningsOfPlayer(innings, batter);
    // Add Post
    batterInnings?.posts.add(post);
  }

  void _unpostFromBatterInningsOfPlayer(
      Innings innings, InningsPost post, Player batter) {
    // Get BatterInnings
    final batterInnings = getBatterInningsOfPlayer(innings, batter);
    // Remove Post
    batterInnings?.posts.remove(post);
  }

  void undoPostFromInnings(Innings innings) {
    if (innings.posts.isEmpty) return;

    final post = innings.posts.removeLast();
    switch (post) {
      case Ball():
        _undoBallPost(innings, post);
      case BowlerRetire():
        _undoBowlerRetirePost(innings, post);
      case NextBowler():
        _undoNextBowlerPost(innings, post);
      case BatterRetire():
        _undoBatterRetirePost(innings, post);
        _unpostFromBatterInningsOfPlayer(innings, post, post.batter);
      case NextBatter():
        _undoNextBatterPost(innings, post);
      case RunoutBeforeDelivery():
        _undoRunoutBeforeDeliveryPost(innings, post);
    }
  }

  PostIndex _currentIndex(Innings innings) {
    if (innings.posts.isEmpty) {
      // First post
      return const PostIndex.zero();
    }

    final last = innings.posts.last;

    if (last.index.ball == innings.rules.ballsPerOver) {
      return PostIndex(last.index.over + 1, 0);
    }
    return innings.posts.last.index;
  }

  PostIndex _nextIndex(Innings innings) {
    final currentIndex = _currentIndex(innings);

    if (currentIndex.ball == innings.rules.ballsPerOver) {
      return PostIndex(currentIndex.over + 1, 0);
    } else {
      return PostIndex(currentIndex.over, currentIndex.ball + 1);
    }
  }
}
