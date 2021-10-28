import 'package:flutter/material.dart';
import 'package:scorecard/models/team.dart';
import 'package:scorecard/screens/createteam.dart';
import 'package:scorecard/screens/widgets/itemlist.dart';
import 'package:scorecard/screens/widgets/teamtile.dart';

class TeamList extends StatelessWidget {
  final List<Team> teamList = [
    Team("Mumbai Indians", "MI", []),
    Team("Chennai Super Kings", "CSK", [])
  ];

  TeamList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ItemList(
      itemList: getTeamList(),
      createItemPage: CreateTeamForm(),
      createItemString: "Create new team",
    );
  }

  List<Widget> getTeamList() {
    List<TeamTile> teamTileList = [];
    for (Team team in teamList) {
      teamTileList.add(TeamTile(team: team));
    }
    return teamTileList;
  }
}
