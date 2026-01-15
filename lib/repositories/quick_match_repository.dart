import 'dart:collection';

import 'package:scorecard/handlers/sql_db_handler.dart';
import 'package:scorecard/modules/quick_match/post_ball_and_extras_model.dart';
import 'package:scorecard/modules/quick_match/quick_match_model.dart';
import 'package:scorecard/modules/quick_match/wicket_model.dart';
import 'package:scorecard/repositories/lookup_config.dart';
import 'package:scorecard/repositories/sql/keys.dart';
import 'package:sqflite/sqflite.dart';

abstract class IQuickMatchRepository {
  Future<QuickMatch> createMatch(QuickMatch match);

  Future<void> deleteMatch(QuickMatch match);

  Future<UnmodifiableListView<QuickMatch>> loadAllMatches();

  Future<QuickMatch> loadMatch(int id);

  Future<QuickMatch> updateMatch(QuickMatch match);

  Future<QuickInnings> createInnings(QuickInnings innings);

  Future<void> updateInnings(QuickInnings innings);

  Future<QuickInnings> loadInnings(int id);

  Future<UnmodifiableListView<QuickInnings>> loadAllInningsOf(int matchId);

  Future<InningsPost> createPost(InningsPost post);

  Future<void> deletePost(InningsPost post);

  Future<InningsPost?> loadLastPostOf(QuickInnings innings);

  Future<int> loadPostCount(QuickInnings innings);

  Future<UnmodifiableListView<InningsPost>> loadAllPostsOf(
    QuickInnings innings,
  );

  Future<UnmodifiableListView<Ball>> loadAllBallsOf(QuickInnings innings);

  Future<UnmodifiableListView<Ball>> loadRecentBallsOf(
    QuickInnings innings,
    int count,
  );

  // Future<Iterable<Over>> loadOversOf(QuickInnings innings);

  Future<UnmodifiableListView<BattingScore>> loadBattersOf(
    QuickInnings innings,
  );

  Future<void> createBattingScore(BattingScore battingScore);

  Future<void> deleteBattingScore(int battingScoreId);

  Future<BattingScore?> loadLastBattingScoreOf(
    QuickInnings innings,
    int batterId,
  );

  Future<Iterable<Partnership>> loadPartnershipsOf(QuickInnings innings);

  Future<Partnership> createPartnership(Partnership partnership);

  Future<UnmodifiableListView<BowlingScore>> loadBowlersOf(
    QuickInnings innings,
  );

  Future<void> createBowlingScore(BowlingScore bowlingScore);

  Future<void> deleteBowlingScore(int bowlingScoreId);

  Future<BowlingScore?> loadBowlingScoreOf(QuickInnings innings, int bowlerId);

  Future<UnmodifiableListView<FallOfWicket>> loadWicketsOf(
    QuickInnings innings,
  );
}

class SQLQuickMatchRepository implements IQuickMatchRepository {
  final SQLDBHandler _sql;
  final LookupConfig _config;

  SQLQuickMatchRepository(this._sql, this._config);

  @override
  Future<UnmodifiableListView<QuickMatch>> loadAllMatches() async {
    final entities = await _sql.query(
      table: Tables.quickMatches,
      orderBy: "id DESC",
    );
    final matches = entities.map(_unpackQuickMatch);
    return UnmodifiableListView(matches);
  }

  @override
  Future<QuickMatch> loadMatch(int id) async {
    final entity = await _sql.query(
      table: Tables.quickMatches,
      where: "id = ?",
      whereArgs: [id],
    );
    final match = _unpackQuickMatch(entity.single);
    return match;
  }

  @override
  Future<QuickMatch> createMatch(QuickMatch match) async {
    final id = await _sql.insert(
      table: Tables.quickMatches,
      values: _repackQuickMatch(match),
    );
    final entity = await _sql.query(
      table: Tables.quickMatches,
      where: "id = ?",
      whereArgs: [id],
    );
    final newMatch = _unpackQuickMatch(entity.single);
    return newMatch;
  }

  @override
  Future<QuickMatch> updateMatch(QuickMatch match) async {
    await _sql.update(
      table: Tables.quickMatches,
      values: _repackQuickMatch(match),
      where: "id = ?",
      whereArgs: [match.id],
    );

    return await loadMatch(match.id!);
  }

  @override
  Future<void> deleteMatch(QuickMatch match) async {
    await _sql.delete(
      table: Tables.quickMatches,
      where: "id = ?",
      whereArgs: [match.id],
    );
  }

  @override
  Future<QuickInnings> createInnings(QuickInnings innings) async {
    final id = await _sql.insert(
      table: Tables.quickInnings,
      values: _repackQuickInnings(innings),
    );

    return loadInnings(id);
  }

  @override
  Future<void> updateInnings(QuickInnings innings) async {
    if (innings.id == null) {
      throw StateError("Attempted to update innings with null ID!");
    }

    await _sql.update(
      table: Tables.quickInnings,
      where: "id = ?",
      whereArgs: [innings.id],
      values: _repackQuickInnings(innings),
    );
  }

  @override
  Future<QuickInnings> loadInnings(int id) async {
    final entity = await _sql.query(
      table: Tables.quickInnings,
      where: "id = ?",
      whereArgs: [id],
    );
    final innings = _unpackQuickInnings(entity.single);
    return innings;
  }

