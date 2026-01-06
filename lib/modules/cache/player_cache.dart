import 'package:scorecard/modules/player/player_model.dart';

class PlayerCache {
  static final Map<int, Player> _cache = {};

  static void put(Player player) {
    _cache[player.id!] = player;
  }

  static Player get(int id) {
    return _cache[id]!;
  }

  static Iterable<Player> get all => _cache.values;
}
