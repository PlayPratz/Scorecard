import 'package:flutter/material.dart';
import 'package:scorecard/models/team.dart';
import 'package:scorecard/screens/widgets/itemlist.dart';
import 'package:scorecard/screens/widgets/teamtile.dart';

class TeamList extends StatelessWidget {
  final List<Team> teamList;
  final Function(Team)? onSelectTeam;

  const TeamList({Key? key, required this.teamList, this.onSelectTeam})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ItemList(
      itemList: _getTeamList(),
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
