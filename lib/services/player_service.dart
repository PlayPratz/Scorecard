import 'package:scorecard/modules/player/player_model.dart';
import 'package:scorecard/repositories/player_repository.dart';

class PlayerService {
  final PlayerRepository _playerRepository;

  PlayerService(this._playerRepository);

  /// Creates a player
  Future<Player> createPlayer(String name) async {
    final player = await _playerRepository.create(name: name);
    return player;
  }

  /// Updates a player
  Future<Player> savePlayer(Player player) async {
    final updatedPlayer = await _playerRepository.save(player);
    return updatedPlayer;
  }

  /// Fetches a player of the given [id]
  Future<Player?> getPlayerById(String id) async {
    final player = await _playerRepository.load(id);
    return player;
  }

  /// Fetches a player of the given [id]
  Future<List<Player>> getPlayersByIds(Set<String> ids) async {
    final players = await _playerRepository.loadMultiple(ids);
    return players;
  }

  /// Fetches all players
  Future<List<Player>> getAllPlayers() async {
    final players = await _playerRepository.loadAll();
    return players;
  }

  /// Deletes the player of the given [id]
  // Future<void> deletePlayerById(String id) async {
  //   await _playerRepository.delete(id);
  // }

  /// Returns the [String] path of the photo of the player.
  // Future<String> getPhotoOfPlayer(Player player) async {
  //   return ""; // TODO
  // }

  // Future<Iterable<Player>> searchPlayer(String query) async {
  //   return await _playerRepository.search(query);
  // }
}
