import 'package:scorecard/modules/team/models/team_model.dart';
import 'package:scorecard/repositories/sql/db/teams_table.dart';
import 'package:scorecard/repositories/sql/entity_mappers.dart';

class TeamRepository {
  TeamsTable teamsTable;

  TeamRepository({required this.teamsTable});

  Future<void> save(Team team, {bool update = true}) async {
    final entity = EntityMappers.repackTeam(team);
    if (update) {
      await teamsTable.update(entity);
    } else {
      await teamsTable.create(entity);
    }
  }

  Future<Team> fetchById(String id) async {
    final entity = await teamsTable.read(id);
    if (entity == null) {
      throw StateError("Team not found in DB! (id: $id)");
    }
    final team = EntityMappers.unpackTeam(entity);
    return team;
  }

  Future<Iterable<Team>> loadAll() async {
    final entities = await teamsTable.readAll();
    final teams = entities.map((e) => EntityMappers.unpackTeam(e));
    return teams;
  }
}
