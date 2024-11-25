import 'package:scorecard/modules/player/player_model.dart';
import 'package:scorecard/modules/repository/service/repository_service.dart';
import 'package:scorecard/repositories/generic_repository.dart';
import 'package:scorecard/util/ulid.dart';

class PlayerService {
  /// Creates a player
  Future<Player> createPlayer(String name) async {
    final player = Player(id: ULID.generate(), name: name);
    _playerRepository.create(player);
    return player;
  }

  /// Fetches a player of the given [id]
  Future<Player?> getPlayerById(String id) async {
    final player = _playerRepository.read(id);
    return player;
  }

  /// Fetches all players
  Future<Iterable<Player>> getAllPlayers(int page) async {
    final players = await _playerRepository.readAll();
    return players;
  }

  /// Deletes the player of the given [id]
  Future<void> deletePlayerById(String id) async {
    await _playerRepository.delete(id);
  }

  /// Returns the [String] path of the photo of the player.
  Future<String> getPhotoOfPlayer(Player player) async {
    return "";
  }

  /// Saves any changes made to the [Player].
  Future<void> savePlayer(Player player) async {
    return await _playerRepository.update(player);
  }

  Future<Iterable<Player>> searchPlayer(String query) async {
    return await _playerRepository.search(query);
  }

  IRepository<Player> get _playerRepository =>
      RepositoryService().getPlayerRepository();
}
