import 'package:scorecard/repositories/sql/db/game_rules_table.dart';
import 'package:scorecard/repositories/sql/db/matches_table.dart';
import 'package:scorecard/repositories/sql/db/sql_crud.dart';
import 'package:scorecard/repositories/sql/db/teams_table.dart';
import 'package:scorecard/repositories/sql/db/venues_table.dart';
import 'package:scorecard/repositories/sql/keys.dart';

class MatchesExpandedEntity implements IEntity {
  final MatchesEntity matchesEntity;
  final TeamsEntity team1Entity;
  final TeamsEntity team2Entity;
  final VenueEntity venueEntity;
  final GameRulesEntity gameRulesEntity;

  MatchesExpandedEntity._({
    required this.matchesEntity,
    required this.team1Entity,
    required this.team2Entity,
    required this.venueEntity,
    required this.gameRulesEntity,
  });

  factory MatchesExpandedEntity.deserialize(Map<String, Object?> map) {
    final Map<String, Object?> team1 = {};
    final Map<String, Object?> team2 = {};
    final Map<String, Object?> venue = {};
    final Map<String, Object?> gameRules = {};

    for (final entry in map.entries) {
      team1[entry.key.replaceFirst("team1_", "")] = entry.value;
      team2[entry.key.replaceFirst("team2_", "")] = entry.value;
      venue[entry.key.replaceFirst("venue_", "")] = entry.value;
      gameRules[entry.key.replaceFirst("rules_", "")] = entry.value;
    }

    return MatchesExpandedEntity._(
      matchesEntity: MatchesEntity.deserialize(map),
      team1Entity: TeamsEntity.deserialize(team1),
      team2Entity: TeamsEntity.deserialize(team2),
      venueEntity: VenueEntity.deserialize(venue),
      gameRulesEntity: GameRulesEntity.deserialize(gameRules),
    );
  }

  @override
  Map<String, Object?> serialize() =>
      throw UnimplementedError("Attempted to serialize MatchesExpandedEntity");

  @override
  List get primary_key => [matchesEntity.primary_key];
  String get id => matchesEntity.id;
}

// {
//   "id": "m1",
//   "stage": 3,
//   "starts_at": "29/06/2024",
//   "toss_winner_id": "t3",
//   "toss_choice": 1,
//   "result_type": null,
//   "result_winner_id": null,
//   "result_loser_id": null,
//   "result_margin_1": null,
//   "result_margin_2": null,
//   "potm_id": null,
//   "venue_id:1": "v1",
//   "venue_name": "default",
//   "rules_type": 1,
//   "rules_balls_per_over": 6,
//   "rules_no_ball_penalty": 1,
//   "rules_wide_penalty": 1,
//   "rules_only_single_batter": 0,
//   "rules_allow_last_man": 0,
//   "rules_days_of_play": null,
//   "rules_session_per_day": null,
//   "rules_innings_per_side": null,
//   "rules_overs_per_innings": 5,
//   "rules_overs_per_bowler": 2,
//   "team1_id": "t1",
//   "team1_name": "Mumbai Indians",
//   "team1_short": "MI",
//   "team1_color": null,
//   "team2_id": "t3",
//   "team2_name": "Royal Challengers Bengaluru",
//   "team2_short": "RCB",
//   "team2_color": null
// };

class MatchesExpandedView extends ICrud<MatchesExpandedEntity> {
  @override
  Future<int> create(MatchesExpandedEntity object) {
    throw UnsupportedError("Cannot insert into a View (id: ${object.id})");
  }

  @override
  Future<void> update(MatchesExpandedEntity object) {
    throw UnsupportedError("Cannot update a View (id: ${object.id})");
  }

  @override
  String get table => Views.matchesExpanded;

  @override
  MatchesExpandedEntity deserialize(Map<String, Object?> map) =>
      MatchesExpandedEntity.deserialize(map);
}
