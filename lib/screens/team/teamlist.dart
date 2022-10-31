import 'package:flutter/material.dart';
import 'package:scorecard/screens/team/createteam.dart';
import 'package:scorecard/util/strings.dart';
import '../../models/team.dart';
import '../templates/itemlist.dart';
import 'teamtile.dart';

class TeamList extends StatelessWidget {
  final List<Team> teamList;
  final void Function(Team team)? onSelectTeam;
  final void Function(Team team)? onCreateTeam;

  const TeamList(
      {Key? key, required this.teamList, this.onSelectTeam, this.onCreateTeam})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ItemList(
      itemList: _getTeamList(),
      createItem: onCreateTeam != null
          ? CreateItemEntry<Team>(
              page: CreateTeamForm(),
              string: Strings.createTeamCreate,
              onCreateItem: onCreateTeam,
            )
          : null,
    );
  }

  List<Widget> _getTeamList() {
    List<TeamTile> teamTileList = [];
    for (Team team in teamList) {
      teamTileList.add(TeamTile(
        team: team,
        onSelect: onSelectTeam,
      ));
    }
    return teamTileList;
  }
}