  @override
  Future<InningsPost> createPost(InningsPost post) async {
    final id = await _sql.insert(
      table: Tables.posts,
      values: _repackInningsPost(post),
    );

    final entity = await _sql.query(
      table: Tables.posts,
      where: "id = ?",
      whereArgs: [id],
    );

    final newPost = _unpackInningsPost(entity.single);
    return newPost;
  }

  @override
  Future<void> deletePost(InningsPost post) async {
    await _sql.delete(
      table: Tables.posts,
      where: "id = ?",
      whereArgs: [post.id],
    );
  }

  @override
  Future<InningsPost?> loadLastPostOf(QuickInnings innings) async {
    final entity = await _sql.query(
      table: Tables.posts,
      where: "innings_id = ?",
      whereArgs: [innings.id],
      orderBy: "id DESC",
      limit: 1,
    );
    if (entity.isEmpty) {
      return null;
    }
    final post = _unpackInningsPost(entity.single);
    return post;
  }

  @override
  Future<UnmodifiableListView<QuickInnings>> loadAllInningsOf(
    int matchId,
  ) async {
    final entities = await _sql.query(
      table: Tables.quickInnings,
      where: "match_id = ?",
      whereArgs: [matchId],
    );
    final innings = entities.map(_unpackQuickInnings);
    return UnmodifiableListView(innings);
  }

  @override
  Future<int> loadPostCount(QuickInnings innings) async {
    final entity = await _sql.rawQuery(
      "SELECT COUNT(id) FROM ${Tables.posts} WHERE innings_id = ${innings.id}",
    );
    final count = Sqflite.firstIntValue(entity);
    return count!;
  }

  @override
  Future<UnmodifiableListView<InningsPost>> loadAllPostsOf(
    QuickInnings innings,
  ) async {
    final entities = await _sql.query(
      table: Tables.posts,
      where: "innings_id = ?",
      whereArgs: [innings.id],
    );
    final posts = entities.map(_unpackInningsPost);
    return UnmodifiableListView(posts);
  }

  @override
  Future<UnmodifiableListView<Ball>> loadAllBallsOf(
    QuickInnings innings,
  ) async {
    final entities = await _sql.query(
      table: Views.balls,
      where: "innings_id = ?",
      whereArgs: [innings.id],
    );
    final balls = entities.map(_unpackInningsPost).cast<Ball>();
    return UnmodifiableListView(balls);
  }

  @override
  Future<UnmodifiableListView<Ball>> loadRecentBallsOf(
    QuickInnings innings,
    int count,
  ) async {
    final entities = await _sql.query(
      table: Views.balls,
      where: "innings_id = ?",
      whereArgs: [innings.id],
      limit: count,
      orderBy: "id DESC",
    );
    final posts = entities.map(_unpackInningsPost).cast<Ball>();
    return UnmodifiableListView(posts);
  }

  // @override
  // Future<Iterable<Over>> loadOversOf(QuickInnings innings) async {
  //   final entities = await _sql.query(
  //     table: Tables.posts,
  //     groupBy: "innings_id, over_index",
  //     columns: [
  //       "over_index",
  //       "SUM(total_runs) AS total_runs",
  //       "COUNT(CASE WHEN wicket_type IS NOT NULL THEN 1 ELSE NULL END) AS wickets"
  //     ],
  //     where: "innings_id = ?",
  //     whereArgs: [innings.id],
  //   );
  //
  //   final overs = entities.map((e) => Over(
  //       overNumber: e["over_index"] as int,
  //       scoreIn: Score(e["total_runs"] as int, e["wickets"] as int)));
  //
  //   return overs;
  // }

  @override
  Future<void> createBattingScore(BattingScore battingScore) async {
    await _sql.insert(
      table: Tables.battingScores,
      values: _repackBattingScore(battingScore),
    );
  }

  @override
  Future<void> deleteBattingScore(int battingScoreId) async {
    await _sql.delete(
      table: Tables.battingScores,
      where: "id = ?",
      whereArgs: [battingScoreId],
    );
  }

  @override
  Future<UnmodifiableListView<BattingScore>> loadBattersOf(
    QuickInnings innings,
  ) async {
    final entities = await _sql.query(
      table: Tables.battingScores,
      where: "innings_id = ?",
      whereArgs: [innings.id],
      orderBy: "id ASC",
    );
    final battingScores = entities.map(_unpackBattingScore);
    return UnmodifiableListView(battingScores);
  }

  @override
  Future<BattingScore?> loadLastBattingScoreOf(
    QuickInnings innings,
    int batterId,
  ) async {
    final entity = await _sql.query(
      table: Tables.battingScores,
      where: "innings_id = ? AND player_id = ?",
      whereArgs: [innings.id, batterId],
      orderBy: "id DESC",
      limit: 1,
    );
    if (entity.isEmpty) {
      return null;
    }
    final battingScore = _unpackBattingScore(entity.single);
    return battingScore;
  }

  @override
  Future<Partnership> createPartnership(Partnership partnership) async {
    final id = await _sql.insert(
      table: Tables.partnerships,
      values: _repackPartnership(partnership),
    );

    final entity = await _sql.query(
      table: Tables.partnerships,
      where: "id = ?",
      whereArgs: [id],
    );
    final newPartnership = _unpackPartnership(entity.single);
    return newPartnership;
  }

