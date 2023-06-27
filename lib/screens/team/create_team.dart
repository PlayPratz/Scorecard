import 'package:flutter/material.dart';
import 'package:scorecard/screens/widgets/generic_item_tile.dart';
import 'package:scorecard/screens/widgets/separated_widgets.dart';
import 'package:scorecard/services/storage_service.dart';

import '../../models/player.dart';
import '../../models/team.dart';
import '../../util/strings.dart';
import '../../util/elements.dart';
import '../../util/utils.dart';
import '../player/player_list.dart';
import '../templates/titled_page.dart';
import '../player/player_tile.dart';

class CreateTeamForm extends StatefulWidget {
  final Team team;

  factory CreateTeamForm({Team? team}) {
    if (team == null) {
      return CreateTeamForm.blank();
    }
    return CreateTeamForm.update(team: team);
  }

  CreateTeamForm.blank({super.key}) : team = Team.generate();

  const CreateTeamForm.update({super.key, required this.team});

  @override
  State<CreateTeamForm> createState() => _CreateTeamFormState();
}

class _CreateTeamFormState extends State<CreateTeamForm> {
  Player? _selectedCaptain;
  final List<Player> _selectedPlayerList = [];

  final TextEditingController _teamNameController = TextEditingController();
  final TextEditingController _shortTeamNameController =
      TextEditingController();

  @override
  void initState() {
    super.initState();

    Team team = widget.team;
    _teamNameController.text = team.name;
    _shortTeamNameController.text = team.shortName;

    if (widget.team.squadSize > 0) {
      _selectedCaptain = team.squad[0];
      _selectedPlayerList.addAll(team.squad.sublist(1));
    }
  }

  @override
  Widget build(BuildContext context) {
    return TitledPage(
      title: Strings.createNewTeam,
      child: Form(
        child: Column(
          children: [
            _wTeamNameChooser(),
            const SizedBox(height: 16),
            _wCaptainChooser(),
            const SizedBox(height: 16),
            _wSquadChooser(),
            Elements.getConfirmButton(
                text: Strings.createTeamSave,
                onPressed: _canSubmitTeam ? _submitTeam : null),
          ],
        ),
      ),
    );
  }

  void _submitTeam() {
    Team team = widget.team;
    team.name = _teamNameController.text;
    team.shortName = _shortTeamNameController.text;
    team.squad = [_selectedCaptain!, ..._selectedPlayerList];
    team.color = genTeamTemplates[genTeamIndex % genTeamTemplates.length].color;
    StorageService.saveTeam(team);
    Utils.goBack(context, team);
  }

  bool get _canSubmitTeam => _selectedCaptain != null;

  void _chooseCaptain() async {
    Player? chosenCaptain =
        await getPlayerFromList(StorageService.getAllPlayers(), context);
    if (chosenCaptain != null) {
      if (_selectedPlayerList.contains(chosenCaptain)) {
        _selectedPlayerList.remove(chosenCaptain);
        if (_selectedCaptain != null) {
          _selectedPlayerList.add(_selectedCaptain!);
        }
      }
      setState(() {
        _selectedCaptain = chosenCaptain;
      });
    }
  }

  Widget _wTeamNameChooser() {
    return Row(
      children: [
        Expanded(
            child: GestureDetector(
          onTap: () => setState(() {
            genTeamIndex++;
          }),
          child: CircleAvatar(
            backgroundColor:
                genTeamTemplates[genTeamIndex % genTeamTemplates.length].color,
          ),
        )),
        Expanded(
          flex: 2,
          child: TextFormField(
            controller: _teamNameController,
            maxLength: 20,
            decoration:
                const InputDecoration(label: Text(Strings.createTeamTeamName)),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: TextFormField(
            controller: _shortTeamNameController,
            textCapitalization: TextCapitalization.characters,
            maxLength: 4,
            decoration:
                const InputDecoration(label: Text(Strings.createTeamShortName)),
          ),
        ),
      ],
    );
  }

  Widget _wCaptainChooser() {
    return _selectedCaptain == null
        ? GenericItemTile(
            leading: const Icon(Icons.person),
            primaryHint: Strings.createTeamSelectCaptain,
            secondaryHint: Strings.createTeamCaptainHint,
            trailing: Elements.forwardIcon,
            onSelect: _chooseCaptain,
          )
        : Column(
            children: [
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: const Text(
                  Strings.captain,
                ),
              ),
              PlayerTile(
                _selectedCaptain!,
                onSelect: (Player player) => _chooseCaptain(),
              ),
            ],
          );
  }

  Widget _wSquadChooser() {
    return Expanded(
      child: SeparatedWidgetPair(
        top: GenericItemTile(
            leading: const Icon(Icons.people),
            primaryHint: Strings.squad,
            secondaryHint: Strings.createTeamSquadHint,
            trailing: Elements.addIcon,
            onSelect: () async {
              List<Player> filteredPlayerList = StorageService.getAllPlayers();
              filteredPlayerList.removeWhere(
                  (player) => _selectedPlayerList.contains(player));
              filteredPlayerList.remove(_selectedCaptain);
              Player? player =
                  await getPlayerFromList(filteredPlayerList, context);
              if (player != null) {
                setState(() {
                  if (_selectedCaptain == null) {
                    _selectedCaptain = player;
                  } else {
                    _selectedPlayerList.add(player);
                  }
                });
              }
            }),
        bottom: Expanded(
          child: PlayerList(
            playerList: _selectedPlayerList,
            trailingIcon: Elements.removeIcon,
            onSelectPlayer: (Player player) {
              setState(() {
                _selectedPlayerList.remove(player);
              });
            },
          ),
        ),
      ),
    );
  }
}
