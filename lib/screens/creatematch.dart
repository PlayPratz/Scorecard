import 'package:flutter/material.dart';
import 'package:scorecard/screens/teamlist.dart';

import '../models/cricketmatch.dart';
import '../models/team.dart';
import '../styles/colorstyles.dart';
import '../styles/strings.dart';
import '../util/elements.dart';
import '../util/utils.dart';
import 'matchscreen/matchinitscreen.dart';
import 'titledpage.dart';
import 'widgets/teamdummytile.dart';

class CreateMatchForm extends StatefulWidget {
  const CreateMatchForm({Key? key}) : super(key: key);

  @override
  State<CreateMatchForm> createState() => _CreateMatchFormState();
}

class _CreateMatchFormState extends State<CreateMatchForm> {
  Team? _selectedHomeTeam;
  Team? _selectedAwayTeam;
  int _overs = 5;

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
                  onPressed: _canCreateMatch ? () => _createMatch() : null),
            ],
          ),
        ));
  }

  Widget _wSelectTeam(String primaryHint, String secondaryHint, Color iconColor,
      bool isHomeTeam) {
    return TeamDummyTile(
      primaryHint: primaryHint,
      secondaryHint: secondaryHint,
      color: isHomeTeam ? ColorStyles.homeTeam : ColorStyles.awayTeam,
      onSelect: isHomeTeam ? _chooseHomeTeam : _chooseAwayTeam,
    );
  }

  Widget _wSelectOvers() {
    return Elements.getTextInput(
      Strings.createMatchOvers,
      Strings.createMatchOversHint,
      (value) {
        setState(() {
          if (value.isNotEmpty) {
            _overs = int.parse(value);
          } else {
            _overs = -1;
          }
        });
      },
      _overs.toString(),
      TextInputType.number,
    );
  }

  void _chooseHomeTeam() {
    _chooseTeam((chosenTeam) {
      _selectedHomeTeam = chosenTeam;
    });
  }

  void _chooseAwayTeam() {
    _chooseTeam((chosenTeam) {
      chosenTeam.color = ColorStyles.awayTeam;
      _selectedAwayTeam = chosenTeam;
    });
  }

  void _chooseTeam(
    Function(Team) onSelectTeam,
  ) async {
    Team? chosenTeam = await Utils.goToPage(
      TitledPage(
        title: Strings.chooseTeam,
        child: TeamList(
          teamList: Utils.getAllTeams(),
          onSelectTeam: (team) => Utils.goBack(context, team),
        ),
      ),
      context,
    );
    if (chosenTeam != null) {
      setState(() {
        onSelectTeam(chosenTeam);
      });
    }
  }

  void _createMatch() {
    CricketMatch match = CricketMatch.create(
      homeTeam: _selectedHomeTeam!,
      awayTeam: _selectedAwayTeam!,
      maxOvers: _overs,
    );
    Utils.saveMatch(match);
    Utils.goToReplacementPage(MatchInitScreen(match: match), context);
  }

  bool get _canCreateMatch =>
      _selectedHomeTeam != null && _selectedAwayTeam != null && _overs > 0;
}
