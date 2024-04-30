import 'dart:collection';
import 'dart:math';

import 'package:scorecard/models/ball.dart';
import 'package:scorecard/models/player.dart';
import 'package:scorecard/models/statistics.dart';
import 'package:scorecard/models/team.dart';
import 'package:scorecard/models/wicket.dart';
import 'package:scorecard/util/constants.dart';

/// Represents an innings of a [CricketMatch].
///
/// An innings is one division of a cricket match where one team bats
/// while the other team bowls and fields.
///
/// In Limited Overs Cricket, a [target] represents the runs required by a team
/// to win the game. This implies that this is the second of a match. Typically,
/// the target will be one more than the runs score in the first innings;
/// however, DLS methods may be implemented to re-calculate the target.
class Innings {
  final TeamSquad battingTeam;
  final TeamSquad bowlingTeam;

  int? target;
  final int maxOvers;

  Innings.load({
    required this.battingTeam,
    required this.bowlingTeam,
    required this.maxOvers,
    required this.target,
    required List<Ball> balls,
    required List<Player> batters,
    required List<Player> bowlers,
    // Players in Action
    required Player batter1,
    required Player? batter2,
    required Player striker,
    required Player bowler,
  }) {
    for (final batter in batters) {
      _addBatterToBatterInnings(batter);
    }

    for (final bowler in bowlers) {
      _addBowlerToBowlerInnings(bowler);
    }

    for (final ball in balls) {
      play(ball);
    }

    playersInAction = PlayersInAction(
      batter1: _batterInnings[batter1]!,
      batter2: batter2 == null ? null : _batterInnings[batter2],
      striker: _batterInnings[striker]!,
      bowler: _bowlerInnings[bowler]!,
    );
  }

  /// Creates a blank, uninitialized innings.
  ///
  /// **IMPORTANT**: [initialize] must be called separately!
  Innings.create({
    required this.battingTeam,
    required this.bowlingTeam,
    required this.maxOvers,
    this.target,
  });

  /// This forms the crux, root and source of all data that is generated
  /// for an innings.
  final List<Ball> _balls = [];
  UnmodifiableListView<Ball> get balls => UnmodifiableListView(_balls);

  // Players In Action
  late final PlayersInAction playersInAction;

  /// Initializes an innings with the first [PlayersInAction].
  void initialize({
    required Player batter1,
    required Player? batter2,
    required Player bowler,
  }) {
    final bowlerInnings = _addBowlerToBowlerInnings(bowler);
    final batterInnings1 = _addBatterToBatterInnings(batter1);
    final batterInnings2 =
        batter2 == null ? null : _addBatterToBatterInnings(batter2);

    playersInAction = PlayersInAction(
      batter1: batterInnings1,
      batter2: batterInnings2,
      striker: batterInnings1,
      bowler: bowlerInnings,
    );
  }

  bool get isInitialized =>
      _batterInnings.isNotEmpty && _bowlerInnings.isNotEmpty;

  // Score
  // TODO: Get from [BowlingCalculations]

  /// The runs scored by the batting team in this Innings
  int get runs => balls.fold(0, (runs, ball) => runs + ball.totalRuns);

  UnmodifiableListView<Ball> get _wicketBalls =>
      UnmodifiableListView(balls.where((ball) => ball.isWicket));

  /// The number of wickets the batting team has lost
  int get wickets => _wicketBalls.length;

  /// The number of balls bowled in this Innings
  int get ballsBowled => balls.where((ball) => ball.isLegal).length;

  /// Whether the quota of overs to be bowled has been completed
  bool get areOversCompleted =>
      maxOvers * Constants.ballsPerOver == ballsBowled;

  // Calculations

  /// Average number of runs scored per over
  double get currentRunRate =>
      ballsBowled == 0 ? 0 : (runs / ballsBowled) * Constants.ballsPerOver;

  /// The projected score based on the [currentRunRate]
  int get projectedRuns => (currentRunRate * maxOvers).floor();

  /// The number of runs required by the team to win the match
  /// This only makes sense during the second Innings of a Limited Over match.
  int get requiredRuns => target != null ? max(0, (target! - runs)) : 0;

