import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/cricketmatch.dart';
import '../models/team.dart';
import 'createteam.dart';
import 'matchscreen/matchinitscreen.dart';
import 'matchscreen/matchscreen.dart';
import 'titledpage.dart';
import 'widgets/teamdummytile.dart';
import '../styles/colorstyles.dart';
import '../styles/strings.dart';
import '../util/elements.dart';
import '../util/utils.dart';

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
      CricketMatch match = CricketMatch(
        homeTeam: _selectedHomeTeam!,
        awayTeam: _selectedAwayTeam!,
        maxOvers: _overs,
      );
      Utils.saveMatch(match);
      Utils.goToPage(MatchInitScreen(match: match), context);
    }
  }
}
