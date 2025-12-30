import 'dart:collection';

import 'package:scorecard/modules/quick_match/post_ball_and_extras_model.dart';
import 'package:scorecard/modules/quick_match/quick_match_model.dart';
import 'package:scorecard/repositories/sql/db/batting_scores_table.dart';
import 'package:scorecard/repositories/sql/db/bowling_scores_table.dart';
import 'package:scorecard/repositories/sql/db/posts_table.dart';
import 'package:scorecard/repositories/sql/db/quick_innings_table.dart';
import 'package:scorecard/repositories/sql/db/quick_matches_table.dart';
import 'package:scorecard/repositories/sql/db/sql_interface.dart';
import 'package:scorecard/repositories/sql/entity_mappers.dart';
import 'package:scorecard/repositories/sql/keys.dart';

class QuickMatchRepository {
  final QuickMatchesTable quickMatchesTable;
  final QuickInningsTable quickInningsTable;
  final PostsTable postsTable;
  final BattingScoresTable battingScoresTable;
  final BowlingScoresTable bowlingScoresTable;

  final WicketsView wicketsView;

  QuickMatchRepository(
    this.quickMatchesTable,
    this.quickInningsTable,
    this.postsTable,
    this.battingScoresTable,
    this.bowlingScoresTable,
    this.wicketsView,
  );

  Future<UnmodifiableListView<QuickMatch>> loadAllMatches() async {
    final matchEntities = await quickMatchesTable.selectAll();
    final matches = matchEntities.map((m) => EntityMappers.unpackQuickMatch(m));

    return UnmodifiableListView(matches);
  }

  Future<QuickMatch> createMatch(QuickMatch match) async {
    final matchEntity = EntityMappers.repackQuickMatch(match);
    final id = await quickMatchesTable.insert(matchEntity);
    final newEntity = await quickMatchesTable.select(id);
    if (newEntity == null) {
      throw StateError("Unable to insert match into the database! (id: $id");
    }

    final newMatch = EntityMappers.unpackQuickMatch(newEntity);
    return newMatch;
  }

  Future<void> saveMatch(QuickMatch match) async {
    final matchEntity = EntityMappers.repackQuickMatch(match);
    await quickMatchesTable.update(matchEntity);
  }

  Future<QuickInnings> createInnings(QuickInnings innings) async {
    final entity = EntityMappers.repackQuickInnings(innings);
    final id = await quickInningsTable.insert(entity);

    final newEntity = await quickInningsTable.select(id);
    if (newEntity == null) {
      throw StateError("Unable to insert innings into the database! (id: $id");
    }

    final newInnings = EntityMappers.unpackQuickInnings(newEntity);
    return newInnings;
  }

  Future<void> saveInnings(QuickInnings innings) async {
    final inningsEntity = EntityMappers.repackQuickInnings(innings);
    await quickInningsTable.update(inningsEntity);
  }

  Future<InningsPost> createPost(InningsPost post) async {
    final entity = EntityMappers.repackInningsPost(post);
    final id = await postsTable.insert(entity);

    final newEntity = await postsTable.select(id);
    if (newEntity == null) {
      throw StateError("Unable to insert post into the database! (id: $id");
    }

    final newPost = EntityMappers.unpackInningsPost(newEntity);
    return newPost;
  }

  Future<void> deletePost(int id) async {
    await postsTable.delete(id);
  }

  Future<QuickInnings?> loadLastInningsOf(QuickMatch match) async {
    final entities = await quickInningsTable.selectLastForMatch(match.id);
    if (entities.isEmpty) return null;
    final innings = EntityMappers.unpackQuickInnings(entities.single);
    return innings;
  }

  Future<UnmodifiableListView<QuickInnings>> loadAllInningsOf(
      QuickMatch match) async {
    final entities = await quickInningsTable.selectAllForMatch(match.id);
    final allInnings = entities
        .map(EntityMappers.unpackQuickInnings)
        .toList(); // For some reason, objects are not updated in an Iterable
    return UnmodifiableListView(allInnings);
  }

  Future<UnmodifiableListView<InningsPost>> loadAllPostsOf(
      QuickInnings innings) async {
    final entities = await postsTable.selectForInnings(innings.id);
    final posts = entities.map(EntityMappers.unpackInningsPost);

    return UnmodifiableListView(posts);
  }

  Future<UnmodifiableListView<BattingScore>> loadBattersOf(
      QuickInnings innings) async {
    final entities = await battingScoresTable.selectForInnings(innings.id);
    final battingScores = entities.map(EntityMappers.unpackBattingScore);

    return UnmodifiableListView(battingScores);
  }

  Future<BattingScore?> loadLastBattingScoreOf(
      QuickInnings innings, int batterId) async {
    final entity = await battingScoresTable.selectLastForInningsAndBatter(
        innings.id, batterId);

    if (entity.isEmpty) {
      return null;
    }

    final battingScore = EntityMappers.unpackBattingScore(entity.single);
    return battingScore;
  }

  Future<UnmodifiableListView<BowlingScore>> loadBowlersOf(
      QuickInnings innings) async {
    final entities = await bowlingScoresTable.selectForInnings(innings.id);
    final bowlingScores =
        entities.map((e) => EntityMappers.unpackBowlingScore(e));

    return UnmodifiableListView(bowlingScores);
  }

  Future<BowlingScore?> loadBowlingScoreOf(
      QuickInnings innings, int batterId) async {
    final entity = await bowlingScoresTable.selectForInningsAndBowler(
        innings.id, batterId);
    final bowlingScore = EntityMappers.unpackBowlingScore(entity);
    return bowlingScore;
  }

  Future<UnmodifiableListView<FallOfWicket>> loadWicketsOf(
      QuickInnings innings) async {
    final entities = await wicketsView.selectForInnings(innings.id);
    final fallOfWickets = entities.map(EntityMappers.unpackFallOfWicket);
    return UnmodifiableListView(fallOfWickets);
  }

  // SQLDBHandler get _sql => SQLDBHandler.instance;
}

class WicketsEntity implements IEntity {
  final int id;
  final int match_id;
  final int innings_id;
  final int innings_type;
  final int innings_number;
  final int? day_number;
  final int? session_number;
  final DateTime timestamp;
  final int over_index;
  final int ball_index;
  final int wicket_type;
  final int batter_id;
  final int? bowler_id;
  final int? fielder_id;
  final int runs_at;
  final int wickets_at;

  WicketsEntity({
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
    required this.wicket_type,
    required this.batter_id,
    required this.bowler_id,
    required this.fielder_id,
    required this.runs_at,
    required this.wickets_at,
  });

  WicketsEntity.deserialize(Map<String, Object?> map)
      : this(
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
          wicket_type: map["wicket_type"] as int,
          batter_id: map["batter_id"] as int,
          bowler_id: map["bowler_id"] as int?,
          fielder_id: map["fielder_id"] as int?,
          runs_at: map["runs_at"] as int,
          wickets_at: map["wickets_at"] as int,
        );

  @override
  Map<String, Object?> serialize() {
    throw UnimplementedError();
  }
}

class WicketsView extends ISQL<WicketsEntity> {
  @override
  WicketsEntity deserialize(Map<String, Object?> map) =>
      WicketsEntity.deserialize(map);

  @override
  String get table => Views.wickets;

  Future<Iterable<WicketsEntity>> selectForInnings(int id) async {
    final result = await sql.query(
      table: table,
      where: "innings_id = ?",
      whereArgs: [id],
    );
    final entities = result.map((e) => WicketsEntity.deserialize(e));
    return entities;
  }
}
