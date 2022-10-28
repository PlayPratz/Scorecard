import 'package:flutter/material.dart';
import 'package:scorecard/models/player.dart';
import 'package:scorecard/models/team.dart';
import 'package:scorecard/screens/playerlist.dart';
import 'package:scorecard/screens/titledpage.dart';
import 'package:scorecard/screens/widgets/genericitem.dart';
import 'package:scorecard/screens/widgets/playertile.dart';
import 'package:scorecard/util/elements.dart';
import 'package:scorecard/util/utils.dart';

class PlayerSelector extends StatefulWidget {
  // final int numOfBatters;

  final Team team;
  final String selectionHeading;
  final Function(Player) onPlayerSelect;
  const PlayerSelector({
    Key? key,
    required this.team,
    required this.onPlayerSelect,
    required this.selectionHeading,
  }) : super(key: key);

  @override
  State<PlayerSelector> createState() => _PlayerSelectorState();
}

class _PlayerSelectorState extends State<PlayerSelector> {
  // final List<Player> selectedBatters = [];
  Player? _playerSelection;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(widget.selectionHeading),
        _wBatterSelection(_playerSelection),
        Spacer(),
        Elements.getConfirmButton(
            text: "Select", onPressed: () => validate() ? _process() : null),
      ],
    );
  }

  Widget _wBatterSelection(Player? batter) {
    if (batter == null) {
      return GenericItem(
        primaryHint: "Choose a player",
        secondaryHint: "Hopefully they perform well",
        onSelect: () {
          Utils.goToPage(
              TitledPage(
                  title: "Pick a player",
                  child: PlayerList(
                    playerList: widget.team.squad,
                    showAddButton: false,
                    onSelectPlayer: (player) {
                      setState(() {
                        _playerSelection = player;
                      });
                      Utils.goBack(context);
                    },
                  )),
              context);
        },
      );
    }
    return PlayerTile(batter);
  }

  void _process() {
    widget.onPlayerSelect(_playerSelection!);
    _playerSelection = null;
  }

  bool validate() => _playerSelection != null;
}
