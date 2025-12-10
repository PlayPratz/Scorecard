import 'dart:collection';

import 'package:scorecard/handlers/sql_db_handler.dart';
import 'package:scorecard/handlers/ulid_handler.dart';
import 'package:scorecard/modules/quick_match/post_ball_and_extras_model.dart';
import 'package:scorecard/modules/quick_match/quick_match_model.dart';
import 'package:scorecard/repositories/sql/db/batting_scores_table.dart';
import 'package:scorecard/repositories/sql/db/bowling_scores_table.dart';
import 'package:scorecard/repositories/sql/db/posts_table.dart';
import 'package:scorecard/repositories/sql/db/quick_innings_table.dart';
import 'package:scorecard/repositories/sql/db/quick_matches_table.dart';
import 'package:scorecard/repositories/sql/entity_mappers.dart';

class QuickMatchRepository {
  final QuickMatchesTable quickMatchesTable;
  final QuickInningsTable quickInningsTable;
  final PostsTable postsTable;
  final BattingScoresTable battingScoresTable;
  final BowlingScoresTable bowlingScoresTable;

  QuickMatchRepository(
    this.quickMatchesTable,
    this.quickInningsTable,
    this.postsTable,
    this.battingScoresTable,
    this.bowlingScoresTable,
  );

  Future<List<QuickMatch>> getAllMatches() async {
    final matchEntities = await quickMatchesTable.selectAll();
    final matches = matchEntities.map((m) => EntityMappers.unpackQuickMatch(m));

    return matches.toList(growable: false);
  }

  Future<QuickMatch> createMatch(QuickMatchRules rules) async {
    final match = QuickMatch(
      handle: UlidHandler.generate(),
      startsAt: DateTime.timestamp(),
      rules: rules,
    );

    final matchEntity = EntityMappers.repackQuickMatch(match);
    final id = await quickMatchesTable.insert(matchEntity);
    return match;
  }

  Future<void> saveMatch(QuickMatch match) async {
    final matchEntity = EntityMappers.repackQuickMatch(match);
    await quickMatchesTable.update(matchEntity);
  }

  Future<void> createInnings(QuickInnings innings) async {
    final inningsEntity = EntityMappers.repackQuickInnings(innings);
    final id = await quickInningsTable.insert(inningsEntity);
    innings.id = id;
  }

  Future<void> saveInnings(QuickInnings innings) async {
    final inningsEntity = EntityMappers.repackQuickInnings(innings);
    await quickInningsTable.update(inningsEntity);
  }

  Future<InningsPost> createPost(InningsPost post) async {
    final postEntity = EntityMappers.repackInningsPost(post);
    final id = await postsTable.insert(postEntity);
    post.id = id;
    return post;
  }

  Future<void> deletePost(int id) async {
    await postsTable.deleteById(id);
  }

  Future<QuickInnings?> loadLastInnings(QuickMatch match) async {
    final entities = await quickInningsTable.selectLastForMatch(match.id);

    if (entities.isEmpty) return null;

    final innings =
        EntityMappers.unpackQuickInnings(entities.single, match.rules);

    return innings;
  }

  Future<List<QuickInnings>> loadAllInnings(QuickMatch match) async {
    final entities = await quickInningsTable.selectAllForMatch(match.id);
    final allInnings = entities
        .map((i) => EntityMappers.unpackQuickInnings(i, match.rules))
        .toList(); // For some reason, objects are not updated in an Iterable

    return allInnings;
  }

  Future<UnmodifiableListView<InningsPost>> loadAllPostsForInnings(
      QuickInnings innings) async {
    if (innings.id == null) {
      throw StateError("Attempted to load posts for innings without ID");
    }

    final entities = await postsTable.selectForInnings(innings.id!);
    final posts = entities.map((p) => EntityMappers.unpackInningsPost(p));

    return UnmodifiableListView(posts);
  }

  Future<UnmodifiableListView<BattingScore>> loadBattersForInnings(
      QuickInnings innings) async {
    if (innings.id == null) {
      throw StateError("Attempted to load posts for innings without ID");
    }

    final entities = await battingScoresTable.selectForInnings(innings.id!);
    final battingScores =
        entities.map((e) => EntityMappers.unpackBattingScore(e));

    return UnmodifiableListView(battingScores);
  }

  SQLDBHandler get _sql => SQLDBHandler.instance;
}