  @override
  Future<Iterable<Partnership>> loadPartnershipsOf(QuickInnings innings) async {
    final entities = await _sql.query(
      table: Tables.partnerships,
      where: "innings_id = ?",
      whereArgs: [innings.id],
    );

    final partnerships = entities.map(_unpackPartnership);
    return partnerships;
  }

  @override
  Future<void> createBowlingScore(BowlingScore bowlingScore) async {
    await _sql.insert(
      table: Tables.bowlingScores,
      values: _repackBowlingScore(bowlingScore),
    );
  }

  @override
  Future<void> deleteBowlingScore(int bowlingScoreId) async {
    await _sql.delete(
      table: Tables.bowlingScores,
      where: "id = ?",
      whereArgs: [bowlingScoreId],
    );
  }

  @override
  Future<UnmodifiableListView<BowlingScore>> loadBowlersOf(
    QuickInnings innings,
  ) async {
    final entities = await _sql.query(
      table: Tables.bowlingScores,
      where: "innings_id = ?",
      whereArgs: [innings.id],
      orderBy: "id ASC",
    );
    final bowlingScores = entities.map(_unpackBowlingScore);
    return UnmodifiableListView(bowlingScores);
  }

  @override
  Future<BowlingScore?> loadBowlingScoreOf(
    QuickInnings innings,
    int bowlerId,
  ) async {
    final entity = await _sql.query(
      table: Tables.bowlingScores,
      where: "innings_id = ? AND player_id = ?",
      whereArgs: [innings.id, bowlerId],
    );
    if (entity.isEmpty) {
      return null;
    }
    final bowlingScore = _unpackBowlingScore(entity.single);
    return bowlingScore;
  }

  @override
  Future<UnmodifiableListView<FallOfWicket>> loadWicketsOf(
    QuickInnings innings,
  ) async {
    final entities = await _sql.query(
      table: Views.wickets,
      where: "innings_id = ?",
      whereArgs: [innings.id],
    );

    final fallOfWickets = entities.map(
      (e) => FallOfWicket(
        _decipherWicket(
          e["wicket_type"] as int,
          batterId: e["batter_id"] as int,
          bowlerId: e["bowler_id"] as int?,
          fielderId: e["fielder_id"] as int?,
        )!,
        postIndex: PostIndex(e["over_index"] as int, e["ball_index"] as int),
        scoreAt: Score(e["runs_at"] as int, e["wickets_at"] as int),
      ),
    );
    return UnmodifiableListView(fallOfWickets);
  }

  Map<String, Object?> _repackQuickMatch(QuickMatch match) => {
    "id": match.id,
    "handle": match.handle,
    "type": 1,
    "stage": match.stage,
    "starts_at": match.startsAt.millisecondsSinceEpoch,
    "venue_id": null,
    "overs_per_innings": match.rules.oversPerInnings,
    "balls_per_over": match.rules.ballsPerOver,
  };

  QuickMatch _unpackQuickMatch(Map<String, Object?> map) => QuickMatch(
    id: map["id"] as int,
    handle: map["handle"] as String,
    rules: QuickMatchRules(
      oversPerInnings: map["overs_per_innings"] as int,
      ballsPerOver: map["balls_per_over"] as int,
    ),
    startsAt: DateTime.fromMillisecondsSinceEpoch(map["starts_at"] as int),
    stage: map["stage"] as int,
  );

  Map<String, Object?> _repackQuickInnings(QuickInnings innings) => {
    "id": innings.id,
    "match_id": innings.matchId,
    "innings_number": innings.inningsNumber,
    "type": innings.type,
    "status": innings.status,
    "overs_limit": innings.overLimit,
    "balls_per_over": innings.ballsPerOver,
    "target_runs": innings.target,
    "batter1_id": innings.batter1Id,
    "batter2_id": innings.batter2Id,
    "striker": innings.striker,
    "bowler_id": innings.bowlerId,
  };

  QuickInnings _unpackQuickInnings(Map<String, Object?> map) => QuickInnings(
    id: map["id"] as int,
    matchId: map["match_id"] as int,
    inningsNumber: map["innings_number"] as int,
    type: map["type"] as int,
    status: map["status"] as int,
    overLimit: map["overs_limit"] as int,
    ballsPerOver: map["balls_per_over"] as int,
    target: map["target_runs"] as int?,
    runs: map["runs"] as int,
    wickets: map["wickets"] as int,
    balls: map["balls"] as int,
    extras: Extras(
      noBalls: map["extras_no_balls"] as int,
      wides: map["extras_wides"] as int,
      byes: map["extras_byes"] as int,
      legByes: map["extras_leg_byes"] as int,
      penalties: map["extras_penalties"] as int,
    ),
    batter1Id: map["batter1_id"] as int?,
    batter2Id: map["batter2_id"] as int?,
    striker: map["striker"] as int,
    bowlerId: map["bowler_id"] as int?,
  );

