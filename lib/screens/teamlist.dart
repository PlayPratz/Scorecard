import 'package:flutter/material.dart';
import 'package:scorecard/screens/createteam.dart';
import 'package:scorecard/styles/strings.dart';
import 'package:scorecard/util/utils.dart';
import '../models/team.dart';
import 'widgets/itemlist.dart';
import 'widgets/teamtile.dart';

class TeamList extends StatelessWidget {
  final List<Team> teamList;
  final Function(Team team)? onSelectTeam;
  final bool allowCreateTeam;

  const TeamList(
      {Key? key,
      required this.teamList,
      this.onSelectTeam,
      this.allowCreateTeam = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ItemList(
      itemList: _getTeamList(),
      createItem: allowCreateTeam
          ? CreateItemEntry(
              page: CreateTeamForm(),
              string: Strings.createTeamCreate,
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
