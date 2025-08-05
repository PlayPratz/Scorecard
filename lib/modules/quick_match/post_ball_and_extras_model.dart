import 'package:scorecard/modules/quick_match/wicket_model.dart';

/// Represents an event that occurs during the progression of an innings.
/// The most common post is [Ball].
///
/// I really thought hard but could not come up with a name better than "Post".
/// It made sense because you are *posting* every event to this innings. I did
/// not want to name this InningsEvent because that sounds like a UI Event.
sealed class InningsPost {
  /// The ID of the Post as in the database
  int? id; // TODO Can make this final?

  /// The ID of the Match as in the database
  final String matchId;

  /// The ordinal number of the Innings
  final int inningsNumber;

  /// The index of this post in the innings
  final PostIndex index;

  /// The timestamp of this post
  final DateTime timestamp;

  /// Any comment that the user would like to add about this post
  final String? comment;

  InningsPost(
    this.id,
    this.matchId,
    this.inningsNumber, {
    required this.index,
    required this.timestamp,
    this.comment,
  });
}

/// A ball is the most major event in a game of cricket.
///
/// A bowler delivers the ball to a batter who then attempts to get bat on ball
/// and score runs.
class Ball extends InningsPost {
  /// The bowler who delivered this ball
  final String bowlerId;

  /// The batter who faced this ball
  final String batterId;

  /// Runs off the bat/ran by the batter(s)
  final int batterRuns;

  /// Whether this ball crossed the boundary fence.
  final bool isBoundary;

  /// A wicket, if any, that fell on this ball
  final Wicket? wicket;
  bool get isWicket => wicket != null;

  /// An extra due to the bowler or fielding team's fault
  final BowlingExtra? bowlingExtra;
  bool get isBowlingExtra => bowlingExtra != null;
  int get bowlingExtraRuns => bowlingExtra != null ? bowlingExtra!.penalty : 0;

  /// An extra when the batters score runs without the bat touching the ball
  final BattingExtra? battingExtra; // TODO Make this like BowlingExtra
  bool get isBattingExtra => battingExtra != null;
  int get battingExtraRuns => battingExtra != null ? battingExtra!.runs : 0;

  /// Total runs awarded to the Batting Team
  int get runs => batterRuns + bowlingExtraRuns + battingExtraRuns;

  Ball(
    super.id,
    super.matchId,
    super.inningsNumber, {
    required super.index,
    required super.timestamp,
    super.comment,
    required this.bowlerId,
    required this.batterId,
    required this.batterRuns,
    required this.isBoundary,
    required this.wicket,
    required this.bowlingExtra,
    required this.battingExtra,
  });
}

/// Posted when a Bowler Retires mid-over due to an injury, being sent off, or
/// any other reason.
///
/// This post should be followed by a [NextBowler] post since another bowler
/// will have to complete the remainder of the over.
///
/// Note: Not to be posted when an over is completed.
class BowlerRetire extends InningsPost {
  /// The bowler who retires
  final String bowlerId;

  /// The bowler's retirement
  // final RetiredBowler retired;

  BowlerRetire(
    super.id,
    super.matchId,
    super.inningsNumber, {
    required super.index,
    required super.timestamp,
    super.comment,
    required this.bowlerId,
    // required this.retired,
  });
}

/// Posted whenever a Bowler starts a new over or completes an over that was
/// started by another bowler.
class NextBowler extends InningsPost {
  /// The bowler who bowled the previous delivery
  final String? previousId;

  /// The bowler who will bowl the next delivery
  final String nextId;

  // final bool isMidOverChange;

  NextBowler(
    super.id,
    super.matchId,
    super.inningsNumber, {
    required super.index,
    required super.timestamp,
    super.comment,
    required this.previousId,
    required this.nextId,
    // required this.isMidOverChange
  });
}

/// Posted whenever a Batter Retires due to an injury, being sent off, or any
/// other reason.
///
/// This post should be followed by a [NextBatter] post since a new batter will
/// walk out to bat, unless the innings has ended due to this post.
class BatterRetire extends InningsPost {
  /// The batter's retirement
  final Retired retired;

  /// The batter who has retired
  String get batterId => retired.batterId;

  BatterRetire(
    super.id,
    super.matchId,
    super.inningsNumber, {
    required super.index,
    required super.timestamp,
    super.comment,
    // required this.batter,
    required this.retired,
  });
}

/// Posted whenever a New Batter walks out to bat.
class NextBatter extends InningsPost {
  /// The batter that was batting previously
  final String? previousId;

  /// The batter that has walked out to bat
  final String nextId;

  NextBatter(
    super.id,
    super.matchId,
    super.inningsNumber, {
    required super.index,
    required super.timestamp,
    super.comment,
    required this.previousId,
    required this.nextId,
  });
}

/// Posted whenever a batter is run out before a delivery is bowled by the
/// bowler.
///
/// This is to be used for run out at the non-striker's end before the ball is
/// bowled, as sensationalized by Ravichandran Ashwin
class RunoutBeforeDelivery extends InningsPost {
  /// The run out that took place before the ball was bowled
  final RunoutWicket wicket;

  String get batterId => wicket.batterId;

  RunoutBeforeDelivery(
    super.id,
    super.matchId,
    super.inningsNumber, {
    required super.index,
    required super.timestamp,
    super.comment,
    required this.wicket,
  });
}

// An index which locates events on a timeline of an innings.
/// Commonly represented as `over.ball`
class PostIndex {
  final int over;
  final int ball;

  const PostIndex(this.over, this.ball);

  const PostIndex.zero()
      : over = 0,
        ball = 0;

  @override
  String toString() => "$over.$ball";
}

/// A Bowling Extra is an extra due to the bowler's or the fielding team's
/// fault.
///
/// Due to a Bowling Extra, the batting team is awarded some extra runs in
/// their innings, usually one.
sealed class BowlingExtra {
  /// The amount of additional runs awarded to the Batting Team
  final int penalty;

  BowlingExtra(this.penalty);
}

class NoBall extends BowlingExtra {
  NoBall(super.penalty);
}

class Wide extends BowlingExtra {
  Wide(super.penalty);
}

/// A Batting Extra is an extra due to the striking batter's fault.
///
/// In case of a Batting Extra, the batting team is still awarded the runs, but
/// it's not accounted for in the batter's or the bowler's innings.
sealed class BattingExtra {
  /// Extra runs scored by the batting team
  final int runs;

  BattingExtra(this.runs);
}

/// A Batting Extra where the batters score runs after the striker get neither
/// bat nor body on ball.
class Bye extends BattingExtra {
  Bye(super.runs);
}

/// A Batting Extra where the batters score runs after the striker gets body,
/// but not bat, on ball.
class LegBye extends BattingExtra {
  LegBye(super.runs);
}