  static Wicket? _decipherWicket(
    int? wicketType, {
    required int? batterId,
    required int? bowlerId,
    required int? fielderId,
  }) => switch (wicketType) {
    101 => Bowled(batterId: batterId!, bowlerId: bowlerId!),
    111 => Lbw(batterId: batterId!, bowlerId: bowlerId!),
    131 => HitWicket(batterId: batterId!, bowlerId: bowlerId!),
    151 => Caught(
      batterId: batterId!,
      bowlerId: bowlerId!,
      fielderId: fielderId!,
    ),
    152 => CaughtAndBowled(batterId: batterId!, bowlerId: bowlerId!),
    171 => Stumped(
      batterId: batterId!,
      bowlerId: bowlerId!,
      wicketkeeperId: fielderId!,
    ),
    191 => RunOut(batterId: batterId!, fielderId: fielderId!),
    201 => ObstructingTheField(batterId: batterId!),
    211 => HitTheBallTwice(batterId: batterId!),
    301 => TimedOut(batterId: batterId!),
    401 => RetiredOut(batterId: batterId!),
    501 => RetiredNotOut(batterId: batterId!),
    null => null,
    _ => throw UnsupportedError(
      "wicket_type out of bounds! (wicket_type: $wicketType)",
    ),
  };

  Map<String, Object?> _repackBattingScore(BattingScore battingScore) => {
    "match_id": battingScore.matchId,
    "innings_id": battingScore.inningsId,
    "innings_number": battingScore.inningsNumber,
    "innings_type": battingScore.inningsType,
    "player_id": battingScore.batterId,
  };

  BattingScore _unpackBattingScore(Map<String, Object?> map) => BattingScore(
    id: map["id"] as int,
    matchId: map["match_id"] as int,
    inningsId: map["innings_id"] as int,
    inningsNumber: map["innings_number"] as int,
    inningsType: map["innings_type"] as int,
    batterId: map["player_id"] as int,
    battingAt: map["batting_at"] as int,
    runsScored: map["runs_scored"] as int,
    ballsFaced: map["balls_faced"] as int,
    isNotOut: readBool(map["not_out"])!,
    wicket: _decipherWicket(
      map["wicket_type"] as int?,
      batterId: map["player_id"] as int?,
      bowlerId: map["wicket_bowler_id"] as int?,
      fielderId: map["wicket_fielder_id"] as int?,
    ),
    fours: map["fours_scored"] as int,
    sixes: map["sixes_scored"] as int,
    boundaries: map["boundaries_scored"] as int,
    strikeRate: map["strike_rate"] as double? ?? double.infinity,
  );

  Map<String, Object?> _repackPartnership(Partnership partnership) => {
    "match_id": partnership.matchId,
    "innings_id": partnership.inningsId,
    "innings_number": partnership.inningsNumber,
    "innings_type": partnership.inningsType,
    "batter1_id": partnership.batter1Id,
    "batter2_id": partnership.batter2Id,
    // If not generated:
    "runs_scored": partnership.runs,
    "balls_faced": partnership.balls,
    "wicket_number": partnership.partnershipNumber,
    "batter1_runs_scored": partnership.batter1Runs,
    "batter1_balls_faced": partnership.batter1Balls,
    "batter2_runs_scored": partnership.batter2Runs,
    "batter2_balls_faced": partnership.batter2Balls,
    "extras_no_balls": partnership.extras.noBalls,
    "extras_wides": partnership.extras.wides,
    "extras_byes": partnership.extras.byes,
    "extras_leg_byes": partnership.extras.legByes,
    "extras_penalties": partnership.extras.penalties,
  };

  Partnership _unpackPartnership(Map<String, Object?> map) => Partnership(
    id: map["id"] as int,
    matchId: map["match_id"] as int,
    inningsId: map["innings_id"] as int,
    inningsNumber: map["innings_number"] as int,
    inningsType: map["innings_type"] as int,
    runs: map["runs_scored"] as int,
    balls: map["balls_faced"] as int,
    partnershipNumber: map["wicket_number"] as int,
    batter1Id: map["batter1_id"] as int,
    batter1Runs: map["batter1_runs_scored"] as int,
    batter1Balls: map["batter1_balls_faced"] as int,
    batter2Id: map["batter2_id"] as int,
    batter2Runs: map["batter2_runs_scored"] as int,
    batter2Balls: map["batter2_balls_faced"] as int,
    extras: Extras(
      noBalls: map["extras_no_balls"] as int,
      wides: map["extras_wides"] as int,
      byes: map["extras_byes"] as int,
      legByes: map["extras_leg_byes"] as int,
      penalties: map["extras_penalties"] as int,
    ),
  );

  Map<String, Object?> _repackBowlingScore(BowlingScore bowlingScore) => {
    "match_id": bowlingScore.matchId,
    "innings_id": bowlingScore.inningsId,
    "innings_number": bowlingScore.inningsNumber,
    "innings_type": bowlingScore.inningsType,
    "player_id": bowlingScore.bowlerId,
  };

  BowlingScore _unpackBowlingScore(Map<String, Object?> map) => BowlingScore(
    id: map["id"] as int,
    matchId: map["match_id"] as int,
    inningsId: map["innings_id"] as int,
    inningsNumber: map["innings_number"] as int,
    inningsType: map["innings_type"] as int,
    bowlerId: map["player_id"] as int,
    ballsBowled: map["balls_bowled"] as int,
    runsConceded: map["runs_conceded"] as int,
    wicketsTaken: map["wickets_taken"] as int,
    noBallsBowled: map["extras_no_balls"] as int,
    widesBowled: map["extras_wides"] as int,
    extrasBowled: map["extras_total"] as int,
    economy: map["economy"] as double? ?? double.infinity,
  );

