import 'package:scorecard/modules/player/player_model.dart';

class Team {
  final String id;

  final String name;
  final int color;

  Team({required this.id, required this.name, required this.color});
}

class Squad {
  final Team team;
  final Iterable<Player> players;
  final Player captain;
  // final Player? wicketkeeper; TODO

  Squad({required this.team, required this.players, required this.captain});
}
