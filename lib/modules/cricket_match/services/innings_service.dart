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
        innings.batter1 = nextBatterInnings;
        nextBatterPost = NextBatter(
            index: _currentIndex(innings),
            next: nextBatter,
            previous: innings.batter1!.player);
      } else if (!innings.rules.onlySingleBatter &&
          _isBatterToBeReplaced(innings.batter2)) {
        previousBatterInnings = innings.batter2!;
        innings.batter2 = nextBatterInnings;
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
    batterInnings.retired = retired;
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

  void retireBowlerInnings(Innings innings, BowlerInnings bowlerInnings) {
    final retired = RetiredBowler(bowler: bowlerInnings.player);

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
    required BowlingExtraType? bowlingExtraType,
    required BattingExtraType? battingExtraType,
  }) {
    final BowlingExtra? bowlingExtra = switch (bowlingExtraType) {
      null => null,
      BowlingExtraType.noBall => NoBall(innings.rules.noBallPenalty),
      BowlingExtraType.wide => Wide(innings.rules.widePenalty),
    };

    final index =
        bowlingExtra != null ? _currentIndex(innings) : _nextIndex(innings);

    final ball = Ball(
      index: index,
      bowler: bowler,
      batter: batter,
      runsScoredByBattingTeam: runsScored,
      wicket: wicket,
      bowlingExtra: bowlingExtra,
      battingExtraType: battingExtraType,
    );

    // Add Post to Innings
    _postToInnings(innings, ball);

    // Swap strike for odd number of runs
    if (ball.runsScoredByBattingTeam % 2 == 1) swapStrike(innings);

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
        if (post.wicket != null) {
          final batterInnings =
              getBatterInningsOfPlayer(innings, post.wicket!.batter);
          if (batterInnings != null) {
            batterInnings.wicket = post.wicket;
          }
        }
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
        if (post.runsScoredByBattingTeam % 2 == 1) swapStrike(innings);
    }
  }

  void forfeitInnings(Innings innings) {
    innings.isForfeited = true;
  }

  InningsIndex _currentIndex(Innings innings) {
    if (innings.posts.isEmpty) {
      return const InningsIndex.zero();
    }

    final last = innings.posts.last;
    if (last.index.ball == innings.rules.ballsPerOver) {
      return InningsIndex(last.index.over + 1, 0);
    }
    return innings.posts.last.index;
  }

  InningsIndex _nextIndex(Innings innings) {
    final currentIndex = _currentIndex(innings);

    if (currentIndex.ball == innings.rules.ballsPerOver) {
      return InningsIndex(currentIndex.over + 1, 0);
    } else {
      return InningsIndex(currentIndex.over, currentIndex.ball + 1);
    }
  }
}