  Map<String, Object?> _repackInningsPost(InningsPost post) {
    final entity = switch (post) {
      Ball() => PostsEntity.ball(
        id: post.id,
        innings_id: post.inningsId,
        match_id: post.matchId,
        innings_number: post.inningsNumber,
        day_number: null,
        session_number: null,
        over_index: post.index.over,
        ball_index: post.index.ball,
        timestamp: post.timestamp,
        runs_at: post.scoreAt.runs,
        wickets_at: post.scoreAt.wickets,
        type: 0,
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
        extras_penalties: 0,
        wicket_type: post.wicket == null
            ? null
            : _config.getWicketType(post.wicket!.dismissal.code),
        wicket_batter_id: post.wicket?.batterId,
        wicket_fielder_id: post.wicket is FielderWicket
            ? (post.wicket as FielderWicket).fielderId
            : null,
        innings_type: 0,
        //TODO
        non_striker_id: post.nonStrikerId,
      ),
      BowlerRetire() => PostsEntity.bowlerRetire(
        id: post.id,
        innings_id: post.inningsId,
        match_id: post.matchId,
        innings_number: post.inningsNumber,
        day_number: null,
        session_number: null,
        over_index: post.index.over,
        ball_index: post.index.ball,
        timestamp: post.timestamp,
        runs_at: post.scoreAt.runs,
        wickets_at: post.scoreAt.wickets,
        type: 1,
        comment: post.comment,
        bowler_id: post.bowlerId,
        non_striker_id: post.nonStrikerId,
        batter_id: post.batterId,
        innings_type: 0, // TODO
      ),
      NextBowler() => PostsEntity.nextBowler(
        id: post.id,
        innings_id: post.inningsId,
        match_id: post.matchId,
        innings_number: post.inningsNumber,
        day_number: null,
        session_number: null,
        over_index: post.index.over,
        ball_index: post.index.ball,
        timestamp: post.timestamp,
        runs_at: post.scoreAt.runs,
        wickets_at: post.scoreAt.wickets,
        type: 2,
        comment: post.comment,
        bowler_id: post.bowlerId,
        non_striker_id: post.nonStrikerId,
        batter_id: post.batterId,
        next_player_id: post.nextId,
        innings_type: 0, // TODO
      ),
      BatterRetire() => PostsEntity.batterRetire(
        id: post.id,
        innings_id: post.inningsId,
        match_id: post.matchId,
        innings_number: post.inningsNumber,
        day_number: null,
        session_number: null,
        over_index: post.index.over,
        ball_index: post.index.ball,
        timestamp: post.timestamp,
        runs_at: post.scoreAt.runs,
        wickets_at: post.scoreAt.wickets,
        type: 3,
        comment: post.comment,
        batter_id: post.retired.batterId,
        wicket_type: _config.getWicketType(post.retired.dismissal.code),
        wicket_batter_id: post.retired.batterId,
        non_striker_id: post.nonStrikerId,
        bowler_id: post.bowlerId,
        innings_type: 0, // TODO
      ),
      NextBatter() => PostsEntity.nextBatter(
        id: post.id,
        innings_id: post.inningsId,
        match_id: post.matchId,
        innings_number: post.inningsNumber,
        day_number: null,
        session_number: null,
        over_index: post.index.over,
        ball_index: post.index.ball,
        timestamp: post.timestamp,
        runs_at: post.scoreAt.runs,
        wickets_at: post.scoreAt.wickets,
        type: 4,
        comment: post.comment,
        batter_id: post.nextId,
        bowler_id: post.bowlerId,
        non_striker_id: post.nonStrikerId,
        next_player_id: post.nextId,
        wicket_batter_id: post.previousId,
        innings_type: 0, // TODO
      ),
      WicketBeforeDelivery() => PostsEntity.wicketBeforeDelivery(
        id: post.id,
        innings_id: post.inningsId,
        match_id: post.matchId,
        innings_number: post.inningsNumber,
        day_number: null,
        session_number: null,
        over_index: post.index.over,
        ball_index: post.index.ball,
        timestamp: post.timestamp,
        runs_at: post.scoreAt.runs,
        wickets_at: post.scoreAt.wickets,
        type: 5,
        comment: post.comment,
        wicket_type: _config.getWicketType(post.wicket.dismissal.code),
        wicket_batter_id: post.wicket.batterId,
        wicket_fielder_id: post is FielderWicket
            ? (post.wicket as FielderWicket).fielderId
            : null,
        batter_id: post.batterId,
        bowler_id: post.bowlerId,
        non_striker_id: post.nonStrikerId,
        innings_type: 0, // TODO
      ),
      Penalty() => PostsEntity.penalty(
        id: post.id,
        innings_id: post.inningsId,
        match_id: post.matchId,
        innings_number: post.inningsNumber,
        day_number: null,
        session_number: null,
        over_index: post.index.over,
        ball_index: post.index.ball,
        timestamp: post.timestamp,
        runs_at: post.scoreAt.runs,
        wickets_at: post.scoreAt.wickets,
        type: 6,
        comment: post.comment,
        extras_penalties: post.penalties,
        total_runs: post.penalties,
        batter_id: post.batterId,
        non_striker_id: post.nonStrikerId,
        bowler_id: post.bowlerId,
        innings_type: 0, // TODO
      ),
      Break() => throw UnimplementedError(),
    };
    return entity.serialize();
  }

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

