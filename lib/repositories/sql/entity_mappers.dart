import 'package:scorecard/modules/player/player_model.dart';
import 'package:scorecard/modules/quick_match/post_ball_and_extras_model.dart';
import 'package:scorecard/modules/quick_match/quick_match_model.dart';
import 'package:scorecard/modules/quick_match/wicket_model.dart';
import 'package:scorecard/repositories/sql/db/quick_innings_table.dart';
import 'package:scorecard/repositories/sql/db/quick_matches_table.dart';
import 'package:scorecard/repositories/sql/db/players_table.dart';
import 'package:scorecard/repositories/sql/db/posts_table.dart';

class EntityMappers {
  EntityMappers._();

  static PlayersEntity repackPlayer(Player player) => PlayersEntity(
        id: player.id,
        name: player.name,
      );

  static Player unpackPlayer(PlayersEntity entity) => Player(
        entity.id,
        name: entity.name,
      );

  static QuickMatchesEntity repackQuickMatch(QuickMatch match) =>
      QuickMatchesEntity(
        id: match.id,
        type: 0,
        stage: match.isCompleted ? 1 : 0,
        starts_at: match.startsAt,
        rules_overs_per_innings: match.rules.oversPerInnings,
        rules_balls_per_over: match.rules.ballsPerOver,
        rules_no_ball_penalty: match.rules.noBallPenalty,
        rules_wide_penalty: match.rules.widePenalty,
      );

  static QuickMatch unpackQuickMatch(QuickMatchesEntity entity) =>
      QuickMatch.load(
        entity.id,
        startsAt: entity.starts_at,
        isCompleted: entity.stage == 1,
        rules: QuickMatchRules(
          oversPerInnings: entity.rules_overs_per_innings,
          ballsPerOver: entity.rules_balls_per_over,
          noBallPenalty: entity.rules_no_ball_penalty,
          widePenalty: entity.rules_wide_penalty,
        ),
      );

  static QuickInningsEntity repackQuickInnings(QuickInnings innings) {
    final extras = innings.extras;
    return QuickInningsEntity(
      id: innings.id,
      match_id: innings.matchId,
      innings_number: innings.inningsNumber,
      type: _inningsType(innings),
      is_completed: innings.isCompleted,
      is_declared: innings.isDeclared,
      is_forfeited: false,
      is_ended: innings.isEnded,
      overs_limit: innings.overLimit,
      balls_per_over: innings.ballsPerOver,
      target_runs: innings.target,
      runs: innings.runs,
      wickets: innings.wickets,
      balls: innings.balls,
      extras_no_balls: extras.noBalls,
      extras_wides: extras.wides,
      extras_byes: extras.byes,
      extras_leg_byes: extras.legByes,
      extras_penalties: extras.penalties,
      batter1_id: innings.batter1Id,
      batter2_id: innings.batter2Id,
      striker_id: innings.strikerId,
      bowler_id: innings.bowlerId,
    );
  }

  static QuickInnings unpackQuickInnings(
          QuickInningsEntity entity, QuickMatchRules rules) =>
      QuickInnings.load(
        entity.id,
        matchId: entity.match_id,
        inningsNumber: entity.innings_number,
        rules: rules,
        isCompleted: entity.is_completed,
        target: entity.target_runs,
        runs: entity.runs,
        wickets: entity.wickets,
        balls: entity.balls,
        extras: Extras(
          noBalls: entity.extras_no_balls,
          wides: entity.extras_wides,
          byes: entity.extras_byes,
          legByes: entity.extras_leg_byes,
          penalties: entity.extras_penalties,
        ),
        batter1Id: entity.batter1_id,
        batter2Id: entity.batter2_id,
        strikerId: entity.striker_id,
        bowlerId: entity.bowler_id,
        isDeclared: entity.is_declared,
        isSuperOver: _decipherInningsType(entity),
      );

  static int _inningsType(QuickInnings innings) =>
      innings.isSuperOver ? 100 : 0;

  static bool _decipherInningsType(QuickInningsEntity entity) =>
      entity.type == 100 ? true : false;

