import 'dart:collection';

import 'package:scorecard/models/player.dart';
import 'package:scorecard/styles/color_styles.dart';
import 'package:scorecard/util/utils.dart';

int genTeamIndex = -1;

class Team {
  final String id;

  final String name;
  final String shortName;
  final int color;

  Team({
    required this.id,
    required this.name,
    required this.shortName,
    required this.color,
  });

  Team.create(
      {required this.name, required this.shortName, required this.color})
      : id = Utils.generateUniqueId();

  factory Team.generate() {
    _TeamTemplate template =
        genTeamTemplates[++genTeamIndex % genTeamTemplates.length];
    return Team.create(
        name: template.name,
        shortName: template.shortName,
        color: ColorStyles.teamColors[genTeamIndex].value);
  }
}

class _TeamTemplate {
  final String name;
  final String shortName;

  _TeamTemplate({required this.name, required this.shortName});
}

final List<_TeamTemplate> genTeamTemplates = [
  _TeamTemplate(name: "Aqua", shortName: "AQU"),
  _TeamTemplate(name: "Lava", shortName: "LAV"),
  _TeamTemplate(name: "Solar", shortName: "SOL"),
  _TeamTemplate(name: "Grass", shortName: "GRA"),
  _TeamTemplate(name: "Galaxy", shortName: "GLX"),
  _TeamTemplate(name: "Mint", shortName: "MIN"),
  _TeamTemplate(name: "Cookie", shortName: "CKE"),
  _TeamTemplate(name: "Black Currant", shortName: "BCR"),
  _TeamTemplate(name: "Lemon", shortName: "LEM"),
];

class TeamSquad {
  final Team team;
  final List<Player> _squad;

  TeamSquad({required this.team, required List<Player> squad}) : _squad = squad;

  TeamSquad.generate()
      : team = Team.generate(),
        _squad = [];

  UnmodifiableListView<Player> get squad => UnmodifiableListView(_squad);

  Player get captain => _squad.first;
  int get squadSize => _squad.length;
}
