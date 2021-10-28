import 'package:flutter/material.dart';
import 'package:scorecard/models/player.dart';
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

  @override
  Widget build(BuildContext context) {
    return TitledPage(
      title: Strings.createNewTeam,
      child: Form(
        child: Column(
          children: [
            TextFormField(
              decoration: const InputDecoration(label: Text("Team Name")),
            ),
            const SizedBox(height: 32),
            _selectedCaptain == null
                ? ListTile(
                    leading: CircleAvatar(
                      child: Icon(Icons.person),
                    ),
                    title: Text("Select a captain"),
                    isThreeLine: true,
                    subtitle: Text(
                      "A good captain can make a bad team good, and a bad captain can make a good team bad.",
                    ),
                    trailing: Icon(Icons.chevron_right),
                    onTap: chooseCaptain,
                  )
                : Column(
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          "Captain",
                        ),
                      ),
                      PlayerTile(
                        _selectedCaptain!,
                        onSelect: (Player player) => chooseCaptain(),
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
                          title: const Text("Squad"),
                          subtitle: const Text(
                            "Your captain is already in the squad. You can change the captian later.",
                          ),
                          trailing: Elements.addIcon,
                          onTap: () async {
                            List<Player> filteredPlayerList =
                                Utils.getAllPlayers();
                            filteredPlayerList.removeWhere((player) =>
                                _selectedPlayerList.contains(player));
                            filteredPlayerList.remove(_selectedCaptain);
                            Player? player = await getPlayerFromList(
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
            OutlinedButton(onPressed: () {}, child: Text("Confirm"))
          ],
        ),
      ),
    );
  }

  Future<Player?> getPlayerFromList(
      List<Player> playerList, BuildContext context) async {
    Player? player = await Utils.goToPage(
        TitledPage(
          title: "Choose a player",
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

  void chooseCaptain() async {
    Player? chosenCaptain =
        await getPlayerFromList(Utils.getAllPlayers(), context);
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
