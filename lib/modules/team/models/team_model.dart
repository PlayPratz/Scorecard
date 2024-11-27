import 'package:scorecard/modules/player/player_model.dart';

class Team {
  final String id;

  final String short;
  final String name;
  final int color;

  Team({
    required this.id,
    required this.short,
    required this.name,
    required this.color,
  });
}
//
// class PlayingTeam extends Team {
//   final List<Player> lineup;
//   final Player captain;
//
//   PlayingTeam(
//       {required super.id,
//       required super.short,
//       required super.name,
//       required super.color,
//       required this.lineup,
//       required this.captain});
//
//   PlayingTeam.fromTeam(
//     Team team, {
//     required List<Player> lineup,
//     required Player captain,
//   }) : this(
//           id: team.id,
//           name: team.name,
//           short: team.short,
//           color: team.color,
//           captain: captain,
//           lineup: lineup,
//         );
// }

class Lineup {
  final List<Player> players;
  final Player captain;
  // final Player? wicketkeeper; TODO

  Lineup({required this.players, required this.captain});
}