  /// The number of balls left to be bowled in this innings
  int get ballsLeft => maxOvers * Constants.ballsPerOver - ballsBowled;
  double get requiredRunRate => target != null && ballsLeft != 0
      ? (requiredRuns / ballsLeft) * Constants.ballsPerOver
      : 0;

  // OPERATIONS

  /// Adds the given [ball] to the proceedings of this innings.
  ///
  /// This function serves as an entry point to the innings.
  ///
  /// Pre-requisites:
  /// - ball.batter must be registered into the innings via [addBatter]
  /// - ball.bowler must be registered into the innings via [setBowler]
  ///
  /// Throws [UnsupportedError] if any pre-requisites is not met.
  void play(Ball ball) {
    if (!_bowlerInnings.containsKey(ball.bowler)) {
      throw UnsupportedError("Ball delivered by unregistered bowler");
    }
    if (!_batterInnings.containsKey(ball.batter)) {
      throw UnsupportedError("Ball faced by unregistered batter");
    }

    // Add to the balls of this innings
    _balls.add(ball);

    // Handle Overs
    if (_overs.isEmpty || _overs.last.isCompleted) {
      _overs.add(Over());
    }
    _overs.last.addBall(ball);

    _bowlerInnings[ball.bowler]!.deliver(ball);
    _batterInnings[ball.batter]!.face(ball);

    // Handle partnership
    // _partnerships.last.play(ball);

    if (ball.isWicket || ball.isBatterRetired) {
      if (ball.wicket!.batter != ball.batter) {
        _batterInnings[ball.wicket!.batter]!.setWicket(ball.wicket!);
      }
    }
  }

  /// Remove the given [ball] from this innings.
  ///
  /// The parameter [ball] is pretty useless as of now, it's added as a means of
  /// forwards compatibility. For now, only removing the last ball is supported.
  /// This is because removing a ball other than the last can have various
  /// implications, forcing this innings into an inexplicable state.
  ///
  /// Pre-requisites:
  /// - The given [ball] must be the last ball.
  ///
  /// Throws [UnsupportedError] if any pre-requisites is not met.
  void unPlay(Ball ball) {
    if (_balls.isEmpty) {
      return;
    }
    if (_balls.last != ball) {
      throw UnsupportedError("Attempted to remove ball other than last ball");
    }

    // The following checks are not mentioned in the docs for this function
    // because these conditions are impossible to satisfy. When a ball is added,
    // these conditions are checked anyway. Nevertheless, I am leaving these
    // checks in the code but not adding them to the docs to prevent confusion.

    if (!_bowlerInnings.containsKey(ball.bowler)) {
      throw UnsupportedError("Ball delivered by unregistered bowler");
    }
    if (!_batterInnings.containsKey(ball.batter)) {
      throw UnsupportedError("Ball faced by unregistered batter");
    }

    // Remove the ball from the innings.
    // We have already checked that the given ball is the last ball, so
    // calling .removeLast() instead of .remove(ball) is more efficient.
    _balls.removeLast();

    // Handle Overs
    _overs.last.removeBall(ball);
    if (overs.last.balls.isEmpty) {
      _overs.removeLast();
    }

    // Remove the ball from its batter's and bowler's innings
    _bowlerInnings[ball.bowler]!.unDeliver(ball);
    _batterInnings[ball.batter]!.unFace(ball);
  }

  // GENERATED DATA
  // Anything below is generated ball-by-ball as and when [play] is called.

  // Overs
  final List<Over> _overs = [];
  UnmodifiableListView<Over> get overs => UnmodifiableListView(_overs);

  // Fall of Wickets
  UnmodifiableListView<FallOfWicket> get fallOfWickets {
    final fallOfWickets = <FallOfWicket>[];
    int runs = 0;
    int wickets = 0;
    for (final ball in balls) {
      runs = runs + ball.totalRuns;
      if (ball.isWicket) {
        wickets++;
        fallOfWickets.add(FallOfWicket(
            ball: ball, runsAtWicket: runs, wicketsAtWicket: wickets));
      }
    }
    return UnmodifiableListView(fallOfWickets);
  }

