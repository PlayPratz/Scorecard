import 'package:flutter/material.dart';
import 'package:scorecard/models/team.dart';
import 'package:scorecard/screens/createteam.dart';
import 'package:scorecard/screens/widgets/itemlist.dart';
import 'package:scorecard/screens/widgets/teamtile.dart';

class TeamList extends StatelessWidget {
  final List<Team> teamList;
  final Function(Team)? onSelect;

  const TeamList({Key? key, required this.teamList, this.onSelect})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ItemList(
      itemList: getTeamList(),
      createItemPage: const CreateTeamForm(),
      createItemString: "Create new team",
    );
  }

  List<Widget> getTeamList() {
    List<TeamTile> teamTileList = [];
    for (Team team in teamList) {
      teamTileList.add(TeamTile(
        team: team,
        onSelect: onSelect,
      ));
    }
    return teamTileList;
  }
}