  static PostsEntity repackInningsPost(InningsPost post) => switch (post) {
        Ball() => PostsEntity.ball(
            id: post.id,
            innings_id: post.inningsId,
            match_id: post.matchId,
            innings_number: post.inningsNumber,
            day_number: null,
            session_number: null,
            index_over: post.index.over,
            index_ball: post.index.ball,
            timestamp: post.timestamp,
            type: 0,
            is_counted_for_bowler: post.isCountedForBowler,
            is_counted_for_batter: post.isCountedForBatter,
            comment: post.comment,
            bowler_id: post.bowlerId,
            batter_id: post.batterId,
            batter_runs: post.batterRuns,
            bowler_runs: post.bowlerRuns,
            total_runs: post.totalRuns,
            is_boundary: post.isBoundary,
            extras_no_balls: post.noBalls,
            extras_wides: post.wides,
            extras_byes: post.byes,
            extras_leg_byes: post.legByes,
            extras_penalties: 0, // TODO
            wicket_type: _wicketTypeToInt(post.wicket),
            wicket_batter_id: post.wicket?.batterId,
            wicket_fielder_id: post.wicket is FielderWicket
                ? (post.wicket as FielderWicket).fielderId
                : null,
          ),
        BowlerRetire() => PostsEntity.bowlerRetire(
            id: post.id,
            innings_id: post.inningsId,
            match_id: post.matchId,
            innings_number: post.inningsNumber,
            day_number: null,
            session_number: null,
            index_over: post.index.over,
            index_ball: post.index.ball,
            timestamp: post.timestamp,
            type: 1,
            is_counted_for_bowler: post.isCountedForBowler,
            is_counted_for_batter: post.isCountedForBatter,
            comment: post.comment,
            bowler_id: post.bowlerId,
          ),
        NextBowler() => PostsEntity.nextBowler(
            id: post.id,
            innings_id: post.inningsId,
            match_id: post.matchId,
            innings_number: post.inningsNumber,
            day_number: null,
            session_number: null,
            index_over: post.index.over,
            index_ball: post.index.ball,
            timestamp: post.timestamp,
            type: 2,
            is_counted_for_bowler: post.isCountedForBowler,
            is_counted_for_batter: post.isCountedForBatter,
            comment: post.comment,
            bowler_id: post.nextId,
            previous_id: post.previousId,
          ),
        BatterRetire() => PostsEntity.batterRetire(
            id: post.id,
            innings_id: post.inningsId,
            match_id: post.matchId,
            innings_number: post.inningsNumber,
            day_number: null,
            session_number: null,
            index_over: post.index.over,
            index_ball: post.index.ball,
            timestamp: post.timestamp,
            type: 3,
            is_counted_for_bowler: post.isCountedForBowler,
            is_counted_for_batter: post.isCountedForBatter,
            comment: post.comment,
            batter_id: post.retired.batterId,
            wicket_type: _retiredTypeToInt(post.retired),
            wicket_batter_id: post.retired.batterId,
          ),
        NextBatter() => PostsEntity.nextBatter(
            id: post.id,
            innings_id: post.inningsId,
            match_id: post.matchId,
            innings_number: post.inningsNumber,
            day_number: null,
            session_number: null,
            index_over: post.index.over,
            index_ball: post.index.ball,
            timestamp: post.timestamp,
            type: 4,
            is_counted_for_bowler: post.isCountedForBowler,
            is_counted_for_batter: post.isCountedForBatter,
            comment: post.comment,
            batter_id: post.nextId,
            previous_id: post.previousId,
          ),
        WicketBeforeDelivery() => PostsEntity.wicketBeforeDelivery(
            id: post.id,
            innings_id: post.inningsId,
            match_id: post.matchId,
            innings_number: post.inningsNumber,
            day_number: null,
            session_number: null,
            index_over: post.index.over,
            index_ball: post.index.ball,
            timestamp: post.timestamp,
            type: 5,
            is_counted_for_bowler: post.isCountedForBowler,
            is_counted_for_batter: post.isCountedForBatter,
            comment: post.comment,
            wicket_type: _wicketTypeToInt(post.wicket),
            wicket_batter_id: post.wicket.batterId,
            wicket_fielder_id: post.wicket.fielderId,
          ),
        Penalty() => PostsEntity.penalty(
            id: post.id,
            innings_id: post.inningsId,
            match_id: post.matchId,
            innings_number: post.inningsNumber,
            day_number: null,
            session_number: null,
            index_over: post.index.over,
            index_ball: post.index.ball,
            timestamp: post.timestamp,
            type: 6,
            is_counted_for_bowler: post.isCountedForBowler,
            is_counted_for_batter: post.isCountedForBatter,
            comment: post.comment,
            extras_penalties: post.penalties,
            total_runs: post.penalties,
          ),
      };

  static BowlingExtra? _decipherBowlingExtra(int noBalls, int wides) =>
      noBalls > 0
          ? NoBall(noBalls)
          : wides > 0
              ? Wide(wides)
              : null;

  static BattingExtra? _decipherBattingExtra(int byes, int legByes) => byes > 0
      ? Bye(byes)
      : legByes > 0
          ? LegBye(legByes)
          : null;

  static int? _retiredTypeToInt(Retired retired) => switch (retired) {
        RetiredDeclared() => -1,
        RetiredHurt() => -2,
      };

  static Retired? _decipherRetired(PostsEntity entity) =>
      switch (entity.wicket_type) {
        -1 => RetiredDeclared(batterId: entity.wicket_batter_id!),
        -2 => RetiredHurt(batterId: entity.wicket_batter_id!),
        null => null,
        _ => throw UnsupportedError(
            "retired_type (stored in wicket_type) out of bounds! (id: ${entity.id}, wicket_type: ${entity.wicket_type})")
      };

