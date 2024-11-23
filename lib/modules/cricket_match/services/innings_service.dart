import 'package:scorecard/modules/cricket_match/models/innings_model.dart';
import 'package:scorecard/modules/cricket_match/models/wicket_model.dart';
import 'package:scorecard/modules/player/player_model.dart';

/// Handles the business logic with all operations related to an [Innings].
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
        nextBatterPost = NextBatter(
            index: _currentIndex(innings),
            next: nextBatter,
            previous: innings.batter1!.player);
      } else if (!innings.rules.onlySingleBatter &&
          _isBatterToBeReplaced(innings.batter2)) {
        previousBatterInnings = innings.batter2!;
        nextBatterPost = NextBatter(
            index: _currentIndex(innings),
            next: nextBatter,
            previous: innings.batter2!.player);
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
    innings.batters.add(batterInnings);
    return batterInnings;
  }

  void retireBatterInnings(
      Innings innings, BatterInnings batterInnings, RetiredBatter retired) {
    _postToInnings(
      innings,
      BatterRetire(
        index: _currentIndex(innings),
        batter: batterInnings.player,
        retired: retired,
      ),
    );
  }

  /// Fetches the [BatterInnings] of the given [player]. Returns `null`
  /// if the player hasn't batted.
  BatterInnings? getBatterInningsOfPlayer(Innings innings, Player player) {
    try {
      final batterInnings = innings.batters
          .lastWhere((batterInnings) => batterInnings.player == player);
      return batterInnings;
    } on StateError {
      return null;
    }
  }

  /// Deletes the LAST [BatterInnings] of the given [player].
  BatterInnings? deleteBatterInningsOfPlayer(Innings innings, Player player) {
    final batterInnings = getBatterInningsOfPlayer(innings, player);
    if (batterInnings != null) {
      innings.batters.remove(batterInnings);
    }
    return batterInnings;
  }

  /// Deletes the LAST [BatterInnings] from the given [innings]
  // void deleteLastBatterInnings(Innings innings) {
  //   if (innings.batters.isNotEmpty) innings.batters.removeLast();
  // }

  void nextBowler(Innings innings, Player bowler) {
    // Find or create [BowlerInnings] for player
    final bowlerInnings = getBowlerInningsOfPlayer(innings, bowler) ??
        _createBowlerInnings(innings, bowler);

    // Add post to Innings
    _postToInnings(
        innings,
        NextBowler(
            index: _currentIndex(innings),
            previous: innings.bowler?.player,
            next: bowler));

    // Change the current bowler
    innings.bowler = bowlerInnings;
  }

  /// Creates a new [BowlerInnings] in the given [innings].
  ///
  /// Call this function when a new bowler is set to bowl.
  BowlerInnings _createBowlerInnings(Innings innings, Player bowler) {
    final bowlerInnings =
        BowlerInnings(bowler, ballsPerOver: innings.rules.ballsPerOver);
    innings.bowlers.add(bowlerInnings);
    return bowlerInnings;
  }

  void retireBowlerInnings(
      Innings innings, BowlerInnings bowlerInnings, RetiredBowler retired) {
    _postToInnings(
      innings,
      BowlerRetire(
        index: _currentIndex(innings),
        bowler: bowlerInnings.player,
        retired: retired,
      ),
    );
  }

  BowlerInnings? getBowlerInningsOfPlayer(Innings innings, Player player) {
    try {
      final bowlerInnings = innings.bowlers
          .lastWhere((bowlerInnings) => bowlerInnings.player == player);
      return bowlerInnings;
    } on StateError {
      return null;
    }
  }

  /// Deletes the last bowler innings of the player
  BowlerInnings? deleteBowlerInningsOfPlayer(Innings innings, Player player) {
    final bowlerInnings = getBowlerInningsOfPlayer(innings, player);
    if (bowlerInnings != null) {
      innings.bowlers.remove(bowlerInnings);
    }
    return bowlerInnings;
  }

  void deleteLastBowlerInnings(Innings innings) {
    innings.bowlers.removeLast();
  }

  void play(
    Innings innings, {
    required Player bowler,
    required Player batter,
    required int runsScored,
    required Wicket? wicket,
    required BowlingExtra? bowlingExtra,
    required BattingExtra? battingExtra,
  }) {
    final index =
        bowlingExtra != null ? _currentIndex(innings) : _nextIndex(innings);

    final ball = Ball(
      index: index,
      bowler: bowler,
      batter: batter,
      runsScored: runsScored,
      wicket: wicket,
      bowlingExtra: bowlingExtra,
      battingExtra: battingExtra,
    );

    // Add Post to Innings
    _postToInnings(innings, ball);

    // Swap strike for odd number of runs
    if (ball.runsScored % 2 == 1) swapStrike(innings);

    // Swap strike whenever an over completes
    if (ball.index.ball == innings.rules.ballsPerOver) swapStrike(innings);
  }

  void _postToInnings(Innings innings, InningsPost post) {
    innings.posts.add(post);

    switch (post) {
      case NextBowler():
        // _addPostToBowlerInningsOfPlayer(innings, post, post.next);
        // if (post.previous != null) {
        //   _addPostToBowlerInningsOfPlayer(innings, post, post.previous!);
        // }
        break;
      case BowlerRetire():
        _postToBowlerInningsOfPlayer(innings, post, post.bowler);
      case NextBatter():
        // _addPostToBatterInningsOfPlayer(innings, post, post.next);
        // if(post.previous != null) {
        //   _addPostToBatterInningsOfPlayer(innings, post, post.previous!)
        // }
        break;
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
      bowlerInnings.posts.add(post);
    }
  }

  void _unPostFromBowlerInningsOfPlayer(Innings innings, Player bowler) {
    // Get the BowlerInnings
    final bowlerInnings = getBowlerInningsOfPlayer(innings, bowler);

    // Remove post from BowlerInnings
    if (bowlerInnings != null && bowlerInnings.posts.isNotEmpty) {
      final last = bowlerInnings.posts.removeLast();
    }
  }

  void _postToBatterInningsOfPlayer(
      Innings innings, InningsPost post, Player batter) {
    final batterInnings = getBatterInningsOfPlayer(innings, batter);
    if (batterInnings != null) {
      batterInnings.posts.add(post);
    }
  }

  void undoPostFromInnings(Innings innings) {
    if (innings.posts.isEmpty) return;

    final post = innings.posts.removeLast();
    switch (post) {
      case NextBowler():
        if (post.previous == null) {
          innings.bowler = null;
        } else {
          innings.bowler = getBowlerInningsOfPlayer(innings, post.previous!);
        }
      case BowlerRetire():
        final bowlerInnings = getBowlerInningsOfPlayer(innings, post.bowler);
        if (bowlerInnings != null && bowlerInnings.posts.last is BowlerRetire) {
          bowlerInnings.posts.removeLast();
        }
      case BatterRetire():
        final batterInnings = getBatterInningsOfPlayer(innings, post.batter);
        if (batterInnings != null) {
          batterInnings.retired = null;
        }
      case RunoutBeforeDelivery():
        final batterInnings =
            getBatterInningsOfPlayer(innings, post.wicket.batter);
        if (batterInnings != null) {
          batterInnings.wicket = null;
        }
      case NextBatter():
        final batterInnings = deleteBatterInningsOfPlayer(innings, post.next);
        if (post.previous != null) {
          final restoredBatterInnings =
              getBatterInningsOfPlayer(innings, post.previous!);
          if (innings.batter1 == batterInnings) {
            innings.batter1 = restoredBatterInnings;
          } else if (innings.batter2 == batterInnings) {
            innings.batter2 = restoredBatterInnings;
          }
        }
      case Ball():
      // TODO: Handle this case.
    }
  }

  void forfeitInnings(Innings innings) {
    innings.isForfeited = true;
  }

  InningsIndex _currentIndex(Innings innings) => innings.posts.isEmpty
      ? const InningsIndex.zero()
      : innings.posts.last.index;

  InningsIndex _nextIndex(Innings innings) {
    final currentIndex = _currentIndex(innings);

    if (currentIndex.ball == innings.rules.ballsPerOver) {
      return InningsIndex(currentIndex.over + 1, 0);
    } else {
      return InningsIndex(currentIndex.over, currentIndex.ball + 1);
    }
  }
}
