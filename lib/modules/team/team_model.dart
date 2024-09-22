import 'package:scorecard/modules/player/player_model.dart';

class Team {
  final String name;
  final int color;

  Team({required this.name, required this.color});
}

class Squad {
  final Team team;
  final Iterable<Player> players;
  final Player captain;
  // final Player? wicketkeeper; TODO

  Squad({required this.team, required this.players, required this.captain});
}
