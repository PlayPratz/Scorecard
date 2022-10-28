import 'package:flutter/material.dart';
import 'package:scorecard/models/player.dart';
import 'package:scorecard/models/team.dart';
import 'package:scorecard/screens/playerlist.dart';
import 'package:scorecard/screens/titledpage.dart';
import 'package:scorecard/screens/widgets/genericitem.dart';
import 'package:scorecard/screens/widgets/playertile.dart';
import 'package:scorecard/util/elements.dart';
import 'package:scorecard/util/utils.dart';

class BatterSelector extends StatefulWidget {
  // final int numOfBatters;

  final Team team;
  final Function(Player) onBatterSelect;
  const BatterSelector(
      {Key? key, required this.team, required this.onBatterSelect})
      : super(key: key);

  @override
  State<BatterSelector> createState() => _BatterSelectorState();
}

class _BatterSelectorState extends State<BatterSelector> {
  // final List<Player> selectedBatters = [];
  Player? _batterSelection;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("Select Batter"),
        _wBatterSelection(_batterSelection),
        Spacer(),
        Elements.getConfirmButton(
            text: "Select",
            onPressed: () =>
                validate() ? widget.onBatterSelect(_batterSelection!) : null),
      ],
    );
  }

  Widget _wBatterSelection(Player? batter) {
    if (batter == null) {
      return GenericItem(
        primaryHint: "Choose a batter",
        secondaryHint: "Hopefully they score enough runs",
        onSelect: () {
          Utils.goToPage(
              TitledPage(
                  title: "Pick a batter",
                  child: PlayerList(
                    playerList: widget.team.squad,
                    showAddButton: false,
                    onSelectPlayer: (player) {
                      setState(() {
                        _batterSelection = player;
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

  bool validate() => _batterSelection != null;
}
