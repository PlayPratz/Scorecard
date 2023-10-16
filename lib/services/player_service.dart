import 'dart:collection';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:scorecard/models/player.dart';
import 'package:scorecard/repositories/generic_repository.dart';

/// Services all tasks related to [Player]s.
class PlayerService {
  final IRepository<Player> _playerRepository;

  PlayerService({required IRepository<Player> playerRepository})
      : _playerRepository = playerRepository;

  late final Directory _appDataDirectory;

  Future<void> initialize() async {
    _appDataDirectory = await getApplicationDocumentsDirectory();

    final playerPhotoDirectory =
        Directory("${_appDataDirectory.path}/photos/players");
    await playerPhotoDirectory.create(recursive: true);
  }

  /// Get all players that are accessible to the currently logged-in user.
  Future<UnmodifiableListView<Player>> getAll() async {
    // Fetch players from the repository
    final players = await _playerRepository.getAll();

    // Sort the players by their names in alphabetical order
    players.sort((a, b) => a.name.compareTo(b.name));

    return UnmodifiableListView(players);
  }

  Future<void> save(Player player) async {
    await _playerRepository.add(player);
  }

  Future<File?> getProfilePhoto(String playerId) async {
    // Create a file of the photo
    File photoFile = File(_getProfilePhotoPath(playerId));

    // Check if the photo exists
    if (!await photoFile.exists()) {
      return null;
    }

    return photoFile;
  }

  Future<void> saveProfilePhoto({
    required String playerId,
    required File profilePhoto,
  }) async {
    await profilePhoto.copy(_getProfilePhotoPath(playerId));
  }

  String _getProfilePhotoPath(String playerId) =>
      "${_appDataDirectory.path}/photos/players/$playerId";
}
