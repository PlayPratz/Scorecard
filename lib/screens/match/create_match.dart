import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scorecard/models/cricket_match.dart';
import 'package:scorecard/models/player.dart';
import 'package:scorecard/models/team.dart';
import 'package:scorecard/screens/match/match_init.dart';
import 'package:scorecard/screens/player/player_list.dart';
import 'package:scorecard/screens/team/create_team.dart';
import 'package:scorecard/screens/team/team_dummy_tile.dart';
import 'package:scorecard/screens/templates/titled_page.dart';
import 'package:scorecard/screens/widgets/common_builders.dart';
import 'package:scorecard/screens/widgets/item_list.dart';
import 'package:scorecard/screens/widgets/number_picker.dart';
import 'package:scorecard/services/data/cricket_match_service.dart';
import 'package:scorecard/services/data/player_service.dart';
import 'package:scorecard/util/elements.dart';
import 'package:scorecard/util/strings.dart';
import 'package:scorecard/util/utils.dart';

class CreateMatchForm extends StatefulWidget {
  final void Function(CricketMatch match)? onCreateMatch;

  final TeamSquad? home;
  final TeamSquad? away;
  const CreateMatchForm({
    Key? key,
    this.onCreateMatch,
    this.home,
    this.away,
  }) : super(key: key);

  @override
  State<CreateMatchForm> createState() => _CreateMatchFormState();
}

class _CreateMatchFormState extends State<CreateMatchForm> {
  TeamSquad? _selectedHomeTeam;
  TeamSquad? _selectedAwayTeam;
  int _overs = 5;

  CricketMatch? _match;

  @override
  void initState() {
    super.initState();
    _selectedHomeTeam = widget.home;
    _selectedAwayTeam = widget.away;
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
                      _selectedHomeTeam!.team.name,
                      _selectedHomeTeam!.team.shortName,
                      _selectedHomeTeam!.team.color.withOpacity(0.8),
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
                      _selectedAwayTeam!.team.name,
                      _selectedAwayTeam!.team.shortName,
                      _selectedAwayTeam!.team.color.withOpacity(0.8),
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
                  onPressed:
                      _canCreateMatch ? () => _createMatch(context) : null),
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
    TeamSquad? currentTeam,
    Function(TeamSquad) onSelectTeam,
  ) async {
    final TeamSquad? chosenTeam = await Utils.goToPage(
      CreateTeamForm(team: currentTeam),
      context,
    );
    // Team? chosenTeam = await Utils.goToPage(
    //     TitledPage(
    //       child: TeamList(
    //         teamList: StorageService.getAllTeams(),
    //         onSelectTeam: (team) => Utils.goBack(context, team),
    //       ),
    //     ),
    //     context);
    if (chosenTeam != null) {
      setState(() {
        onSelectTeam(chosenTeam);
      });
    }
  }

  void _createMatch(BuildContext context) {
    if (_match != null) {
      // TODO This is shit logic
      context.read<CricketMatchService>().delete(_match!);
      _match = null;
    }
    final match = CricketMatch.create(
      home: _selectedHomeTeam!,
      away: _selectedAwayTeam!,
      maxOvers: _overs,
    );
    context.read<CricketMatchService>().save(match);
    _match = match;
    Utils.goToPage(MatchInitScreen(match: match), context);
    widget.onCreateMatch?.call(match);
  }

  bool get _canCreateMatch =>
      _selectedHomeTeam != null && _selectedAwayTeam != null && _overs > 0;
}

class CreateQuickMatchForm extends StatelessWidget {
  const CreateQuickMatchForm({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = SelectableItemController<Player>();
    final playersFuture = context.read<PlayerService>().getAllPlayers();
    return TitledPage(
      title: "Quick Match",
      child: SimplifiedFutureBuilder(
        future: playersFuture,
        builder: (context, playerList) {
          return Column(
            children: [
              const SizedBox(height: 16),
              Text("Select Players",
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              const SizedBox(height: 8),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: SelectablePlayerList(
                    players: playerList,
                    controller: controller,
                  ),
                ),
              ),
              ListenableBuilder(
                listenable: controller, // TODO Remove Jugaad
                builder: (context, child) => Elements.getConfirmButton(
                  text: Strings.buttonNext,
                  onPressed: controller.selectedItems.length >= 2
                      ? () => _handleCreateQuickTeams(
                          context, controller.selectedItems)
                      : null,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _handleCreateQuickTeams(
      BuildContext context, List<Player> selectedPlayers) {
    Utils.goToPage(CreateQuickTeamsForm(playerPool: selectedPlayers), context);
  }
}
