import 'package:flutter/material.dart';

import '../util/utils.dart';
import 'player.dart';

int genTeamIndex = -1;

class Team {
  final String id;

  String name;
  String shortName;
  List<Player> squad;
  Color color;

  Team(
      {required this.id,
      required this.name,
      required this.shortName,
      required this.squad,
      required this.color});

  Team.create(
      {required this.name,
      required this.shortName,
      required this.squad,
      required this.color})
      : id = Utils.generateUniqueId();

  factory Team.generate() {
    _TeamTemplate template =
        genTeamTemplates[++genTeamIndex % genTeamTemplates.length];
    return Team.create(
        name: template.name,
        shortName: template.shortName,
        squad: [],
        color: template.color);
  }

  int get squadSize => squad.length;
  Player get captain => squad.first;
}

class _TeamTemplate {
  String name;
  String shortName;
  Color color;

  _TeamTemplate(
      {required this.name, required this.shortName, required this.color});
}

final List<_TeamTemplate> genTeamTemplates = [
  _TeamTemplate(name: "Aqua", shortName: "AQU", color: Colors.blue),
  _TeamTemplate(name: "Lava", shortName: "LAV", color: Colors.deepOrange),
  _TeamTemplate(name: "Smoke", shortName: "SMK", color: Colors.black12),
  _TeamTemplate(name: "Grass", shortName: "GRA", color: Colors.green),
  _TeamTemplate(name: "Mint", shortName: "MIN", color: Colors.cyan),
  _TeamTemplate(name: "Cookie", shortName: "CKE", color: Colors.brown),
  _TeamTemplate(name: "Lemon", shortName: "LEM", color: Colors.lime),
  _TeamTemplate(name: "Blackberry", shortName: "BLB", color: Colors.deepPurple),
];
