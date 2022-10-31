import 'dart:math';

import 'package:flutter/material.dart';
import 'package:scorecard/styles/colorstyles.dart';

import '../util/utils.dart';
import 'player.dart';

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
      this.color = ColorStyles.homeTeam});

  Team.create(
      {required this.name,
      required this.shortName,
      required this.squad,
      this.color = ColorStyles.homeTeam})
      : id = Utils.generateUniqueId();

  factory Team.generate() {
    _TeamTemplate template = _templates[Random().nextInt(8)];
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

final List<_TeamTemplate> _templates = [
  _TeamTemplate(name: "Blue", shortName: "BLU", color: Colors.blue),
  _TeamTemplate(name: "Saffron", shortName: "SAF", color: Colors.orange),
  _TeamTemplate(name: "Amber", shortName: "AMB", color: Colors.amber),
  _TeamTemplate(name: "Green", shortName: "GRN", color: Colors.green),
  _TeamTemplate(name: "Cyan", shortName: "CYN", color: Colors.cyan),
  _TeamTemplate(name: "Brown", shortName: "BRN", color: Colors.brown),
  _TeamTemplate(name: "Orange", shortName: "ORA", color: Colors.deepOrange),
  _TeamTemplate(name: "Purple", shortName: "PRP", color: Colors.purple),
];
