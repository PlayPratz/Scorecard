import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scorecard/models/cricketmatch.dart';
import 'package:scorecard/models/team.dart';
import 'package:scorecard/screens/createteam.dart';
import 'package:scorecard/screens/matchscreen/matchinitscreen.dart';
import 'package:scorecard/screens/matchscreen/matchscreen.dart';
import 'package:scorecard/screens/titledpage.dart';
import 'package:scorecard/screens/widgets/teamdummytile.dart';
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

  int _overs = 10;

  @override
  Widget build(BuildContext context) {
    return TitledPage(
        title: Strings.matchlistCreateNewMatch,
        child: Form(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: [
              _selectedHomeTeam != null
                  ? _wSelectTeam(_selectedHomeTeam!.name,
                      _selectedHomeTeam!.shortName, ColorStyles.homeTeam, true)
                  : _wSelectTeam(
                      Strings.createMatchSelectHomeTeam,
                      Strings.createMatchHomeTeamHint,
                      ColorStyles.homeTeam,
                      true),
              _selectedAwayTeam != null
                  ? _wSelectTeam(_selectedAwayTeam!.name,
                      _selectedAwayTeam!.shortName, ColorStyles.awayTeam, false)
                  : _wSelectTeam(
                      Strings.createMatchSelectAwayTeam,
                      Strings.createMatchAwayTeamHint,
                      ColorStyles.awayTeam,
                      false),
              const Spacer(),
              _wSelectOvers(),
              const Spacer(),
              Elements.getConfirmButton(
                  text: Strings.createMatchStartMatch,
                  onPressed: () => _createMatch()),
            ],
          ),
        ));
  }

  Widget _wSelectTeam(String primaryHint, String secondaryHint, Color iconColor,
      bool isHomeTeam) {
    return TeamDummyTile(
      primaryHint: primaryHint,
      secondaryHint: secondaryHint,
      isHomeTeam: isHomeTeam,
      onSelect: isHomeTeam ? _chooseHomeTeam : _chooseAwayTeam,
    );
  }

  Widget _wSelectOvers() {
    return ListTile(
      title: Text("Overs"),
      subtitle: TextField(
          keyboardType: TextInputType.number,
          onChanged: (value) => _overs = int.parse(value)),
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
          MatchInitScreen(
            match: CricketMatch(
              homeTeam: _selectedHomeTeam!,
              awayTeam: _selectedAwayTeam!,
              maxOvers: _overs,
            ),
          ),
          context);
    }
  }
}
