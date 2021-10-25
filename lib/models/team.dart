import 'package:scorecard/models/player.dart';

class Team {
  String name;
  String shortName;

  List<Player> squad;

  Team(this.name, this.shortName, this.squad);

  int get squadSize => squad.length;
}
