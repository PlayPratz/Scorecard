import 'package:scorecard/modules/cricket_match/models/cricket_match_model.dart';
import 'package:scorecard/modules/cricket_match/models/cricket_match_rules_model.dart';
import 'package:scorecard/modules/cricket_match/models/innings_model.dart';
import 'package:scorecard/modules/player/player_model.dart';
import 'package:scorecard/repositories/sql/db/game_rules_table.dart';
import 'package:scorecard/repositories/sql/db/innings_table.dart';
import 'package:scorecard/repositories/sql/db/lineups_expanded_view.dart';
import 'package:scorecard/repositories/sql/db/players_in_match_table.dart';
import 'package:scorecard/repositories/sql/db/matches_expanded_view.dart';
import 'package:scorecard/repositories/sql/db/matches_table.dart';
import 'package:scorecard/repositories/sql/db/posts_table.dart';
import 'package:scorecard/repositories/sql/entity_mappers.dart';

class CricketMatchRepository {
  final MatchesTable cricketMatchesTable;
  final MatchesExpandedView cricketMatchesExpandedView;
  final GameRulesTable gameRulesTable;
  final PlayersInMatchTable playersInMatchTable;
  final LineupsExpandedView lineupsExpandedView;
  final InningsTable inningsTable;
  final PostsTable postsTable;

  CricketMatchRepository(
      {required this.cricketMatchesTable,
      required this.cricketMatchesExpandedView,
      required this.gameRulesTable,
      required this.playersInMatchTable,
      required this.lineupsExpandedView,
      required this.inningsTable,
      required this.postsTable});

  Future<void> saveGameRules(GameRules rules) async {
    final entity = EntityMappers.repackGameRules(rules);
    if (rules.id == null) {
      // Insert the GameRules
      await gameRulesTable.create(entity);
    } else {
      // Update the GameRules
      await gameRulesTable.update(entity);
    }
  }

  /// This will update the cricket match's details in the repository
  Future<void> saveCricketMatch(CricketMatch match,
      {required bool update}) async {
    // Update match entry in DB
    final entity = EntityMappers.repackMatch(match);
    if (update) {
      // Update
      await cricketMatchesTable.update(entity);
    } else {
      // Insert
      await cricketMatchesTable.create(entity);
    }
  }

  Future<void> saveLineupsOfGame(CricketGame game,
      {required bool update}) async {
    final id = game.matchId;
    // Add lineups to DB

    final batters = <Player, BatterInnings>{};
    final bowlers = <Player, BowlerInnings>{};

    for (final innings in game.innings) {
      batters.addAll(innings.batters);
      bowlers.addAll(innings.bowlers);
    }

    final lineup1Entities = EntityMappers.repackLineup(
      game.lineup1,
      matchId: id,
      teamId: game.team1.id,
      opponentTeamId: game.team2.id,
      isMatchCompleted: false, //TODO
      batters: batters,
      bowlers: bowlers,
    );
    final lineup2Entities = EntityMappers.repackLineup(
      game.lineup1,
      matchId: id,
      teamId: game.team2.id,
      opponentTeamId: game.team1.id,
      isMatchCompleted: false, //TODO
      batters: batters,
      bowlers: bowlers,
    );

    if (update) {
      // TODO Optimize
      [...lineup1Entities, ...lineup2Entities]
          .map((e) async => await playersInMatchTable.update(e));
    } else {
      [...lineup1Entities, ...lineup2Entities]
          .map((e) async => await playersInMatchTable.create(e));
    }
  }

  Future<void> storeLastInningsOfGame(CricketGame game) async {
    final id = game.matchId;
    // Put the last innings of the given game in the DB
    final innings = game.innings.last;
    final inningsEntity = EntityMappers.repackInnings(innings, matchId: id);

    // Insert the Innings
    inningsTable.create(inningsEntity);
  }

  Future<void> postToGame(
      CricketGame game, Innings innings, InningsPost post) async {
    final id = game.matchId;
    final postEntity = EntityMappers.repackLimitedOversPost(post,
        matchId: id, inningsNumber: game.innings.indexOf(innings));

    // Insert the Post
    postsTable.create(postEntity);
  }

  Future<CricketGame> loadCricketGameForMatch(
      InitializedCricketMatch cricketMatch) async {
    final id = cricketMatch.id;

    final lineupsExpandedEntities =
        await lineupsExpandedView.readWhere(matchId: cricketMatch.id);
    final lineups = EntityMappers.unpackLineups(lineupsExpandedEntities,
        matchId: id,
        team1Id: cricketMatch.team1.id,
        team2Id: cricketMatch.team2.id);

    final lineup1 = lineups.first;
    final lineup2 = lineups.last;

    final game =
        CricketGame.auto(cricketMatch, lineup1: lineup1, lineup2: lineup2);

    return game;
  }

  Future<Iterable<Innings>> loadAllInningsOfGame(CricketGame game) async {
    final id = game.matchId;
    final inningsEntities = await inningsTable.readWhere(matchId: id);

    final teamMap = {
      game.team1.id: game.team1,
      game.team2.id: game.team2,
    };

    final lineupMap = {
      game.team1: game.lineup1,
      game.team2: game.lineup2,
    };

    final allInnings =
        inningsEntities.map((entity) => EntityMappers.unpackInnings(
              entity,
              teamMap: teamMap,
              lineupMap: lineupMap,
              rules: game.rules,
            ));
    return allInnings;
  }

  /// Returns all posts mapped the their respective [inningsNumber]s.
  Future<Map<int, Iterable<InningsPost>>> loadAllPostsOfGame(
      CricketGame game) async {
    final id = game.matchId;

    final playerMap = <String, Player>{
      for (final player in game.lineup1.players) player.id: player,
      for (final player in game.lineup2.players) player.id: player
    };
    final postEntities = await postsTable.readWhere(matchId: id);
    final postMap = <int, List<InningsPost>>{};

    for (final entity in postEntities) {
      final post =
          EntityMappers.unpackLimitedOversPost(entity, playerMap: playerMap);
      if (postMap.containsKey(entity.innings_number)) {
        postMap[entity.innings_number]!.add(post);
      } else {
        postMap[entity.innings_number] = [post];
      }
    }

    return postMap;
  }
}
