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
  void swapStrike(Innings innings) {
    if (innings.striker == innings.batter1) {
      innings.striker = innings.batter2;
    } else {
      innings.striker = innings.batter1;
    }
  }

  void nextBatter(Innings innings, Player nextBatter) {
    // Find or create [BatterInnings] for player
    final nextBatterInnings = getBatterInningsOfPlayer(innings, nextBatter) ??
        _createBatterInnings(innings, nextBatter);

    // Remove retirement, if any
    nextBatterInnings.retired = null;
    // Remove wicket, if any
    nextBatterInnings.wicket = null;

    // final previousBatterInnings = _isBatterToBeReplaced(innings.)

    late final NextBatter nextBatterPost;
    if (innings.batter1 == null) {
      innings.batter1 = nextBatterInnings;
      nextBatterPost = NextBatter(
          index: _currentIndex(innings), next: nextBatter, previous: null);
    } else if (!innings.rules.onlySingleBatter && innings.batter2 == null) {
      innings.batter2 = nextBatterInnings;
      nextBatterPost = NextBatter(
          index: _currentIndex(innings), next: nextBatter, previous: null);
    } else {
      // Previous batter exists
      late final BatterInnings previousBatterInnings;
      if (_isBatterToBeReplaced(innings.batter1)) {
        previousBatterInnings = innings.batter1!;
        innings.batter1 = nextBatterInnings;
        nextBatterPost = NextBatter(
            index: _currentIndex(innings),
            next: nextBatter,
            previous: previousBatterInnings.player);
      } else if (!innings.rules.onlySingleBatter &&
          _isBatterToBeReplaced(innings.batter2)) {
        previousBatterInnings = innings.batter2!;
        innings.batter2 = nextBatterInnings;
        nextBatterPost = NextBatter(
            index: _currentIndex(innings),
            next: nextBatter,
            previous: previousBatterInnings.player);
      } else {
        throw StateError(
            "Attempted to add new batter without retiring previous");
      }
    }

    // Set strike
    if (innings.striker == null ||
        innings.striker != innings.batter1 &&
            innings.striker != innings.batter2) {
      setStrike(innings, nextBatterInnings);
    }

    // Add Post to Innings
    _postToInnings(innings, nextBatterPost);
  }

  bool _isBatterToBeReplaced(BatterInnings? batterInnings) {
    if (batterInnings == null) {
      return true;
    } else if (batterInnings.isOut || batterInnings.isRetired) {
      return true;
    } else {
      return false;
    }
  }

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

  /// Retires the [BatterInnings] from the innings.
  void retireBatterInnings(
      Innings innings, BatterInnings batterInnings, Retire retired) {
    batterInnings.retired = retired;
    _postToInnings(
      innings,
      BatterRetire(
        index: _currentIndex(innings),
        // batter: batterInnings.player,
        retired: retired,
      ),
    );
  }

  /// Adds the given [bowler] to the [innings]
  void nextBowler(Innings innings, Player bowler) {
    // Find or create [BowlerInnings] for player
    final bowlerInnings = getBowlerInningsOfPlayer(innings, bowler) ??
        _createBowlerInnings(innings, bowler);

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

    // Change the current bowler
    innings.bowler = bowlerInnings;
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

  void retireBowlerInnings(Innings innings, BowlerInnings bowlerInnings) {
    // final retired = RetiredBowler(bowler: bowlerInnings.player);

    _postToInnings(
      innings,
      BowlerRetire(
        index: _currentIndex(innings),
        bowler: bowlerInnings.player,
        // retired: retired,
      ),
    );
  }

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

    // Swap strike for odd number of runs
    if (ball.runsScoredByBatter % 2 == 1) swapStrike(innings);

    // Swap strike whenever an over completes
    if (ball.index.ball == innings.rules.ballsPerOver) swapStrike(innings);
  }

  void _postToInnings(Innings innings, InningsPost post) {
    innings.posts.add(post);

    switch (post) {
      case NextBowler():
      case NextBatter():
        break;
      case BowlerRetire():
        _postToBowlerInningsOfPlayer(innings, post, post.bowler);
      case BatterRetire():
        _postToBatterInningsOfPlayer(innings, post, post.batter);
      case RunoutBeforeDelivery():
        _postToBatterInningsOfPlayer(innings, post, post.wicket.batter);
      case Ball():
        _postToBowlerInningsOfPlayer(innings, post, post.bowler);
        _postToBatterInningsOfPlayer(innings, post, post.batter);
    }
  }

  void _postToBowlerInningsOfPlayer(
      Innings innings, InningsPost post, Player bowler) {
    final bowlerInnings = getBowlerInningsOfPlayer(innings, bowler);
    if (bowlerInnings != null) {
      // Add post to bowler innings
      bowlerInnings.posts.add(post);
    }
  }

  void _postToBatterInningsOfPlayer(
      Innings innings, InningsPost post, Player batter) {
    final batterInnings = getBatterInningsOfPlayer(innings, batter);
    if (batterInnings != null) {
      // Add post to batter innings
      batterInnings.posts.add(post);

      // Add wicket if required
      if (post is Ball && post.isWicket && post.wicket!.batter == batter) {
        batterInnings.wicket = post.wicket;
      }
    }
  }

  void undoPostFromInnings(Innings innings) {
    if (innings.posts.isEmpty) return;

    final post = innings.posts.removeLast();
    switch (post) {
      case BowlerRetire():
        // Remove post from BowlerInnings
        final bowlerInnings = getBowlerInningsOfPlayer(innings, post.bowler);
        if (bowlerInnings != null) {
          bowlerInnings.posts.remove(post);
        }
      case NextBowler():
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
      case BatterRetire():
        final batterInnings = getBatterInningsOfPlayer(innings, post.batter);
        if (batterInnings != null) {
          // Clear retirement from BatterInnings
          batterInnings.retired = null;

          // Remove post from BatterInnings
          batterInnings.posts.remove(post);
        }

      case NextBatter():
        // Remove ghost BatterInnings from Innings
        final batterInnings = deleteBatterInningsOfPlayer(innings, post.next);
        late final BatterInnings? restoredBatterInnings;

        // Set the correct batter in the innings
        if (post.previous != null) {
          // Set innings.batter to previous batter
          restoredBatterInnings =
              getBatterInningsOfPlayer(innings, post.previous!);
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
      case RunoutBeforeDelivery():
        // Remove wicket from respective BatterInnings
        final batterInnings =
            getBatterInningsOfPlayer(innings, post.wicket.batter);
        if (batterInnings != null) {
          batterInnings.wicket = null;

          // Remove post from respective BatterInnings
          batterInnings.posts.remove(post);
        }
      case Ball():
        // Remove post from BatterInnings
        final batterInnings = getBatterInningsOfPlayer(innings, post.batter);
        if (batterInnings != null) {
          batterInnings.posts.remove(post);
          if (post.isWicket) {
            batterInnings.wicket = null;
          }
        }

        // Remove post from BowlerInnings
        final bowlerInnings = getBowlerInningsOfPlayer(innings, post.bowler);
        if (bowlerInnings != null) bowlerInnings.posts.remove(post);

        // Swap strike
        if (post.runsScoredByBatter % 2 == 1) swapStrike(innings);
        if (post.index.ball == innings.rules.ballsPerOver) swapStrike(innings);
    }
  }

  void forfeitInnings(Innings innings) {
    innings.isForfeited = true;
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
