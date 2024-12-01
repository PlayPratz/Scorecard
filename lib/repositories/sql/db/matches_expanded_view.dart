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
