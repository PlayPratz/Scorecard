import 'package:flutter/material.dart';
import '../models/player.dart';
import '../models/team.dart';
import 'playerlist.dart';
import 'titledpage.dart';
import 'widgets/playertile.dart';
import '../styles/colorstyles.dart';
import '../styles/strings.dart';
import '../util/elements.dart';
import '../util/utils.dart';

class CreateTeamForm extends StatefulWidget {
  final Team? team;

  const CreateTeamForm({Key? key, this.team}) : super(key: key);

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

    if (widget.team != null) {
      Team team = widget.team!;
      _teamNameController.text = team.name;
      _shortTeamNameController.text = team.shortName;
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
                text: Strings.createTeamCreate,
                onPressed: _validateForm() ? _submitTeam : null),
          ],
        ),
      ),
    );
  }

  void _submitTeam() {
    Utils.goBack(
        context,
        Team(
          _teamNameController.text,
          _shortTeamNameController.text,
          [_selectedCaptain!, ..._selectedPlayerList],
        ));
  }

  bool _validateForm() {
    if (_selectedCaptain == null) {
      return false;
    }
    return true;
  }

  Future<Player?> _getPlayerFromList(
      List<Player> playerList, BuildContext context) async {
    Player? player = await Utils.goToPage(
        TitledPage(
          title: Strings.choosePlayer,
          child: PlayerList(
            playerList: playerList,
            showAddButton: true,
            onSelectPlayer: (Player player) {
              Utils.goBack(context, player);
            },
          ),
        ),
        context);
    return player;
  }

  void _chooseCaptain() async {
    Player? chosenCaptain =
        await _getPlayerFromList(Utils.getAllPlayers(), context);
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
          flex: 2,
          child: TextFormField(
            controller: _teamNameController,
            maxLength: 25,
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
        ? ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.person),
            ),
            title: const Text(Strings.createTeamSelectCaptain),
            isThreeLine: true,
            subtitle: const Text(
              Strings.createTeamCaptainHint,
            ),
            trailing: Elements.forwardIcon,
            onTap: _chooseCaptain,
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
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: ColorStyles.highlight),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: ListTile(
                  leading: const Icon(Icons.people),
                  title: const Text(Strings.squad),
                  subtitle: const Text(
                    Strings.createTeamSquadHint,
                  ),
                  trailing: Elements.addIcon,
                  onTap: () async {
                    List<Player> filteredPlayerList = Utils.getAllPlayers();
                    filteredPlayerList.removeWhere(
                        (player) => _selectedPlayerList.contains(player));
                    filteredPlayerList.remove(_selectedCaptain);
                    Player? player =
                        await _getPlayerFromList(filteredPlayerList, context);
                    if (player != null) {
                      setState(() {
                        _selectedPlayerList.add(player);
                      });
                    }
                  }),
            ),
            const Divider(thickness: 1),
            Expanded(
              child: PlayerList(
                playerList: _selectedPlayerList,
                showAddButton: false,
                trailingIcon: Elements.removeIcon,
                onSelectPlayer: (Player player) {
                  setState(() {
                    _selectedPlayerList.remove(player);
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
