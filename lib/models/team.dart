import '../util/utils.dart';
import 'player.dart';

class Team {
  final String id;

  String name;
  String shortName;
  final List<Player> squad;

  Team(
      {required this.id,
      required this.name,
      required this.shortName,
      required this.squad});

  Team.create(
      {required this.name, required this.shortName, required this.squad})
      : id = Utils.generateUniqueId();

  int get squadSize => squad.length;
  Player get captain => squad.first;
}
