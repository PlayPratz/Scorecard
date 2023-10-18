import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:scorecard/handlers/photo_handler.dart';
import 'package:scorecard/handlers/share_handler.dart';
import 'package:scorecard/models/player.dart';
import 'package:scorecard/repositories/generic_repository.dart';
import 'package:scorecard/repositories/player_repository.dart';

/// Services all tasks related to [Player]s.
class PlayerService {
  final IRepository<Player> _playerRepository;

  PlayerService({required IRepository<Player> playerRepository})
      : _playerRepository = playerRepository;

  Future<void> initialize() async {}

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

  File? getPhotoFromCache(Player player) {
    return PhotoHandler.getPlayerPhotoFromCache(player.id);
  }

  Future<File?> getPhotoFromStorage(Player player) async {
    return await PhotoHandler.getPlayerPhoto(player.id, storeInCache: true);
  }

  Future<void> savePhoto(Player player, File profilePhoto) async {
    await PhotoHandler.savePlayerPhoto(
        playerId: player.id, profilePhoto: profilePhoto);
  }

  Future<void> share(List<Player> players) async {
    final mapList = <Map<String, dynamic>>[];

    for (final player in players) {
      final map = PlayerDTO.of(player).toMap();

      // Handle Photo
      final photoFile = await getPhotoFromStorage(player);
      if (photoFile != null) {
        final photoBytes = await photoFile.readAsBytes();
        map["photo"] = base64Encode(photoBytes);
      }
      mapList.add(map);
    }
    final filename = players.length == 1
        ? "${players.single.name}-${players.single.id}"
        : "players-export-${DateTime.now()}";

    await ShareHandler.sharePlayersJson(mapList, filename);
  }

  Future<void> shareAll() async {
    final players = await getAll();
    await share(players);
  }
}
