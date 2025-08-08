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
        rules_balls_per_over: match.rules.ballsPerOver,
        rules_balls_per_innings: match.rules.ballsPerInnings,
        rules_no_ball_penalty: match.rules.noBallPenalty,
        rules_wide_penalty: match.rules.widePenalty,
        rules_only_single_batter: match.rules.onlySingleBatter,
      );

  static QuickMatch unpackQuickMatch(QuickMatchesEntity entity) =>
      QuickMatch.load(
        entity.id,
        startsAt: entity.starts_at,
        isCompleted: entity.stage == 1,
        rules: QuickMatchRules(
          ballsPerOver: entity.rules_balls_per_over,
          ballsPerInnings: entity.rules_balls_per_innings,
          noBallPenalty: entity.rules_no_ball_penalty,
          widePenalty: entity.rules_wide_penalty,
          onlySingleBatter: entity.rules_only_single_batter,
        ),
      );

  static QuickInningsEntity repackQuickInnings(QuickInnings innings) =>
      QuickInningsEntity(
        id: innings.id,
        match_id: innings.matchId,
        innings_number: innings.inningsNumber,
        type: _inningsType(innings),
        is_declared: innings.isDeclared,
        batter1_id: innings.batter1Id,
        batter2_id: innings.batter2Id,
        striker_id: innings.strikerId,
        bowler_id: innings.bowlerId,
        target_runs: innings.target,
      );

  static QuickInnings unpackQuickInnings(
          QuickInningsEntity entity, QuickMatchRules rules) =>
      QuickInnings.load(
        entity.id,
        matchId: entity.match_id,
        inningsNumber: entity.innings_number,
        rules: rules,
        target: entity.target_runs,
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
            // innings_number: post.inningsNumber,
            index_over: post.index.over,
            index_ball: post.index.ball,
            timestamp: post.timestamp,
            type: 0,
            comment: post.comment,
            bowler_id: post.bowlerId,
            batter_id: post.batterId,
            batter_runs: post.batterRuns,
            bowler_runs: post.bowlerRuns,
            total_runs: post.totalRuns,
            is_boundary: post.isBoundary,
            wicket_type: _wicketTypeToInt(post.wicket),
            wicket_batter_id: post.wicket?.batterId,
            wicket_fielder_id: post.wicket is FielderWicket
                ? (post.wicket as FielderWicket).fielderId
                : null,
            bowling_extra_type: _bowlingExtraTypeToInt(post.bowlingExtra),
            bowling_extra_penalty: post.bowlingExtraRuns,
            batting_extra_type: _battingExtraType(post.battingExtra),
            batting_extra_runs: post.battingExtraRuns,
          ),
        BowlerRetire() => PostsEntity.bowlerRetire(
            id: post.id,
            innings_id: post.inningsId,
            match_id: post.matchId,
            // innings_number: post.inningsNumber,
            index_over: post.index.over,
            index_ball: post.index.ball,
            timestamp: post.timestamp,
            type: 1,
            comment: post.comment,
            bowler_id: post.bowlerId,
          ),
        NextBowler() => PostsEntity.nextBowler(
            id: post.id,
            innings_id: post.inningsId,
            match_id: post.matchId,
            // innings_number: post.inningsNumber,
            index_over: post.index.over,
            index_ball: post.index.ball,
            timestamp: post.timestamp,
            type: 2,
            comment: post.comment,
            bowler_id: post.nextId,
            wicket_fielder_id: post.previousId,
          ),
        BatterRetire() => PostsEntity.batterRetire(
            id: post.id,
            innings_id: post.inningsId,
            match_id: post.matchId,
            // innings_number: post.inningsNumber,
            index_over: post.index.over,
            index_ball: post.index.ball,
            timestamp: post.timestamp,
            type: 3,
            comment: post.comment,
            wicket_batter_id: post.retired.batterId,
            wicket_type: _retiredTypeToInt(post.retired),
          ),
        NextBatter() => PostsEntity.nextBatter(
            id: post.id,
            innings_id: post.inningsId,
            match_id: post.matchId,
            // innings_number: post.inningsNumber,
            index_over: post.index.over,
            index_ball: post.index.ball,
            timestamp: post.timestamp,
            type: 4,
            comment: post.comment,
            batter_id: post.nextId,
            wicket_batter_id: post.previousId,
          ),
        WicketBeforeDelivery() => PostsEntity.wicketBeforeDelivery(
            id: post.id,
            innings_id: post.inningsId,
            match_id: post.matchId,
            // innings_number: post.inningsNumber,
            index_over: post.index.over,
            index_ball: post.index.ball,
            timestamp: post.timestamp,
            type: 5,
            comment: post.comment,
            wicket_type: _wicketTypeToInt(post.wicket),
            wicket_batter_id: post.wicket.batterId,
            wicket_fielder_id: post.wicket.fielderId,
          ),
      };

  static int? _bowlingExtraTypeToInt(BowlingExtra? bowlingExtra) =>
      switch (bowlingExtra) {
        null => null,
        Wide() => 0,
        NoBall() => 1,
      };

  static BowlingExtra? _decipherBowlingExtra(int? extra, int? penalty) =>
      switch (extra) {
        0 => Wide(penalty!),
        1 => NoBall(penalty!),
        null => null,
        _ => throw UnsupportedError("bowling_extra_type out of bounds!"),
      };

  static int? _battingExtraType(BattingExtra? battingExtra) =>
      switch (battingExtra) {
        null => null,
        Bye() => 0,
        LegBye() => 1,
      };

  static BattingExtra? _decipherBattingExtra(int? extra, int? runs) =>
      switch (extra) {
        0 => Bye(runs!),
        1 => LegBye(runs!),
        null => null,
        _ => throw UnsupportedError("batting_extra_type out of bounds!"),
      };

  static int? _retiredTypeToInt(Retired retired) => switch (retired) {
        RetiredDeclared() => 0,
        RetiredHurt() => 1,
      };

  static Retired? _decipherRetired(PostsEntity entity) =>
      switch (entity.wicket_type) {
        0 => RetiredDeclared(batterId: entity.wicket_batter_id!),
        1 => RetiredHurt(batterId: entity.wicket_batter_id!),
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
            timestamp: entity.timestamp,
            comment: entity.comment,
            bowlerId: entity.bowler_id!,
            batterId: entity.batter_id!,
            batterRuns: entity.batter_runs!,
            isBoundary: entity.is_boundary!,
            wicket: _decipherWicket(entity),
            bowlingExtra: _decipherBowlingExtra(
                entity.bowling_extra_type, entity.bowling_extra_penalty),
            battingExtra: _decipherBattingExtra(
                entity.batting_extra_type, entity.batting_extra_runs),
          ),
        1 => BowlerRetire(
            entity.id,
            matchId: entity.match_id,
            inningsId: entity.innings_id,
            index: PostIndex(entity.index_over, entity.index_ball),
            timestamp: entity.timestamp,
            comment: entity.comment,
            bowlerId: entity.bowler_id!,
          ),
        2 => NextBowler(
            entity.id,
            matchId: entity.match_id,
            inningsId: entity.innings_id,
            index: PostIndex(entity.index_over, entity.index_ball),
            timestamp: entity.timestamp,
            comment: entity.comment,
            nextId: entity.bowler_id!,
            previousId: entity.wicket_fielder_id,
          ),
        3 => BatterRetire(
            entity.id,
            matchId: entity.match_id,
            inningsId: entity.innings_id,
            index: PostIndex(entity.index_over, entity.index_ball),
            timestamp: entity.timestamp,
            comment: entity.comment,
            retired: _decipherRetired(entity)!,
          ),
        4 => NextBatter(
            entity.id,
            matchId: entity.match_id,
            inningsId: entity.innings_id,
            index: PostIndex(entity.index_over, entity.index_ball),
            timestamp: entity.timestamp,
            comment: entity.comment,
            nextId: entity.batter_id!,
            previousId: entity.wicket_batter_id,
          ),
        5 => WicketBeforeDelivery(
            entity.id,
            matchId: entity.match_id,
            inningsId: entity.innings_id,
            index: PostIndex(entity.index_over, entity.index_ball),
            timestamp: entity.timestamp,
            comment: entity.comment,
            wicket: _decipherWicket(entity) as RunoutWicket,
          ),
        _ =>
          throw UnsupportedError("posts.type out of bounds! (id:${entity.id})"),
      };
}