  static int? _wicketTypeToInt(Wicket? wicket) => switch (wicket) {
        BowledWicket() => 0,
        HitWicket() => 1,
        LbwWicket() => 2,
        CaughtWicket() => 3,
        StumpedWicket() => 4,
        RunoutWicket() => 5,
        TimedOutWicket() => 6,
        null => null,
      };

  static Wicket? _decipherWicket(PostsEntity entity) =>
      switch (entity.wicket_type) {
        0 => BowledWicket(
            batterId: entity.wicket_batter_id!,
            bowlerId: entity.bowler_id!,
          ),
        1 => HitWicket(
            batterId: entity.wicket_batter_id!,
            bowlerId: entity.bowler_id!,
          ),
        2 => LbwWicket(
            batterId: entity.wicket_batter_id!,
            bowlerId: entity.bowler_id!,
          ),
        3 => CaughtWicket(
            batterId: entity.wicket_batter_id!,
            bowlerId: entity.bowler_id!,
            fielderId: entity.wicket_fielder_id!,
          ),
        4 => StumpedWicket(
            batterId: entity.wicket_batter_id!,
            bowlerId: entity.bowler_id!,
            wicketkeeperId: entity.wicket_fielder_id!,
          ),
        5 => RunoutWicket(
            batterId: entity.wicket_batter_id!,
            fielderId: entity.wicket_fielder_id!,
          ),
        6 => TimedOutWicket(
            batterId: entity.wicket_batter_id!,
          ),
        null => null,
        _ => throw UnsupportedError(
            "wicket_type out of bounds! (id: ${entity.id}, wicket_type: ${entity.wicket_type})"),
      };

  static InningsPost unpackInningsPost(PostsEntity entity) =>
      switch (entity.type) {
        0 => Ball(
            entity.id,
            matchId: entity.match_id,
            inningsId: entity.innings_id,
            index: PostIndex(entity.index_over, entity.index_ball),
            inningsNumber: entity.innings_number,
            timestamp: entity.timestamp,
            comment: entity.comment,
            bowlerId: entity.bowler_id!,
            batterId: entity.batter_id!,
            batterRuns: entity.batter_runs!,
            isBoundary: entity.is_boundary!,
            wicket: _decipherWicket(entity),
            bowlingExtra: _decipherBowlingExtra(
                entity.extras_no_balls ?? 0, entity.extras_wides ?? 0),
            battingExtra: _decipherBattingExtra(
                entity.extras_byes ?? 0, entity.extras_leg_byes ?? 0),
          ),
        1 => BowlerRetire(
            entity.id,
            matchId: entity.match_id,
            inningsId: entity.innings_id,
            inningsNumber: entity.innings_number,
            index: PostIndex(entity.index_over, entity.index_ball),
            timestamp: entity.timestamp,
            comment: entity.comment,
            bowlerId: entity.bowler_id!,
          ),
        2 => NextBowler(
            entity.id,
            matchId: entity.match_id,
            inningsId: entity.innings_id,
            inningsNumber: entity.innings_number,
            index: PostIndex(entity.index_over, entity.index_ball),
            timestamp: entity.timestamp,
            comment: entity.comment,
            nextId: entity.bowler_id!,
            previousId: entity.previous_id,
          ),
        3 => BatterRetire(
            entity.id,
            matchId: entity.match_id,
            inningsId: entity.innings_id,
            inningsNumber: entity.innings_number,
            index: PostIndex(entity.index_over, entity.index_ball),
            timestamp: entity.timestamp,
            comment: entity.comment,
            retired: _decipherRetired(entity)!,
          ),
        4 => NextBatter(
            entity.id,
            matchId: entity.match_id,
            inningsId: entity.innings_id,
            inningsNumber: entity.innings_number,
            index: PostIndex(entity.index_over, entity.index_ball),
            timestamp: entity.timestamp,
            comment: entity.comment,
            nextId: entity.batter_id!,
            previousId: entity.previous_id,
          ),
        5 => WicketBeforeDelivery(
            entity.id,
            matchId: entity.match_id,
            inningsId: entity.innings_id,
            inningsNumber: entity.innings_number,
            index: PostIndex(entity.index_over, entity.index_ball),
            timestamp: entity.timestamp,
            comment: entity.comment,
            wicket: _decipherWicket(entity) as RunoutWicket,
          ),
        6 => Penalty(
            entity.id,
            matchId: entity.match_id,
            inningsId: entity.innings_id,
            inningsNumber: entity.innings_number,
            index: PostIndex(entity.index_over, entity.index_ball),
            timestamp: entity.timestamp,
            comment: entity.comment,
            penalties: entity.extras_penalties!,
          ),
        _ =>
          throw UnsupportedError("posts.type out of bounds! (id:${entity.id})"),
      };
}