  static InningsPost _unpackInningsPost(Map<String, Object?> map) {
    final entity = PostsEntity.deserialize(map);
    return switch (entity.type) {
      0 => Ball(
        entity.id,
        matchId: entity.match_id,
        inningsId: entity.innings_id,
        inningsNumber: entity.innings_number,
        timestamp: entity.timestamp,
        index: PostIndex(entity.over_index, entity.ball_index),
        scoreAt: Score(entity.runs_at, entity.wickets_at),
        comment: entity.comment,
        bowlerId: entity.bowler_id!,
        batterId: entity.batter_id!,
        batterRuns: entity.batter_runs!,
        isBoundary: entity.is_boundary!,
        wicket: _decipherWicket(
          entity.wicket_type,
          batterId: entity.wicket_batter_id,
          bowlerId: entity.bowler_id,
          fielderId: entity.wicket_fielder_id,
        ),
        bowlingExtra: _decipherBowlingExtra(
          entity.extras_no_balls ?? 0,
          entity.extras_wides ?? 0,
        ),
        battingExtra: _decipherBattingExtra(
          entity.extras_byes ?? 0,
          entity.extras_leg_byes ?? 0,
        ),
        nonStrikerId: entity.non_striker_id,
      ),
      1 => BowlerRetire(
        entity.id,
        matchId: entity.match_id,
        inningsId: entity.innings_id,
        inningsNumber: entity.innings_number,
        timestamp: entity.timestamp,
        index: PostIndex(entity.over_index, entity.ball_index),
        scoreAt: Score(entity.runs_at, entity.wickets_at),
        comment: entity.comment,
        bowlerId: entity.bowler_id!,
        nonStrikerId: entity.non_striker_id,
        batterId: entity.batter_id,
      ),
      2 => NextBowler(
        entity.id,
        matchId: entity.match_id,
        inningsId: entity.innings_id,
        inningsNumber: entity.innings_number,
        timestamp: entity.timestamp,
        index: PostIndex(entity.over_index, entity.ball_index),
        scoreAt: Score(entity.runs_at, entity.wickets_at),
        comment: entity.comment,
        nextId: entity.next_player_id!,
        bowlerId: entity.bowler_id,
        nonStrikerId: entity.non_striker_id,
        batterId: entity.batter_id,
      ),
      3 => BatterRetire(
        entity.id,
        matchId: entity.match_id,
        inningsId: entity.innings_id,
        inningsNumber: entity.innings_number,
        timestamp: entity.timestamp,
        index: PostIndex(entity.over_index, entity.ball_index),
        scoreAt: Score(entity.runs_at, entity.wickets_at),
        comment: entity.comment,
        retired:
            _decipherWicket(
                  entity.wicket_type,
                  batterId: entity.batter_id,
                  bowlerId: null,
                  fielderId: null,
                )
                as Retired,
        bowlerId: entity.bowler_id,
        nonStrikerId: entity.non_striker_id,
        batterId: entity.batter_id,
      ),
      4 => NextBatter(
        entity.id,
        matchId: entity.match_id,
        inningsId: entity.innings_id,
        inningsNumber: entity.innings_number,
        timestamp: entity.timestamp,
        index: PostIndex(entity.over_index, entity.ball_index),
        scoreAt: Score(entity.runs_at, entity.wickets_at),
        comment: entity.comment,
        nextId: entity.next_player_id!,
        previousId: entity.wicket_batter_id,
        bowlerId: entity.bowler_id,
        nonStrikerId: entity.non_striker_id,
        batterId: entity.batter_id,
      ),
      5 => WicketBeforeDelivery(
        entity.id,
        matchId: entity.match_id,
        inningsId: entity.innings_id,
        inningsNumber: entity.innings_number,
        timestamp: entity.timestamp,
        index: PostIndex(entity.over_index, entity.ball_index),
        scoreAt: Score(entity.runs_at, entity.wickets_at),
        comment: entity.comment,
        wicket: _decipherWicket(
          entity.wicket_type,
          batterId: entity.wicket_batter_id,
          fielderId: entity.wicket_fielder_id,
          bowlerId: null,
        )!,
        bowlerId: entity.bowler_id!,
        nonStrikerId: entity.non_striker_id,
        batterId: entity.batter_id,
      ),
      6 => Penalty(
        entity.id,
        matchId: entity.match_id,
        inningsId: entity.innings_id,
        inningsNumber: entity.innings_number,
        timestamp: entity.timestamp,
        index: PostIndex(entity.over_index, entity.ball_index),
        scoreAt: Score(entity.runs_at, entity.wickets_at),
        comment: entity.comment,
        penalties: entity.extras_penalties!,
        bowlerId: entity.bowler_id!,
        nonStrikerId: entity.non_striker_id,
        batterId: entity.batter_id,
      ),
      _ => throw UnsupportedError(
        "posts.type out of bounds! (id:${entity.id})",
      ),
    };
  }
}

class PostsEntity {
  // Common
  final int? id;
  final int match_id;
  final int innings_id;
  final int innings_type;
  final int innings_number;

