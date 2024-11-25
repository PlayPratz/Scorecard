import 'package:scorecard/handlers/ulid.dart';
import 'package:scorecard/modules/player/player_model.dart';
import 'package:scorecard/repositories/generic_repository.dart';
import 'package:scorecard/repositories/provider/repository_provider.dart';

class PlayerService {
  /// Creates a player
  Future<Player> savePlayer(String name, {String? fullName, String? id}) async {
    if (fullName != null && fullName.isEmpty) fullName = null;

    if (id == null) {
      // Create player
      return _createPlayer(name, fullName: fullName);
    } else {
      return _updatePlayer(name, id: id, fullName: fullName);
    }
  }

  Future<Player> _createPlayer(String name, {String? fullName}) async {
    if (fullName != null && fullName.isEmpty) fullName = null;
    final player = Player(id: ULID.generate(), name: name, fullName: fullName);
    _playerRepository.create(player);
    return player;
  }

  /// Saves any changes made to the [Player].
  Future<Player> _updatePlayer(String name,
      {String? fullName, required String id}) async {
    final player = Player(id: id, name: name, fullName: fullName);
    await _playerRepository.update(player);
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

  Future<Iterable<Player>> searchPlayer(String query) async {
    return await _playerRepository.search(query);
  }

  IRepository<Player> get _playerRepository =>
      RepositoryProvider().getPlayerRepository();
}
