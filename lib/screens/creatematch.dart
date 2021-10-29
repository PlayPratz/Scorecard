import 'package:flutter/material.dart';
import 'package:scorecard/models/team.dart';
import 'package:scorecard/screens/teamlist.dart';
import 'package:scorecard/screens/titledpage.dart';
import 'package:scorecard/screens/widgets/teamtile.dart';
import 'package:scorecard/styles/colorstyles.dart';
import 'package:scorecard/styles/strings.dart';
import 'package:scorecard/util/elements.dart';
import 'package:scorecard/util/utils.dart';

class CreateMatchForm extends StatefulWidget {
  const CreateMatchForm({Key? key}) : super(key: key);

  @override
  State<CreateMatchForm> createState() => _CreateMatchFormState();
}

class _CreateMatchFormState extends State<CreateMatchForm> {
  Team? _selectedHomeTeam;
  Team? _selectedAwayTeam;

  @override
  Widget build(BuildContext context) {
    return TitledPage(
        title: Strings.matchlistCreateNewMatch,
        child: Form(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: [
              _selectedHomeTeam != null
                  ? TeamTile(
                      team: _selectedHomeTeam!,
                      onSelect: (Team team) => _chooseHomeTeam(),
                    )
                  : _getSelectTeamWidget(
                      Strings.createMatchSelectHomeTeam,
                      Strings.createMatchHomeTeamHint,
                      ColorStyles.homeTeam,
                      _chooseHomeTeam),
              _selectedAwayTeam != null
                  ? TeamTile(
                      team: _selectedAwayTeam!,
                      onSelect: (Team team) => _chooseAwayTeam(),
                    )
                  : _getSelectTeamWidget(
                      Strings.createMatchSelectAwayTeam,
                      Strings.createMatchAwayTeamHint,
                      ColorStyles.awayTeam,
                      _chooseAwayTeam),
              const Spacer(),
              Elements.getConfirmButton(
                  text: Strings.createMatchStartMatch, onPressed: () {}),
            ],
          ),
        ));
  }

  Widget _getSelectTeamWidget(String primaryHint, String secondaryHint,
      Color iconColor, Function onTap) {
    return InkWell(
      onTap: () => onTap(),
      child: ListTile(
        title: Text(primaryHint),
        subtitle: Text(secondaryHint),
        leading: Icon(Icons.people, color: iconColor),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  void _chooseHomeTeam() {
    _chooseTeam((chosenTeam) {
      if (chosenTeam == _selectedAwayTeam) {
        _selectedAwayTeam = null;
      }
      _selectedHomeTeam = chosenTeam;
    });
  }

  void _chooseAwayTeam() {
    _chooseTeam((chosenTeam) {
      if (chosenTeam == _selectedHomeTeam) {
        _selectedHomeTeam = null;
      }
      _selectedAwayTeam = chosenTeam;
    });
  }

  void _chooseTeam(Function(Team) callInsideSetState) async {
    Team? chosenTeam = await Utils.goToPage(
      TitledPage(
        title: Strings.chooseTeam,
        child: TeamList(
          teamList: Utils.getAllTeams(),
          onSelect: (Team chosenTeam) => Utils.goBack(context, chosenTeam),
        ),
      ),
      context,
    );
    if (chosenTeam != null) {
      setState(() {
        callInsideSetState(chosenTeam);
      });
    }
  }
}