  final int? day_number;
  final int? session_number;
  final DateTime timestamp;
  final int over_index;
  final int ball_index;
  final int runs_at;
  final int wickets_at;
  final int type;

  final int? bowler_id;
  final int? batter_id;
  final int? non_striker_id;

  final String? comment;

  // NextBatter/NextBowler
  final int? next_player_id;

  // Ball specific
  final int? total_runs;
  final int? bowler_runs;
  final int? batter_runs;
  final bool? is_boundary;

  final int? extras_no_balls;
  final int? extras_wides;
  final int? extras_byes;
  final int? extras_leg_byes;
  final int? extras_penalties;

  // Wicket
  final int? wicket_type;
  final int? wicket_batter_id;
  final int? wicket_fielder_id;

  PostsEntity._({
    required this.id,
    required this.match_id,
    required this.innings_id,
    required this.innings_type,
    required this.innings_number,
    required this.day_number,
    required this.session_number,
    required this.timestamp,
    required this.over_index,
    required this.ball_index,
    required this.runs_at,
    required this.wickets_at,
    required this.type,
    required this.comment,
    required this.bowler_id,
    required this.batter_id,
    required this.non_striker_id,
    required this.next_player_id,
    required this.total_runs,
    required this.bowler_runs,
    required this.batter_runs,
    required this.is_boundary,
    required this.extras_no_balls,
    required this.extras_wides,
    required this.extras_byes,
    required this.extras_leg_byes,
    required this.extras_penalties,
    required this.wicket_type,
    required this.wicket_batter_id,
    required this.wicket_fielder_id,
  });

  PostsEntity.ball({
    required this.id,
    required this.match_id,
    required this.innings_id,
    required this.innings_type,
    required this.innings_number,
    required this.day_number,
    required this.session_number,
    required this.timestamp,
    required this.over_index,
    required this.ball_index,
    required this.runs_at,
    required this.wickets_at,
    required this.type,
    required this.comment,
    // Specific
    required this.bowler_id,
    required this.batter_id,
    required this.non_striker_id,
    required this.total_runs,
    required this.bowler_runs,
    required this.batter_runs,
    required this.is_boundary,
    required this.extras_no_balls,
    required this.extras_wides,
    required this.extras_byes,
    required this.extras_leg_byes,
    required this.extras_penalties,
    required this.wicket_type,
    required this.wicket_batter_id,
    required this.wicket_fielder_id,
    // null
    this.next_player_id,
  });

  PostsEntity.bowlerRetire({
    required this.id,
    required this.match_id,
    required this.innings_id,
    required this.innings_type,
    required this.innings_number,
    required this.day_number,
    required this.session_number,
    required this.timestamp,
    required this.over_index,
    required this.ball_index,
    required this.runs_at,
    required this.wickets_at,
    required this.type,
    required this.comment,
    // Specific
    required this.bowler_id,
    required this.batter_id,
    required this.non_striker_id,
    // null
    this.batter_runs,
    this.bowler_runs,
    this.total_runs,
    this.is_boundary,
    this.wicket_type,
    this.wicket_batter_id,
    this.wicket_fielder_id,
    this.next_player_id,
    this.extras_no_balls,
    this.extras_wides,
    this.extras_byes,
    this.extras_leg_byes,
    this.extras_penalties,
  });

  PostsEntity.nextBowler({
    required this.id,
    required this.match_id,
    required this.innings_id,
    required this.innings_type,
    required this.innings_number,
    required this.day_number,
    required this.session_number,
    required this.timestamp,
    required this.over_index,
    required this.ball_index,
    required this.runs_at,
    required this.wickets_at,
    required this.type,
    required this.comment,
    // Specific
    required this.next_player_id,
    required this.bowler_id,
    required this.batter_id,
    required this.non_striker_id,
    // null
    this.batter_runs,
    this.bowler_runs,
    this.total_runs,
    this.is_boundary,
    this.extras_no_balls,
    this.extras_wides,
    this.extras_byes,
    this.extras_leg_byes,
    this.extras_penalties,
    this.wicket_type,
    this.wicket_batter_id,
    this.wicket_fielder_id,
  });

  PostsEntity.batterRetire({
    required this.id,
    required this.match_id,
    required this.innings_id,
    required this.innings_type,
    required this.innings_number,
    required this.day_number,
    required this.session_number,
    required this.timestamp,
    required this.over_index,
    required this.ball_index,
    required this.runs_at,
    required this.wickets_at,
    required this.type,
    required this.comment,
    // Specific
    required this.bowler_id,
    required this.batter_id,
    required this.non_striker_id,
    required this.wicket_type, // retire
    required this.wicket_batter_id,
    // null
    this.batter_runs,
    this.bowler_runs,
    this.total_runs,
    this.is_boundary,
    this.extras_no_balls,
    this.extras_wides,
    this.extras_byes,
    this.extras_leg_byes,
    this.extras_penalties,
    this.next_player_id,
    this.wicket_fielder_id,
  });

