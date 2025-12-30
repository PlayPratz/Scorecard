import 'package:scorecard/modules/player/player_model.dart';

class PlayerCache {
  final Map<int, Player> _cache = {};

  void add(Player player) {
    _cache[player.id] = player;
  }

  Player get(int id) {
    return _cache[id]!;
  }
}
