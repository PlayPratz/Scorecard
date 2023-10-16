import 'dart:io';

import 'package:path_provider/path_provider.dart';

class _PhotoHandler {
  late final Directory _appDataDirectory;

  final _photoCache = <String, File>{};

  Future<void> initialize() async {
    _appDataDirectory = await getApplicationDocumentsDirectory();

    final playerPhotoDirectory =
        Directory("${_appDataDirectory.path}/photos/players");
    await playerPhotoDirectory.create(recursive: true);
  }

  Future<File?> getPlayerPhoto(String playerId,
      {bool storeInCache = false}) async {
    // Return photo from cache
    if (_photoCache.containsKey(playerId)) {
      return _photoCache[playerId];
    }

    // Create a file of the photo
    File photoFile = File(_getPlayerPhotoPath(playerId));

    // Check if the photo exists
    if (!await photoFile.exists()) {
      return null;
    }

    // Store in cache
    if (storeInCache) {
      _photoCache[playerId] = photoFile;
    }

    return photoFile;
  }

  File? getPlayerPhotoFromCache(String playerId) {
    return _photoCache[playerId];
  }

  Future<void> savePlayerPhoto(
      {required String playerId,
      required File profilePhoto,
      storeInCache = false}) async {
    final file = await profilePhoto.copy(_getPlayerPhotoPath(playerId));

    if (storeInCache) {
      _photoCache[playerId] = file;
    }
  }

  Future<void> clearPlayerPhotoCache() async {
    _photoCache.clear();
  }

  String _getPlayerPhotoPath(String playerId) =>
      "${_appDataDirectory.path}/photos/players/$playerId";
}

// ignore: non_constant_identifier_names
final PhotoHandler = _PhotoHandler();