  PostsEntity.nextBatter({
    required this.id,
    required this.match_id,
    required this.innings_id,
    required this.innings_type,
    required this.innings_number,
    required this.day_number,
    required this.session_number,
    required this.timestamp,
    required this.over_index,
    required this.ball_index,
    required this.runs_at,
    required this.wickets_at,
    required this.type,
    required this.comment,
    // Specific
    required this.next_player_id,
    required this.wicket_batter_id, //previous
    required this.batter_id,
    required this.bowler_id,
    required this.non_striker_id,
    // null
    this.batter_runs,
    this.bowler_runs,
    this.total_runs,
    this.is_boundary,
    this.extras_no_balls,
    this.extras_wides,
    this.extras_byes,
    this.extras_leg_byes,
    this.extras_penalties,
    this.wicket_type,
    this.wicket_fielder_id,
  });

  PostsEntity.wicketBeforeDelivery({
    required this.id,
    required this.match_id,
    required this.innings_id,
    required this.innings_type,
    required this.innings_number,
    required this.day_number,
    required this.session_number,
    required this.timestamp,
    required this.over_index,
    required this.ball_index,
    required this.runs_at,
    required this.wickets_at,
    required this.type,
    required this.comment,
    // Specific
    required this.wicket_type, // wicket type
    required this.wicket_batter_id,
    required this.wicket_fielder_id,
    required this.batter_id, // next
    required this.bowler_id,
    required this.non_striker_id,
    // null
    this.batter_runs,
    this.bowler_runs,
    this.total_runs,
    this.is_boundary,
    this.extras_no_balls,
    this.extras_wides,
    this.extras_byes,
    this.extras_leg_byes,
    this.extras_penalties,
    this.next_player_id,
  });

  PostsEntity.penalty({
    required this.id,
    required this.match_id,
    required this.innings_id,
    required this.innings_type,
    required this.innings_number,
    required this.day_number,
    required this.session_number,
    required this.timestamp,
    required this.over_index,
    required this.ball_index,
    required this.runs_at,
    required this.wickets_at,
    required this.type,
    required this.comment,
    // Specific
    required this.extras_penalties,
    required this.total_runs,
    required this.batter_id, // next
    required this.bowler_id,
    required this.non_striker_id,
    // null
    this.next_player_id, // previous
    this.batter_runs,
    this.bowler_runs,
    this.is_boundary,
    this.extras_no_balls,
    this.extras_wides,
    this.extras_byes,
    this.extras_leg_byes,
    this.wicket_type,
    this.wicket_batter_id,
    this.wicket_fielder_id,
  });

  PostsEntity.deserialize(Map<String, Object?> map)
    : this._(
        id: map["id"] as int,
        match_id: map["match_id"] as int,
        innings_id: map["innings_id"] as int,
        innings_type: map["innings_type"] as int,
        innings_number: map["innings_number"] as int,
        day_number: map["day_number"] as int?,
        session_number: map["session_number"] as int?,
        timestamp: readDateTime(map["timestamp"] as int)!,
        over_index: map["over_index"] as int,
        ball_index: map["ball_index"] as int,
        runs_at: map["runs_at"] as int,
        wickets_at: map["wickets_at"] as int,
        type: map["type"] as int,
        bowler_id: map["bowler_id"] as int?,
        batter_id: map["batter_id"] as int?,
        non_striker_id: map["non_striker_id"] as int?,
        next_player_id: map["next_player_id"] as int?,
        batter_runs: map["batter_runs"] as int?,
        bowler_runs: map["bowler_runs"] as int?,
        total_runs: map["total_runs"] as int?,
        is_boundary: readBool(map["is_boundary"]),
        extras_no_balls: map["extras_no_balls"] as int?,
        extras_wides: map["extras_wides"] as int?,
        extras_byes: map["extras_byes"] as int?,
        extras_leg_byes: map["extras_leg_byes"] as int?,
        extras_penalties: map["extras_penalties"] as int?,
        wicket_type: map["wicket_type"] as int?,
        wicket_batter_id: map["wicket_batter_id"] as int?,
        wicket_fielder_id: map["wicket_fielder_id"] as int?,
        comment: map["comment"] as String?,
      );

  Map<String, Object?> serialize() => {
    "id": id,
    "match_id": match_id,
    "innings_id": innings_id,
    "innings_type": innings_type,
    "innings_number": innings_number,
    "day_number": day_number,
    "session_number": session_number,
    "over_index": over_index,
    "ball_index": ball_index,
    "timestamp": timestamp.microsecondsSinceEpoch,
    "type": type,
    "bowler_id": bowler_id,
    "batter_id": batter_id,
    "non_striker_id": non_striker_id,
    "next_player_id": next_player_id,
    "total_runs": total_runs,
    "batter_runs": batter_runs,
    "bowler_runs": bowler_runs,
    "is_boundary": parseBool(is_boundary),
    "extras_no_balls": extras_no_balls,
    "extras_wides": extras_wides,
    "extras_byes": extras_byes,
    "extras_leg_byes": extras_leg_byes,
    "extras_penalties": extras_penalties,
    "wicket_type": wicket_type,
    "wicket_batter_id": wicket_batter_id,
    "wicket_fielder_id": wicket_fielder_id,
    // "runs_at": runs_at,
    // "wickets_at": wickets_at,
    "comment": comment,
  };
}

bool? readBool(Object? object) {
  if (object == null) return null;
  return object as int != 0;
}

int? parseBool(bool? value) {
  if (value == null) return null;
  return value ? 1 : 0;
}

DateTime? readDateTime(int? micros) {
  if (micros == null) return null;
  return DateTime.fromMicrosecondsSinceEpoch(micros);
}
