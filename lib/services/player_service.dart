import 'package:scorecard/handlers/ulid_handler.dart';
import 'package:scorecard/modules/player/player_model.dart';
import 'package:scorecard/repositories/player_repository.dart';

class PlayerService {
  final IPlayerRepository _playerRepository;

  PlayerService(this._playerRepository);

  /// Creates a player
  Future<Player> savePlayer({
    int? id,
    String? handle,
    required String name,
    String? fullName,
    DateTime? dob,
  }) async {
    final player = Player(
      id: id,
      handle: handle ?? UlidHandler.generate(),
      name: name,
      dateOfBirth: dob,
      fullName: fullName,
    );

    final newPlayer = await _playerRepository.save(player);
    return newPlayer;
  }

  /// Fetches a player of the given [id]
  Future<Player?> getPlayerById(int id) async {
    final player = await _playerRepository.load(id);
    return player;
  }

  /// Fetches a player of the given [id]
  // Future<List<Player>> getPlayersByIds(Set<int> ids) async {
  //   final players = await _playerRepository.loadMultiple(ids);
  //   return players;
  // }

  /// Fetches all players
  Future<List<Player>> getAllPlayers() async {
    final players = await _playerRepository.loadAll();
    return players;
  }

  // Future<List<Player>> loadPlayersForMatch(QuickMatch match) async {
  //   final players = await _playerRepository.loadPlayersForMatch(match);
  //
  //   return players;
  // }

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