  // Partnerships
  // final List<Partnership> _partnerships = [];
  UnmodifiableListView<Partnership> get partnerships {
    final partnerships = <Partnership>[];
    final batterInningsIterator = batterInningsList.iterator;

    batterInningsIterator.moveNext();
    final batter1 = batterInningsIterator.current;
    batterInningsIterator.moveNext();
    final batter2 = batterInningsIterator.current;

    partnerships
        .add(Partnership(batter1: batter1.batter, batter2: batter2.batter));
    for (final ball in balls) {
      partnerships.last.play(ball);
      if ((ball.isWicket || ball.isBatterRetired) &&
          batterInningsIterator.moveNext()) {
        final batterToBeAdded = ball.wicket!.batter == partnerships.last.batter1
            ? partnerships.last.batter2
            : partnerships.last.batter1;
        partnerships.add(Partnership(
            batter1: batterToBeAdded,
            batter2: batterInningsIterator.current.batter));
      }
    }
    return UnmodifiableListView(partnerships);
  }

  // Bowler

  final Map<Player, BowlerInnings> _bowlerInnings = {};
  List<BowlerInnings> get bowlerInningsList => _bowlerInnings.values.toList();

  /// Sets the given bowler as the "current" bowler
  /// as defined in [PlayersInAction]
  ///
  /// The given bowler, if not registered previously,
  /// is registered into the innings.
  ///
  /// Returns the [BowlerInnings] of the given bowler.
  BowlerInnings setBowler(Player bowler) {
    // Check if bowler is not already registered
    if (!_bowlerInnings.containsKey(bowler)) {
      // Add bowler to bowlerInnings
      _addBowlerToBowlerInnings(bowler);
    }

    // Set bowler as the current bowler
    playersInAction.bowler = _bowlerInnings[bowler]!;

    return _bowlerInnings[bowler]!;
  }

  BowlerInnings _addBowlerToBowlerInnings(Player bowler) {
    final bowlerInn = BowlerInnings(bowler, innings: this);
    _bowlerInnings[bowler] = bowlerInn;
    return bowlerInn;
  }

  /// Returns the [BowlerInnings] of the given [bowler] as long as the bowler
  /// has been registered into this innings.
  BowlerInnings? getBowlerInnings(Player bowler) {
    return _bowlerInnings[bowler];
  }

  /// Removes the given [bowler] from the innings.
  ///
  /// Pre-requisites:
  /// - No ball in [balls] should be bowled by the given bowler.
  ///
  /// throws [UnsupportedError] if any pre-requisites is not met.
  void removeBowler(BowlerInnings bowlInn) {
    if (balls.any((ball) => ball.bowler == bowlInn.bowler)) {
      throw UnsupportedError(
          "Attempted to remove a bowler who has bowled at least once ball.");
    }
    _bowlerInnings.remove(bowlInn.bowler);
  }

  // Batter

  /// Serves as a register of [BatterInnings] for this innings.
  /// A map data-structure ensures that every player has
  /// only one associated [BatterInnings].
  final Map<Player, BatterInnings> _batterInnings = {};

  /// A list of [BatterInnings] registered into this innings.
  List<BatterInnings> get batterInningsList => _batterInnings.values.toList();

  /// Registers the given batter into this innings.
  ///
  /// If [addBatter] is called more than once on the same player, nothing
  /// happens except that the [Wicket] of the batter is cleared. For more
  /// information, refer to the docs on [BatterInnings].
  ///
  /// [outBatter] is the batter that will be replaced in [PlayersInAction].
  ///
  /// Returns the [BatterInnings] of the given batter.
  BatterInnings addBatter(Player batter, BatterInnings outBatter) {
    final inBatter = _addBatterToBatterInnings(batter);

    // Handle PlayersInAction
    _fixBattersInAction(inBatter, outBatter);

    // Handle Partnerships
    // _handlePartnerships(inBatter, outBatter);

    if (!outBatter.isOutOrRetired && outBatter.ballsFaced == 0) {
      _batterInnings.remove(outBatter.batter);
    }

    return inBatter;
  }

