import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scorecard/models/player.dart';
import 'package:scorecard/models/team.dart';
import 'package:scorecard/screens/player/player_pickers.dart';
import 'package:scorecard/screens/player/player_list.dart';
import 'package:scorecard/screens/player/player_tile.dart';
import 'package:scorecard/screens/templates/titled_page.dart';
import 'package:scorecard/screens/widgets/generic_item_tile.dart';
import 'package:scorecard/screens/widgets/item_list.dart';
import 'package:scorecard/screens/widgets/separated_widgets.dart';
import 'package:scorecard/services/data/player_service.dart';
import 'package:scorecard/util/elements.dart';
import 'package:scorecard/util/strings.dart';
import 'package:scorecard/util/utils.dart';

class CreateTeamForm extends StatefulWidget {
  final TeamSquad team;

  factory CreateTeamForm({TeamSquad? team}) {
    if (team == null) {
      return CreateTeamForm.blank();
    }
    return CreateTeamForm.update(team: team);
  }

  CreateTeamForm.blank({super.key}) : team = TeamSquad.generate();

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

  late Color _color;

  @override
  void initState() {
    super.initState();

    TeamSquad teamSquad = widget.team;
    _teamNameController.text = teamSquad.team.name;
    _shortTeamNameController.text = teamSquad.team.shortName;
    _color = teamSquad.team.color;

    if (teamSquad.squadSize > 0) {
      _selectedCaptain = teamSquad.squad[0];
      _selectedPlayerList.addAll(teamSquad.squad.sublist(1));
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
              onPressed: _canSubmitTeam ? _submitTeamSquad : null,
            ),
          ],
        ),
      ),
    );
  }

  void _submitTeamSquad() {
    final teamSquad = TeamSquad(
      team: Team(
        id: widget.team.team.id,
        name: _teamNameController.text,
        shortName: _shortTeamNameController.text,
        color: _color,
      ),
      squad: [_selectedCaptain!, ..._selectedPlayerList],
    );

    Utils.goBack(context, teamSquad);
  }

  bool get _canSubmitTeam => _selectedCaptain != null;

  void _chooseCaptain() async {
    final players = await context.read<PlayerService>().getAll();
    Player? chosenCaptain = await choosePlayer(context, players);
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
            _color =
                genTeamTemplates[genTeamIndex % genTeamTemplates.length].color;
          }),
          child: CircleAvatar(backgroundColor: _color),
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
              List<Player> filteredPlayerList =
                  await context.read<PlayerService>().getAll();
              filteredPlayerList.removeWhere(
                  (player) => _selectedPlayerList.contains(player));
              filteredPlayerList.remove(_selectedCaptain);
              Player? player = await choosePlayer(context, filteredPlayerList);
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
            onSelect: (Player player) {
              setState(() {
                _selectedPlayerList.remove(player);
              });
            },
          ),
        ),
        color: _color.withOpacity(0.1),
      ),
    );
  }
}

class CreateQuickTeamsForm extends StatelessWidget {
  final List<Player> playerPool;

  const CreateQuickTeamsForm({super.key, required this.playerPool});

  @override
  Widget build(BuildContext context) {
    final controller = CreateQuickTeamsFormController(playerPool: playerPool);
    final shuffledTemplates = [...genTeamTemplates]..shuffle();
    final colors = shuffledTemplates
        .take(2)
        .map((teamTemplate) => teamTemplate.color.withOpacity(0.2))
        .toList();
    return TitledPage(
      title: "Quick Teams",
      child: ListenableBuilder(
        listenable: controller,
        builder: (context, child) => Column(
          children: [
            _wTeamPool(context, controller, colors.first,
                "Team ${controller.team1}", controller.squad1, false, true),
            _wTeamPool(context, controller, null, "Pool", controller.playerPool,
                true, true),
            _wTeamPool(context, controller, colors.last,
                "Team ${controller.team2}", controller.squad2, true, false),
            Elements.getConfirmButton(
              text: Strings.buttonNext,
              onPressed: controller.canSubmit
                  ? () => _handleSubmitTeams(
                      context, controller, colors.first, colors.last)
                  : null,
            )
          ],
        ),
      ),
    );
  }

  void _handleSubmitTeams(BuildContext context,
      CreateQuickTeamsFormController controller, Color teamA, Color teamB) {
    final team1 = TeamSquad(
      team: Team.create(
        name: controller.team1,
        shortName: controller.team1.substring(0, 3).toUpperCase(),
        color: teamA,
      ),
      squad: controller.squad1,
    );

    final team2 = TeamSquad(
      team: Team.create(
        name: controller.team2,
        shortName: controller.team2.substring(0, 3).toUpperCase(),
        color: teamB,
      ),
      squad: controller.squad2,
    );

    Utils.goBack(
      context,
      [team1, team2],
    );
  }

  Widget _wTeamPool(
    BuildContext context,
    CreateQuickTeamsFormController controller,
    Color? color,
    String title,
    List<Player> players,
    bool showUp,
    bool showDown,
  ) =>
      Expanded(
        child: SeparatedWidgetPair(
          top: Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          bottom: Expanded(
            child: ItemList(
              itemList: players
                  .map(
                    (player) => ListTile(
                      leading: IconButton(
                        onPressed:
                            showUp ? () => controller.moveUp(player) : null,
                        icon: Visibility(
                          visible: showUp,
                          child: Transform.rotate(
                              angle: pi / 2,
                              child: const Icon(Icons.arrow_circle_left)),
                        ),
                      ),
                      title: Row(
                        children: [
                          Elements.getPlayerIcon(player, 32, null), //TODO
                          const SizedBox(width: 12),
                          Text(player.name),
                        ],
                      ),
                      trailing: showDown
                          ? IconButton(
                              onPressed: showDown
                                  ? () => controller.moveDown(player)
                                  : null,
                              icon: Visibility(
                                visible: showDown,
                                child: Transform.rotate(
                                    angle: -pi / 2,
                                    child: const Icon(Icons.arrow_circle_left)),
                              ),
                            )
                          : null,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  )
                  .toList(),
              alignToBottom: false,
            ),
          ),
          color: color,
        ),
      );
}

class CreateQuickTeamsFormController with ChangeNotifier {
  final List<Player> playerPool;

  CreateQuickTeamsFormController({required this.playerPool});

  final List<Player> squad1 = [];
  final List<Player> squad2 = [];

  void moveUp(Player player) {
    if (squad2.contains(player)) {
      squad2.remove(player);
      playerPool.add(player);
      playerPool.sort((a, b) => a.name.compareTo(b.name));
    } else if (playerPool.contains(player)) {
      playerPool.remove(player);
      squad1.add(player);
    }
    notifyListeners();
  }

  void moveDown(Player player) {
    if (squad1.contains(player)) {
      squad1.remove(player);
      playerPool.add(player);
      playerPool.sort((a, b) => a.name.compareTo(b.name));
    } else if (playerPool.contains(player)) {
      playerPool.remove(player);
      squad2.add(player);
    }
    notifyListeners();
  }

  String get team1 =>
      squad1.isNotEmpty ? squad1.first.name : "A"; // TODO move hardcoded
  String get team2 => squad2.isNotEmpty ? squad2.first.name : "B";

  bool get canSubmit =>
      playerPool.isEmpty && squad1.isNotEmpty && squad2.isNotEmpty;
}
