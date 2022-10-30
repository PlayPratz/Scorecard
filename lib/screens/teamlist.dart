import 'package:flutter/material.dart';
import 'package:scorecard/screens/createteam.dart';
import '../models/team.dart';
import 'widgets/itemlist.dart';
import 'widgets/teamtile.dart';

class TeamList extends StatelessWidget {
  final List<Team> teamList;
  final Function(Team)? onSelectTeam;

  const TeamList({Key? key, required this.teamList, this.onSelectTeam})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ItemList(
      itemList: _getTeamList(),
      createItem:
          CreateItemEntry(page: CreateTeamForm(), string: "Create Team"),
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