  BatterInnings _addBatterToBatterInnings(Player batter) {
    final inBatter = BatterInnings(batter, innings: this);
    _batterInnings[batter] = inBatter; //TODO check containsKey?

    return inBatter;
  }

  /// Returns the [BatterInnings] of the given [batter] as long as the
  /// the batter is registered.
  BatterInnings? getBatterInnings(Player batter) {
    return _batterInnings[batter];
  }

  /// Removes a batter from this innings.
  ///
  /// Due to lack of better options, a [restore] parameter is required
  /// that specifies which batter is to be restored to [PlayersInAction].
  ///
  /// Pre-requisites:
  /// - No ball in [balls] should be played by the batter to be removed.
  ///
  /// throws [UnsupportedError] if any of the pre-requisites is not met
  void removeBatter(BatterInnings batInn, {required BatterInnings restore}) {
    if (balls.any((ball) => ball.batter == batInn.batter)) {
      throw UnsupportedError(
          "Attempted to remove a batter who has played at least one ball.");
    }

    // All actions performed in [addBatter] are reversed here.

    // Fix partnerships
    // if (partnerships.last.batter1 != batInn.batter &&
    //     partnerships.last.batter2 != batInn.batter) {
    //   throw UnsupportedError(
    //       "Attempted to remove batter that is not part of the current partnership");
    // }
    // _partnerships.removeLast();

    // Fix Batters In Action
    // Params are reversed
    _fixBattersInAction(restore, batInn);

    // Remove the batterInnings from
    _batterInnings.remove(batInn.batter);
  }

  void _fixBattersInAction(BatterInnings inBatter, BatterInnings outBatter) {
    if (outBatter == playersInAction.batter2) {
      playersInAction.batter2 = inBatter;
    } else {
      playersInAction.batter1 = inBatter;
    }
    if (playersInAction.striker != playersInAction.batter1 &&
        playersInAction.striker != playersInAction.batter2) {
      playersInAction.striker = inBatter;
    }
  }

  // void _handlePartnerships(BatterInnings inBatter, BatterInnings outBatter) {
  //   final currentPartnership = _partnerships.last;
  //   if (currentPartnership.batter1 == outBatter.batter) {
  //     _partnerships.add(Partnership(
  //         batter1: currentPartnership.batter2, batter2: inBatter.batter));
  //   } else {
  //     _partnerships.add(Partnership(
  //         batter1: currentPartnership.batter1, batter2: inBatter.batter));
  //   }
  // }

  /// Sets the strike, as defined in [PlayersInAction] to the given [batter].
  ///
  /// Pre-requisites:
  /// - The given [batter] must be a batter in [PlayersInAction]
  ///
  /// throws [UnsupportedError] if any pre-requisite is not met.
  void setStrike(BatterInnings batter) {
    if (batter != playersInAction.batter1 &&
        batter != playersInAction.batter2) {
      throw UnsupportedError(
          "Attempted to set strike to batter who is not in PlayersInAction");
    }
    playersInAction.striker = batter;
  }
}

/// An innings played by a batter during the course of one [Innings].
///
/// Colloquially, this may be referred to as a *knock*.
class BatterInnings with BattingCalculations {
  final Player batter;
  final Innings innings;

  BatterInnings(this.batter, {required this.innings});

  Wicket? _wicket;
  Wicket? get wicket => _wicket;

  @override
  UnmodifiableListView<Ball> get balls => UnmodifiableListView(
      innings.balls.where((ball) => ball.batter == batter));

  bool get isOutOrRetired => wicket != null;
  bool get isOut => wicket != null && wicket!.dismissal != Dismissal.retired;

  bool get isRetired =>
      wicket != null && wicket!.dismissal == Dismissal.retired;

  void face(Ball ball) {
    if (ball.isWicket && ball.wicket!.batter == batter) {
      _wicket = ball.wicket;
    }
  }

  void unFace(Ball ball) {
    if (ball.isWicket && ball.wicket!.batter == batter) {
      _wicket = null;
    }
  }

