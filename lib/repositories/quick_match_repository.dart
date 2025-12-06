import 'package:scorecard/handlers/ulid_handler.dart';
import 'package:scorecard/modules/quick_match/post_ball_and_extras_model.dart';
import 'package:scorecard/modules/quick_match/quick_match_model.dart';
import 'package:scorecard/repositories/sql/db/posts_table.dart';
import 'package:scorecard/repositories/sql/db/quick_innings_table.dart';
import 'package:scorecard/repositories/sql/db/quick_matches_table.dart';
import 'package:scorecard/repositories/sql/entity_mappers.dart';

class QuickMatchRepository {
  final QuickMatchesTable quickMatchesTable;
  final QuickInningsTable quickInningsTable;
  final PostsTable postsTable;

  QuickMatchRepository(
      this.quickMatchesTable, this.quickInningsTable, this.postsTable);

  Future<List<QuickMatch>> getAllMatches() async {
    final matchEntities = await quickMatchesTable.selectAll();
    final matches = matchEntities.map((m) => EntityMappers.unpackQuickMatch(m));

    return matches.toList(growable: false);
  }

  Future<QuickMatch> createMatch(QuickMatchRules rules) async {
    final match = QuickMatch(
      UlidHandler.generate(),
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
    final inningsEntity = await quickInningsTable.selectLastForMatch(match.id);

    if (inningsEntity.isEmpty) return null;

    final innings =
        EntityMappers.unpackQuickInnings(inningsEntity.single, match.rules);

    final postEntities = await postsTable.selectForInnings(innings.id!);
    final posts = postEntities.map((p) => EntityMappers.unpackInningsPost(p));
    innings.posts.addAll(posts);

    return innings;
  }

  Future<List<QuickInnings>> loadAllInnings(QuickMatch match) async {
    final inningsEntities = await quickInningsTable.selectAllForMatch(match.id);
    final allInnings = inningsEntities
        .map((i) => EntityMappers.unpackQuickInnings(i, match.rules))
        .toList(); // For some reason, objects are not updated in an Iterable

    final postEntities = await postsTable.selectForMatch(match.id);
    final posts = postEntities.map((p) => EntityMappers.unpackInningsPost(p));
    final postMap = <int, List<InningsPost>>{};

    for (final p in posts) {
      postMap.putIfAbsent(p.inningsId, () => []);
      postMap[p.inningsId]!.add(p);
    }

    for (final i in allInnings) {
      if (postMap[i.id] != null) i.posts.addAll(postMap[i.id!]!);
    }

    return allInnings;
  }
}
