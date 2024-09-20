import 'package:scorecard/modules/player/player_model.dart';

class Team {
  final String name;

  Team({required this.name});
}

class Squad {
  final Team team;
  final Iterable<Player> players;
  final Player captain;
  // final Player? wicketkeeper; TODO

  Squad({required this.team, required this.players, required this.captain});
}
