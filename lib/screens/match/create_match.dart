import 'package:flutter/material.dart';
import 'package:scorecard/screens/team/team_list.dart';
import 'package:scorecard/screens/widgets/number_picker.dart';
import 'package:scorecard/services/storage_service.dart';

import '../../models/cricket_match.dart';
import '../../models/team.dart';
import '../../util/elements.dart';
import '../../util/strings.dart';
import '../../util/utils.dart';
import '../templates/titled_page.dart';
import '../team/team_dummy_tile.dart';
import 'match_init.dart';

class CreateMatchForm extends StatefulWidget {
  final void Function(CricketMatch match)? onCreateMatch;

  final Team? homeTeam;
  final Team? awayTeam;
  const CreateMatchForm({
    Key? key,
    this.onCreateMatch,
    this.homeTeam,
    this.awayTeam,
  }) : super(key: key);

  @override
  State<CreateMatchForm> createState() => _CreateMatchFormState();
}

class _CreateMatchFormState extends State<CreateMatchForm> {
  Team? _selectedHomeTeam;
  Team? _selectedAwayTeam;
  int _overs = 5;

  @override
  void initState() {
    super.initState();
    _selectedHomeTeam = widget.homeTeam;
    _selectedAwayTeam = widget.awayTeam;
  }

  @override
  Widget build(BuildContext context) {
    return TitledPage(
        title: Strings.matchlistCreateNewMatch,
        showBackButton: false,
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
    return SizedBox(
      width: 192,
      child: Column(children: [
        const Text(Strings.createMatchOvers),
        NumberPicker(min: 1, onChange: (value) => _overs = value)
      ]),
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
  // TODO Convert ALLLLL Callbacks to Async calls
  // (This is what happens when you develop in TypeScript and Dart simulatenously.)

  void _chooseTeam(
    Team? currentTeam,
    Function(Team) onSelectTeam,
  ) async {
    // final Team? chosenTeam = await Utils.goToPage(
    //   CreateTeamForm(team: currentTeam),
    //   context,
    // );
    Team? chosenTeam = await Utils.goToPage(
        TitledPage(
          child: TeamList(
            teamList: StorageService.getAllTeams(),
            onSelectTeam: (team) => Utils.goBack(context, team),
          ),
        ),
        context);
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
    StorageService.saveMatch(match);
    Utils.goToReplacementPage(MatchInitScreen(match: match), context);
    widget.onCreateMatch?.call(match);
  }

  bool get _canCreateMatch =>
      _selectedHomeTeam != null && _selectedAwayTeam != null && _overs > 0;
}
