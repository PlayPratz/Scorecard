import 'package:scorecard/modules/cricket_match/models/cricket_match_model.dart';
import 'package:scorecard/modules/cricket_match/models/cricket_match_rules_model.dart';
import 'package:scorecard/modules/cricket_match/models/innings_model.dart';
import 'package:scorecard/repositories/sql/db/game_rules_table.dart';
import 'package:scorecard/repositories/sql/db/innings_table.dart';
import 'package:scorecard/repositories/sql/db/lineups_table.dart';
import 'package:scorecard/repositories/sql/db/matches_expanded_view.dart';
import 'package:scorecard/repositories/sql/db/matches_table.dart';
import 'package:scorecard/repositories/sql/db/posts_table.dart';
import 'package:scorecard/repositories/sql/db/wickets_table.dart';
import 'package:scorecard/repositories/sql/entity_mappers.dart';

class CricketMatchRepository {
  final MatchesTable cricketMatchesTable;
  final MatchesExpandedView cricketMatchesExpandedView;
  final GameRulesTable gameRulesTable;
  final LineupsTable lineupsTable;
  final InningsTable inningsTable;
  final WicketsTable wicketsTable;
  final PostsTable postsTable;

  CricketMatchRepository(
      {required this.cricketMatchesTable,
      required this.cricketMatchesExpandedView,
      required this.gameRulesTable,
      required this.lineupsTable,
      required this.inningsTable,
      required this.wicketsTable,
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

  Future<void> scheduleCricketMatch(ScheduledCricketMatch match) async {
    // Create match entry in DB
    final entity = EntityMappers.repackMatch(match);

    // Insert the match
    await cricketMatchesTable.create(entity);
  }

  Future<void> initializeCricketGame(CricketGame game) async {
    // Update match entry in DB (stage = 2, toss)
    final entity = EntityMappers.repackMatch(game.match);

    // Update the match
    await cricketMatchesTable.update(entity);

    // Add lineups to DB
    final lineup1Entity =
        EntityMappers.lineup(game.match.team1, matchId: match.id);
    final lineup2Entity = EntityMappers.lineup(match.team1, matchId: match.id);
    await lineupsTable.create([...lineup1Entity, ...lineup2Entity]);
  }

  Future<void> commenceCricketGame(CricketGame game) async {
    // Update match entry in DB (stage = 3)
    final entity = EntityMappers.repackMatch(game.match);

    // Update the match
    cricketMatchesTable.update(entity);
  }

  Future<void> putLastInningsOfGame(CricketGame game) async {
    // Puts the last innings of the given game in the DB
    final innings = game.innings.last;
    final inningsEntity = EntityMappers.innings(innings,
        matchId: game.match.id, inningsNumber: innings.inningsNumber);

    // Insert the Innings
    inningsTable.create(inningsEntity);
  }

  Future<void> postToGame(
      CricketGame game, Innings innings, InningsPost post) async {
    final postEntity = EntityMappers.limitedOversPost(post,
        matchId: game.match.id, inningsNumber: game.innings.indexOf(innings));

    // Insert the Post
    postsTable.create(postEntity);
  }
}
