import 'package:flutter/material.dart';

import '../models/player.dart';
import '../styles/strings.dart';
import '../util/elements.dart';
import '../util/helpers.dart';
import '../util/utils.dart';
import 'titledpage.dart';

class CreatePlayerForm extends StatefulWidget {
  final Player? player;
  const CreatePlayerForm({Key? key, this.player}) : super(key: key);

  @override
  State<CreatePlayerForm> createState() => _CreatePlayerFormState();
}

class _CreatePlayerFormState extends State<CreatePlayerForm> {
  String? _name;

  final SingleToggleSelection<Arm> _batArm = SingleToggleSelection(
      dataList: Arm.values,
      stringifier: Strings.getArm,
      allowNoSelection: false);

  final SingleToggleSelection<Arm> _bowlArm = SingleToggleSelection(
      dataList: Arm.values,
      stringifier: Strings.getArm,
      allowNoSelection: false);

  final SingleToggleSelection<BowlStyle> _bowlStyle = SingleToggleSelection(
      dataList: BowlStyle.values,
      stringifier: Strings.getBowlStyle,
      allowNoSelection: false);

  @override
  void initState() {
    super.initState();

    if (widget.player != null) {
      Player player = widget.player!;
      _batArm.selection = player.batArm;
      _bowlArm.selection = player.bowlArm;
      _bowlStyle.selection = player.bowlStyle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return TitledPage(
        title: Strings.createPlayerTitle,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Elements.getTextInput(
                        Strings.createPlayerName,
                        Strings.createPlayerNameHint,
                        widget.player?.name,
                        (value) => _name = value),
                    const SizedBox(height: 32),
                    _wToggleButtonWithLabel(
                        _batArm, Strings.createPlayerBatArm),
                    _wToggleButtonWithLabel(
                        _bowlArm, Strings.createPlayerBowlArm),
                    _wToggleButtonWithLabel(
                        _bowlStyle, Strings.createPlayerBowlStyle),
                  ],
                ),
              ),
            ),
            Elements.getConfirmButton(
                text: Strings.createPlayerSave, onPressed: _onCreatePlayer),
          ],
        ));
  }

  Widget _wToggleButtonWithLabel(
      SingleToggleSelection toggleSelection, String heading) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(heading),
          const SizedBox(height: 16),
          Row(
            children: [
              ToggleButtons(
                children: toggleSelection.widgets,
                isSelected: toggleSelection.booleans,
                onPressed: (index) {
                  setState(() {
                    toggleSelection.index = index;
                  });
                },
                constraints: const BoxConstraints(minWidth: 72, minHeight: 48),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _onCreatePlayer() {
    Player player;
    if (widget.player != null) {
      player = widget.player!;
      player.name = _name!;
      player.batArm = _batArm.selection!;
      player.bowlArm = _bowlArm.selection!;
      player.bowlStyle = _bowlStyle.selection!;
    } else {
      player = Player.create(
          name: _name!,
          batArm: _batArm.selection!,
          bowlArm: _bowlArm.selection!,
          bowlStyle: _bowlStyle.selection!);
    }
    Utils.savePlayer(player);
    Utils.goBack(context);
  }

  bool get canCreatePlayer => _name != null;
}