  void setWicket(Wicket? wicket) {
    _wicket = wicket;
  }

  // void retire() {
  //   _wicket = Wicket.retired(batter: batter);
  // }
}

class BowlerInnings with BowlingCalculations {
  final Player bowler;
  final Innings innings;

  BowlerInnings(this.bowler, {required this.innings});

  @override
  UnmodifiableListView<Ball> get balls => UnmodifiableListView(
      innings.balls.where((ball) => ball.bowler == bowler));

  void deliver(Ball ball) {
    // Added for uniformity
  }

  void unDeliver(Ball ball) {
    // Added for uniformity
  }
}

/// The [Player]s that are currently on pitch
///
/// It's a handy class to represent the two batters and a bowler
class PlayersInAction {
  BatterInnings batter1;
  BatterInnings? batter2;
  BatterInnings striker;

  BowlerInnings bowler;

  PlayersInAction({
    required this.batter1,
    required this.batter2,
    required this.striker,
    required this.bowler,
  });
}

/// "Fall of Wickets" is a common entry in a [CricketMatch]'s scorecard.
///
/// One entry designates a wicket, its (over.ball) index and the innings score
/// when that wicket fell.
class FallOfWicket {
  final Ball ball;

  final int runsAtWicket;
  final int wicketsAtWicket;

  Wicket get wicket => ball.wicket!;
  Player get outBatter => wicket.batter;

  const FallOfWicket({
    required this.ball,
    required this.runsAtWicket,
    required this.wicketsAtWicket,
  });
}

/// A partnership between two batters during an innings.
///
/// In cricketing terms, it represents the contribution made by two batters
/// to their team's score, also including any runs awarded to their team due
/// to extras.
///
/// As such, a partnership comes to an end when one of the involved batters
/// either loses their wicket or retires; an end of one partnership paves
/// the way for the next. The first-wicket partnership begins at the start
/// of a team's innings, consisting of the two opening batters.
class Partnership {
  /// As per convention, the batter who walked onto the crease first should
  /// be batter1
  final Player batter1;

  /// As per convention, the new batter in should be batter2
  final Player batter2;

  // TODO: Is this the best way?
  late final PartnershipContribution batter1Contribution;
  late final PartnershipContribution batter2Contribution;

  Partnership({required this.batter1, required this.batter2}) {
    batter1Contribution = PartnershipContribution(batter1, partnership: this);
    batter2Contribution = PartnershipContribution(batter2, partnership: this);
  }

  final List<Ball> _balls = [];
  // @override
  UnmodifiableListView<Ball> get balls => UnmodifiableListView(_balls);

  // TODO: Abstract this logic, it's repeated so many times
  int get runs => balls.fold<int>(0, (runs, ball) => runs + ball.totalRuns);
  int get ballsFaced => balls.fold<int>(
      0, (ballsFaced, ball) => ball.isLegal ? ballsFaced + 1 : ballsFaced);

  void play(Ball ball) {
    if (ball.batter != batter1 && ball.batter != batter2) {
      throw UnsupportedError(
          "Ball added to Partnership is not faced by any of the batters in the partnership.");
    }
    _balls.add(ball);
  }

  void unPlay(Ball ball) {
    if (_balls.isEmpty || _balls.last != ball) {
      throw UnsupportedError(
          "Attempted to undo a ball that isn't the last ball.");
    }
    _balls.removeLast();
  }
}

/// Represents a contribution made by one batter in a [Partnership].
///
/// Technically, this will be a subset of a batter's innings, consisting
/// of the balls that a batter played while the said partnership was active.
///
/// It must be noted that the runs scored by a Partnership is more than just
/// the sum of both batters' contributions, since a Partnership also consists
/// of runs awarded due to extras, which are not accounted for in either
/// batter's contribution.
class PartnershipContribution with BattingCalculations {
  final Player batter;
  final Partnership partnership;

  const PartnershipContribution(this.batter, {required this.partnership});

  @override
  UnmodifiableListView<Ball> get balls => UnmodifiableListView(
      partnership.balls.where((ball) => ball.batter == batter));
}
