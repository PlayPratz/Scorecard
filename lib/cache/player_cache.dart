import 'package:scorecard/modules/player/player_model.dart';

class PlayerCache {
  final Map<String, Player> _playerMap = {};

  PlayerCache._();
  static final instance = PlayerCache._(); //TODO Find more efficient way?

  factory PlayerCache() => instance;

  void put(Player player) {
    _playerMap[player.id] = player;
  }

  void putAll(Iterable<Player> players) {
    _playerMap.addAll({for (var p in players) p.id: p});
  }

  Player get(String id) {
    final player = _playerMap[id];
    if (player == null) {
      throw StateError(
          "Attempted to retrieve player which was never cached (id : $id)");
    }
    return player;
  }

  Map<String, Player> all() => {..._playerMap};

  void clear() {
    _playerMap.clear();
  }
}
