import 'package:flutter/material.dart';
import 'package:scorecard/screens/team/team_list.dart';
import 'package:scorecard/util/storage_util.dart';

import '../../models/cricket_match.dart';
import '../../models/team.dart';
import '../../util/elements.dart';
import '../../util/strings.dart';
import '../../util/utils.dart';
import '../templates/titled_page.dart';
import '../team/team_dummy_tile.dart';
import 'match_init.dart';

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
              const Spacer(),
              _selectedHomeTeam != null
                  ? _wSelectTeam(
                      _selectedHomeTeam!.name,
                      _selectedHomeTeam!.shortName,
                      _selectedHomeTeam!.color,
                      true,
                    )
                  : _wSelectTeam(
                      Strings.createMatchSelectHomeTeam,
                      Strings.createMatchHomeTeamHint,
                      Colors.white,
                      true,
                    ),
              const SizedBox(height: 32),
              _selectedAwayTeam != null
                  ? _wSelectTeam(
                      _selectedAwayTeam!.name,
                      _selectedAwayTeam!.shortName,
                      _selectedAwayTeam!.color,
                      false,
                    )
                  : _wSelectTeam(
                      Strings.createMatchSelectAwayTeam,
                      Strings.createMatchAwayTeamHint,
                      Colors.white,
                      false,
                    ),
              const SizedBox(height: 64),
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
      color: iconColor,
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
          teamList: StorageUtils.getAllTeams(),
          onSelectTeam: (team) => Utils.goBack(context, team),
          onCreateTeam: (team) => Utils.goBack(context, team),
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
