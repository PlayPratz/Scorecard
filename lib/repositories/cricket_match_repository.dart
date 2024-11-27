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
    final entity = EntityMappers.gameRules(rules);
    if (rules.id == null) {
      // Insert
      await gameRulesTable.create(entity);
    } else {
      // Update
      await gameRulesTable.update(entity);
    }
  }

  Future<void> scheduleCricketMatch(ScheduledCricketMatch match) async {
    final entity = EntityMappers.match(match);
    await cricketMatchesTable.create(entity);
  }

  Future<void> initializeCricketMatch(InitializedCricketMatch match) async {
    final entity = EntityMappers.match(match);
    await cricketMatchesTable.update(entity);

    final lineup1Entity = EntityMappers.lineup(match.team1, matchId: match.id);
    final lineup2Entity = EntityMappers.lineup(match.team1, matchId: match.id);
    await lineupsTable.create([...lineup1Entity, ...lineup2Entity]);
  }

  Future<void> commenceCricketMatch(OngoingCricketMatch match) async {
    final inningsEntity = EntityMappers.innings(match.game.innings.first,
        matchId: match.id, inningsNumber: 1);
    inningsTable.create(inningsEntity);

    // Update the stage of the cricket match
    final entity = EntityMappers.match(match);
    cricketMatchesTable.update(entity);
  }

  Future<void> postToMatch(
      OngoingCricketMatch match, Innings innings, InningsPost post) async {
    final postEntity = EntityMappers.limitedOversPost(post,
        matchId: match.id, inningsNumber: match.game.innings.indexOf(innings));
    postsTable.create(postEntity);
  }
}
