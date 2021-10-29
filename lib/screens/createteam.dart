import 'package:flutter/material.dart';
import 'package:scorecard/models/player.dart';
import 'package:scorecard/models/team.dart';
import 'package:scorecard/screens/basescreen.dart';
import 'package:scorecard/screens/playerlist.dart';
import 'package:scorecard/screens/titledpage.dart';
import 'package:scorecard/screens/widgets/playertile.dart';
import 'package:scorecard/styles/colorstyles.dart';
import 'package:scorecard/styles/strings.dart';
import 'package:scorecard/util/elements.dart';
import 'package:scorecard/util/utils.dart';

class CreateTeamForm extends StatefulWidget {
  const CreateTeamForm({Key? key}) : super(key: key);

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
  Widget build(BuildContext context) {
    return TitledPage(
      title: Strings.createNewTeam,
      child: Form(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _teamNameController,
                    maxLength: 25,
                    decoration: const InputDecoration(
                        label: Text(Strings.createTeamTeamName)),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: TextFormField(
                    controller: _shortTeamNameController,
                    textCapitalization: TextCapitalization.characters,
                    maxLength: 4,
                    decoration: const InputDecoration(
                        label: Text(Strings.createTeamShortName)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _selectedCaptain == null
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
                  ),
            const SizedBox(height: 16),
            Expanded(
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
                            List<Player> filteredPlayerList =
                                Utils.getAllPlayers();
                            filteredPlayerList.removeWhere((player) =>
                                _selectedPlayerList.contains(player));
                            filteredPlayerList.remove(_selectedCaptain);
                            Player? player = await _getPlayerFromList(
                                filteredPlayerList, context);
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
            ),
            Elements.getConfirmButton(
                text: Strings.createTeamCreate,
                onPressed: _validateForm() ? _submitTeam : null),
          ],
        ),
      ),
    );
  }

  void _submitTeam() {
    Utils.addTeam(Team(
      _teamNameController.text,
      _shortTeamNameController.text,
      [_selectedCaptain!, ..._selectedPlayerList],
    ));
    Utils.goBack(context);
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
}
