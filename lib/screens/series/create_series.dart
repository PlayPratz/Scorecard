import 'package:flutter/material.dart';
import 'package:scorecard/models/team.dart';
import 'package:scorecard/screens/team/team_list.dart';
import 'package:scorecard/screens/team/team_tile.dart';
import 'package:scorecard/screens/templates/titled_page.dart';
import 'package:scorecard/screens/widgets/generic_item_tile.dart';
import 'package:scorecard/screens/widgets/separated_widgets.dart';
import 'package:scorecard/util/elements.dart';
import 'package:scorecard/services/storage_service.dart';
import 'package:scorecard/util/utils.dart';

class CreateSeries extends StatefulWidget {
  const CreateSeries({super.key});

  @override
  State<CreateSeries> createState() => _CreateSeriesState();
}

class _CreateSeriesState extends State<CreateSeries> {
  final List<Team> _selectedTeams = [];

  @override
  Widget build(BuildContext context) {
    return TitledPage(
        title: "Create new series",
        child: Column(
          children: [
            Expanded(
              child: SeparatedWidgetPair(
                top: GenericItemTile(
                  leading: Elements.teamIcon,
                  primaryHint: "Add Team",
                  secondaryHint:
                      "Add teams to this series. There must be at least two teams.",
                  trailing: Elements.addIcon,
                  onSelect: _chooseTeam,
                ),
                bottom: Column(
                  children: _selectedTeams
                      .map((team) => TeamTile(team: team))
                      .toList(),
                ),
              ),
            ),
            Elements.getConfirmButton(text: "Create Series")
          ],
        ));
  }

  void _chooseTeam() async {
    Team? team = await _getTeamFromList();
    if (team != null) {
      setState(() {
        _selectedTeams.add(team);
      });
    }
  }

  Future<Team?> _getTeamFromList() async {
    return await Utils.goToPage(
        TitledPage(
          title: "Choose team",
          child: TeamList(
            teamList: StorageService.getAllTeams()
                .where((team) => !_selectedTeams.contains(team))
                .toList(),
            onSelectTeam: (team) => Utils.goBack(context, team),
          ),
        ),
        context);
  }

  bool get canCreateSeries => _selectedTeams.length >= 2;
}
