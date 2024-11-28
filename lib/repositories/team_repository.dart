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
  }

  Future<Iterable<Team>> fetchAll() async {
    final entities = teamsTable.readAll();
  }
}
