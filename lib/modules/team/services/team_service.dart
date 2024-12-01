import 'package:scorecard/handlers/ulid.dart';
import 'package:scorecard/modules/team/models/team_model.dart';
import 'package:scorecard/repositories/provider/repository_provider.dart';
import 'package:scorecard/repositories/team_repository.dart';

class TeamService {
  Future<void> saveTeam(
      {required String name,
      required String short,
      required int color,
      String? id}) async {
    final update = id != null;
    id ??= UlidHandler.generate();
    final team = Team(id: id, short: short, name: name, color: color);
    _repository.save(team, update: update);
  }

  Future<Iterable<Team>> getAllTeams() async {
    final teams = await _repository.loadAll();
    return teams;
  }

  TeamRepository get _repository => RepositoryProvider().getTeamRepository();
}
