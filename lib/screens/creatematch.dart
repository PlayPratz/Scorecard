import 'package:flutter/material.dart';
import 'package:scorecard/models/cricketmatch.dart';
import 'package:scorecard/models/team.dart';
import 'package:scorecard/screens/createteam.dart';
import 'package:scorecard/screens/matchscreen.dart';
import 'package:scorecard/screens/titledpage.dart';
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
                  ? _getSelectTeamWidget(
                      _selectedHomeTeam!.name,
                      _selectedHomeTeam!.shortName,
                      ColorStyles.homeTeam,
                      _chooseHomeTeam)
                  : _getSelectTeamWidget(
                      Strings.createMatchSelectHomeTeam,
                      Strings.createMatchHomeTeamHint,
                      ColorStyles.homeTeam,
                      _chooseHomeTeam),
              _selectedAwayTeam != null
                  ? _getSelectTeamWidget(
                      _selectedAwayTeam!.name,
                      _selectedAwayTeam!.shortName,
                      ColorStyles.awayTeam,
                      _chooseHomeTeam)
                  : _getSelectTeamWidget(
                      Strings.createMatchSelectAwayTeam,
                      Strings.createMatchAwayTeamHint,
                      ColorStyles.awayTeam,
                      _chooseAwayTeam),
              const Spacer(),
              _getSelectOversWidget(),
              const Spacer(),
              Elements.getConfirmButton(
                  text: Strings.createMatchStartMatch,
                  onPressed: () => _createMatch()),
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

  Widget _getSelectOversWidget() {
    return const ListTile(
      title: Text("Overs"),
      subtitle: Text("Default: 20 for now"),
    );
  }

  void _chooseHomeTeam() {
    _chooseTeam(_selectedHomeTeam, (chosenTeam) {
      _selectedHomeTeam = chosenTeam;
    });
  }

  void _chooseAwayTeam() {
    _chooseTeam(_selectedAwayTeam, (chosenTeam) {
      _selectedAwayTeam = chosenTeam;
    });
  }

  void _chooseTeam(
    Team? selectedTeam,
    Function(Team) callInsideSetState,
  ) async {
    Team? chosenTeam = await Utils.goToPage(
      CreateTeamForm(
        team: selectedTeam,
      ),
      context,
    );
    if (chosenTeam != null) {
      setState(() {
        callInsideSetState(chosenTeam);
      });
    }
  }

  void _createMatch() {
    if (_selectedHomeTeam != null && _selectedAwayTeam != null) {
      Utils.goToPage(
          MatchScreen(
            match: CricketMatch(
              homeTeam: _selectedHomeTeam!,
              awayTeam: _selectedAwayTeam!,
              maxOvers: 20,
            ),
          ),
          context);
    }
  }
}
