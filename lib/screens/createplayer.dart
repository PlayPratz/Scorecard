import 'package:flutter/material.dart';

import '../models/player.dart';
import '../styles/strings.dart';
import '../util/elements.dart';
import '../util/helpers.dart';
import 'titledpage.dart';

class CreatePlayerForm extends StatefulWidget {
  final Player? player;
  const CreatePlayerForm({Key? key, this.player}) : super(key: key);

  @override
  State<CreatePlayerForm> createState() => _CreatePlayerFormState();
}

class _CreatePlayerFormState extends State<CreatePlayerForm> {
  String? _name;

  SingleToggleSelection<Arm> _batArm = SingleToggleSelection(
      dataList: Arm.values,
      stringifier: Strings.getArm,
      allowNoSelection: false);

  SingleToggleSelection<Arm> _bowlArm = SingleToggleSelection(
      dataList: Arm.values,
      stringifier: Strings.getArm,
      allowNoSelection: false);

  SingleToggleSelection<BowlStyle> _bowlStyle = SingleToggleSelection(
      dataList: BowlStyle.values,
      stringifier: Strings.getBowlStyle,
      allowNoSelection: false);

  @override
  Widget build(BuildContext context) {
    return TitledPage(
        title: "Create a Player",
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Elements.getTextInput("Name", "A future superstar?",
                        (value) => _name = value),
                    SizedBox(height: 32),
                    _wToggleButtonWithLabel(_batArm, "Bat Arm"),
                    _wToggleButtonWithLabel(_bowlArm, "Bowl Arm"),
                    _wToggleButtonWithLabel(_bowlStyle, "Bowl Style"),
                  ],
                ),
              ),
            ),
            Elements.getConfirmButton(text: "Create Player"),
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

  void _onCreatePlayer() {}

  bool get canCreatePlayer => false;
}
