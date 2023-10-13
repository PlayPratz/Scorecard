import 'dart:collection';

import 'package:scorecard/models/team.dart';
import 'package:scorecard/repositories/generic_repository.dart';

/// Services all tasks related to [Team]s.
class TeamService {
  final IRepository<Team> _teamRepository;

  TeamService({required IRepository<Team> teamRepository})
      : _teamRepository = teamRepository;

  Future<void> initialize() async {}

  Future<UnmodifiableListView<Team>> getAllTeams() async {
    final teams = await _teamRepository.getAll();
    return UnmodifiableListView(teams);
  }

  Future<void> save(Team team) async {
    await _teamRepository.add(team);
  }
}
