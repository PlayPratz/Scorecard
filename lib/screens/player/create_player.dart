import 'package:flutter/material.dart';
import 'package:scorecard/util/storage_util.dart';

import '../../models/player.dart';
import '../../util/strings.dart';
import '../../util/elements.dart';
import '../../util/helpers.dart';
import '../../util/utils.dart';
import '../templates/titled_page.dart';

class CreatePlayerForm extends StatefulWidget {
  final Player? player;

  const CreatePlayerForm({Key? key})
      : player = null,
        super(key: key);

  const CreatePlayerForm.update({Key? key, required this.player})
      : super(key: key);

  @override
  State<CreatePlayerForm> createState() => _CreatePlayerFormState();
}

class _CreatePlayerFormState extends State<CreatePlayerForm> {
  String? _name;
  ImageProvider? _playerPhoto;

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
      _name = widget.player!.name;
      _playerPhoto = StorageUtils.getPlayerPhoto(widget.player!);
    }

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
                    InkWell(
                      onTap: () => Utils.pickPhotoFromGallery()
                          .then((photo) => setState(() {
                                if (photo != null) {
                                  _playerPhoto = photo;
                                }
                              })),
                      child: CircleAvatar(
                        radius: 64,
                        foregroundImage: _playerPhoto,
                        child: const Icon(
                          Icons.person,
                          size: 56,
                        ),
                      ),
                    ),
                    Elements.getTextInput(
                      Strings.createPlayerName,
                      Strings.createPlayerNameHint,
                      (value) => setState(() {
                        _name = value;
                      }),
                      widget.player?.name,
                    ),
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
                text: Strings.createPlayerSave,
                onPressed: _canCreatePlayer ? _onCreatePlayer : null),
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
    if (_playerPhoto != null) {
      StorageUtils.savePlayerPhoto(player.id, (_playerPhoto as FileImage).file);
    }
    StorageUtils.savePlayer(player);
    Utils.goBack(context, player);
  }

  bool get _canCreatePlayer => _name != null;
}
