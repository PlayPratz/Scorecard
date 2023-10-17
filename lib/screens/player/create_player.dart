import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scorecard/handlers/image_picker_handler.dart';
import 'package:scorecard/models/player.dart';
import 'package:scorecard/screens/templates/titled_page.dart';
import 'package:scorecard/services/player_service.dart';
import 'package:scorecard/screens/widgets/elements.dart';
import 'package:scorecard/screens/widgets/helpers.dart';
import 'package:scorecard/util/strings.dart';
import 'package:scorecard/util/utils.dart';

class CreatePlayerForm extends StatefulWidget {
  final Player? player;

  const CreatePlayerForm.create({super.key}) : player = null;

  const CreatePlayerForm.update({super.key, required this.player});

  @override
  State<CreatePlayerForm> createState() => _CreatePlayerFormState();
}

class _CreatePlayerFormState extends State<CreatePlayerForm> {
  String? _name;
  ImageProvider? _playerPhoto;

  final SingleSelectionToggle<Arm> _batArm = SingleSelectionToggle(
      dataList: Arm.values,
      stringifier: Strings.getArm,
      allowNoSelection: false);

  final SingleSelectionToggle<Arm> _bowlArm = SingleSelectionToggle(
      dataList: Arm.values,
      stringifier: Strings.getArm,
      allowNoSelection: false);

  final SingleSelectionToggle<BowlStyle> _bowlStyle = SingleSelectionToggle(
      dataList: BowlStyle.values,
      stringifier: Strings.getBowlStyle,
      allowNoSelection: false);

  @override
  void initState() {
    super.initState();
    if (widget.player != null) {
      _name = widget.player!.name;
      context
          .read<PlayerService>()
          .getPhotoFromStorage(widget.player!)
          .then((photoFile) {
        if (photoFile != null) {
          setState(() {
            _playerPhoto = FileImage(photoFile);
          });
        }
      });
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
                    DecoratedBox(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          shape: BoxShape.circle),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => ImagePickerHandler.pickPhotoFromGallery()
                            .then((photo) => setState(() {
                                  if (photo != null) {
                                    _playerPhoto = FileImage(photo);
                                  }
                                })),
                        child: CircleAvatar(
                          radius: 64,
                          foregroundImage: _playerPhoto,
                          backgroundColor: Colors.transparent,
                          child: const Icon(
                            Icons.camera_alt,
                            size: 48,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Elements.getTextInput(
                      Strings.createPlayerName,
                      Strings.createPlayerNameHint,
                      (value) => setState(() {
                        _name = value;
                      }),
                      widget.player?.name,
                      null,
                      TextCapitalization.words,
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
                onPressed:
                    _canCreatePlayer ? () => _onCreatePlayer(context) : null),
          ],
        ));
  }

  Widget _wToggleButtonWithLabel(
      SingleSelectionToggle toggleSelection, String heading) {
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

  void _onCreatePlayer(BuildContext context) {
    final player = Player(
      id: widget.player?.id ?? Utils.generateUniqueId(),
      name: _name!,
      batArm: _batArm.selection!,
      bowlArm: _bowlArm.selection!,
      bowlStyle: _bowlStyle.selection!,
    );

    if (_playerPhoto != null) {
      context
          .read<PlayerService>()
          .savePhoto(player, (_playerPhoto as FileImage).file);
    }
    Utils.goBack(context, player);
  }

  bool get _canCreatePlayer => _name != null;
}
