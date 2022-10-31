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

  int get squadSize => squad.length;
  Player get captain => squad.first;
}
