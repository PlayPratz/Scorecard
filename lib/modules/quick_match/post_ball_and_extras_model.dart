import 'package:scorecard/modules/quick_match/quick_match_model.dart';
import 'package:scorecard/modules/quick_match/wicket_model.dart';

/// Represents an event that occurs during the progression of an innings.
/// The most common post is [Ball].
///
/// I really thought hard but could not come up with a name better than "Post".
/// It made sense because you are *posting* every event to this innings. I did
/// not want to name this InningsEvent because that sounds like a UI Event.
sealed class InningsPost {
  /// The ID of the Post as in the database
  final int? id;

  /// The ID of the Match as in the database
  final int matchId;

  /// The ID of the Innings as in the database
  final int inningsId;

  /// The cardinal number of the Innings
  final int inningsNumber;

  /// The timestamp of this post
  final DateTime timestamp;

  /// The index of this post in the innings
  final PostIndex index;

  /// The score of the innings after this post was posted
  final Score scoreAt;

  /// Any comment that the user would like to add about this post
  final String? comment;

  /// The batter at the striker's end
  final int? batterId;

  /// The batter at the non-striker's end
  final int? nonStrikerId;

  /// The bowler who is to bowl the bal
  final int? bowlerId;

  String get code;

  InningsPost(
    this.id, {
    required this.matchId,
    required this.inningsId,
    required this.inningsNumber,
    required this.timestamp,
    required this.index,
    required this.scoreAt,
    required this.batterId,
    required this.bowlerId,
    required this.nonStrikerId,
    this.comment,
  });
}

/// A ball is the most major event in a game of cricket.
///
/// A bowler delivers the ball to a batter who then attempts to get bat on ball
/// and score runs.
class Ball extends InningsPost {
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
  int get noBalls => bowlingExtra is NoBall ? bowlingExtra!.penalty : 0;
  int get wides => bowlingExtra is Wide ? bowlingExtra!.penalty : 0;

  /// An extra when the batters score runs without the bat touching the ball
  final BattingExtra? battingExtra;
  bool get isBattingExtra => battingExtra != null;
  int get battingExtraRuns => battingExtra != null ? battingExtra!.runs : 0;
  int get byes => bowlingExtra is Bye ? battingExtra!.runs : 0;
  int get legByes => bowlingExtra is LegBye ? battingExtra!.runs : 0;

  /// TODO handle Penalties
  // bool get isExtra => isBowlingExtra || isBattingExtra;

  /// Total runs conceded by the bowler
  int get bowlerRuns => batterRuns + bowlingExtraRuns;

  /// Total runs awarded to the Batting Team
  int get totalRuns => batterRuns + bowlingExtraRuns + battingExtraRuns;

  Ball(
    super.id, {
    required super.matchId,
    required super.inningsId,
    required super.inningsNumber,
    required super.timestamp,
    required super.index,
    required super.scoreAt,
    super.comment,
    required super.bowlerId,
    required super.batterId,
    required super.nonStrikerId,
    required this.batterRuns,
    required this.isBoundary,
    required this.wicket,
    required this.bowlingExtra,
    required this.battingExtra,
  });

  @override
  String get code => "ball";
}

/// Posted when a Bowler Retires mid-over due to an injury, being sent off, or
/// any other reason.
///
/// This post should be followed by a [NextBowler] post since another bowler
/// will have to complete the remainder of the over.
///
/// Note: Not to be posted when an over is completed.
class BowlerRetire extends InningsPost {
  BowlerRetire(
    super.id, {
    required super.matchId,
    required super.inningsId,
    required super.inningsNumber,
    required super.timestamp,
    required super.index,
    required super.scoreAt,
    super.comment,
    required super.bowlerId,
    required super.batterId,
    required super.nonStrikerId,
  });

  @override
  String get code => "bowler retire";
}

/// Posted whenever a Bowler starts a new over or completes an over that was
/// started by another bowler.
class NextBowler extends InningsPost {
  /// The next bowler of the match
  final int nextId;

  NextBowler(
    super.id, {
    required super.matchId,
    required super.inningsId,
    required super.inningsNumber,
    required super.timestamp,
    required super.index,
    required super.scoreAt,
    required super.bowlerId,
    required super.batterId,
    required super.nonStrikerId,
    super.comment,
    required this.nextId,
    // required this.isMidOverChange
  });

  @override
  String get code => "next bowler";
}

/// Posted whenever a Batter Retires due to an injury, being sent off, or any
/// other reason.
///
/// This post should be followed by a [NextBatter] post since a new batter will
/// walk out to bat, unless the innings has ended due to this post.
class BatterRetire extends InningsPost {
  /// The batter's retirement
  final Retired retired;

  BatterRetire(
    super.id, {
    required super.matchId,
    required super.inningsId,
    required super.inningsNumber,
    required super.timestamp,
    required super.index,
    required super.scoreAt,
    required super.bowlerId,
    required super.batterId,
    required super.nonStrikerId,
    super.comment,
    required this.retired,
  });

  @override
  String get code => "batter retire";
}

/// Posted whenever a New Batter walks out to bat.
class NextBatter extends InningsPost {
  /// The batter that was batting previously
  final int? previousId;

  /// The batter that has walked out to bat
  final int nextId;

  NextBatter(
    super.id, {
    required super.matchId,
    required super.inningsId,
    required super.inningsNumber,
    required super.timestamp,
    required super.index,
    required super.scoreAt,
    required super.bowlerId,
    required super.batterId,
    required super.nonStrikerId,
    super.comment,
    required this.previousId,
    required this.nextId,
  });

  @override
  String get code => "next batter";
}

/// Posted whenever a batter is run out before a delivery is bowled by the
/// bowler.
///
/// This is to be used for run out at the non-striker's end before the ball is
/// bowled, as sensationalized by Ravichandran Ashwin
class WicketBeforeDelivery extends InningsPost {
  /// The run out that took place before the ball was bowled
  final Wicket wicket;

  WicketBeforeDelivery(
    super.id, {
    required super.matchId,
    required super.inningsId,
    required super.inningsNumber,
    required super.timestamp,
    required super.index,
    required super.scoreAt,
    super.comment,
    required this.wicket,
    required super.bowlerId,
    required super.batterId,
    required super.nonStrikerId,
  });

  @override
  String get code => "wicket before delivery";
}

/// Posted whenever penalty runs are awarded to the batting team
class Penalty extends InningsPost {
  final int penalties;

  Penalty(
    super.id, {
    required super.matchId,
    required super.inningsId,
    required super.inningsNumber,
    required super.timestamp,
    required super.index,
    required super.scoreAt,
    super.comment,
    required this.penalties,
    required super.bowlerId,
    required super.batterId,
    required super.nonStrikerId,
  });

  @override
  String get code => "penalty";
}

/// Posted whenever there is a break in play in the Innings
class Break extends InningsPost {
  final int breakType;

  Break(
    super.id, {
    required super.matchId,
    required super.inningsId,
    required super.inningsNumber,
    required super.timestamp,
    required super.index,
    required super.scoreAt,
    required this.breakType,
    required super.bowlerId,
    required super.batterId,
    required super.nonStrikerId,
  });

  @override
  String get code => "break";
}

// An index which locates events on a timeline of an innings.
/// Commonly represented as `over.ball`
class PostIndex {
  final int over;
  final int ball;

  const PostIndex(this.over, this.ball);

  const PostIndex.of(int ballsBowled, int ballsPerOver)
      : over = ballsBowled ~/ ballsPerOver,
        ball = ballsBowled % ballsPerOver;

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
