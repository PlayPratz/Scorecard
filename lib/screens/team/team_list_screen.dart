import 'dart:async';

import 'package:flutter/material.dart';
import 'package:scorecard/modules/repository/service/repository_service.dart';
import 'package:scorecard/modules/team/models/team_model.dart';
import 'package:scorecard/repositories/generic_repository.dart';

class TeamListScreen extends StatelessWidget {
  final void Function(Team)? onSelect;
  const TeamListScreen({super.key, this.onSelect});

  @override
  Widget build(BuildContext context) {
    final controller = TeamListController();
    controller.fetchAll();
    return Scaffold(
      appBar: AppBar(),
      body: StreamBuilder(
        stream: controller.stream,
        builder: (context, snapshot) {
          final state = snapshot.data;
          switch (state) {
            case null:
            case TeamListLoadingState():
              return const CircularProgressIndicator();
            case TeamListLoadedState():
              return TeamList(state.teams, onSelect: onSelect);
          }
        },
      ),
      bottomNavigationBar: const BottomAppBar(),
    );
  }
}

class TeamList extends StatelessWidget {
  final Iterable<Team> teams;
  final void Function(Team)? onSelect;
  const TeamList(this.teams, {super.key, this.onSelect});

  @override
  Widget build(BuildContext context) {
    final teamList = teams.toList();
    return ListView.builder(
      itemBuilder: (context, index) {
        final team = teamList[index];
        return TeamTile(
          team,
          onSelect: onSelect != null ? () => onSelect!(team) : null,
        );
      },
      itemCount: teams.length,
    );
  }
}

class TeamTile extends StatelessWidget {
  final Team team;
  final void Function()? onSelect;
  const TeamTile(this.team, {super.key, this.onSelect});

  @override
  Widget build(BuildContext context) {
    final isSelectable = onSelect != null;
    final color = Color(team.color);
    // final brightness = ThemeData.estimateBrightnessForColor(color);
    return Card(
      color: color.withOpacity(0.9),
      child: ListTile(
        leading: const Icon(Icons.groups),
        title: Text(team.name),
        trailing: isSelectable ? const Icon(Icons.chevron_right) : null,
        onTap: onSelect,
      ),
    );
  }
}

class TeamListController {
  final _streamController = StreamController<TeamListState>();
  Stream<TeamListState> get stream => _streamController.stream;

  void fetchAll() {
    _streamController.add(TeamListLoadingState());
    _repository
        .readAll()
        .then((teams) => _streamController.add(TeamListLoadedState(teams)));
  }

  IRepository<Team> get _repository => RepositoryService().getTeamRepository();
}

sealed class TeamListState {}

class TeamListLoadingState extends TeamListState {}

class TeamListLoadedState extends TeamListState {
  final Iterable<Team> teams;
  TeamListLoadedState(this.teams);
}
