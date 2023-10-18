import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Handles all requests related to sharing (and in the future, importing) data
/// to outside the app
class _ShareHandler {
  late final Directory cacheDirectory;

  Future<void> initialize() async {
    cacheDirectory = await getTemporaryDirectory();
  }

  Future<void> shareCricketMatchesJson(
      List<Map<String, dynamic>> mapList, String filename) async {
    final file =
        await _createJsonFile({"matches": mapList}, "/matches", filename);
    // Share the file
    await Share.shareXFiles([XFile(file.path)]);
  }

  // Future<void> sharePlayerJson(
  //     Map<String, dynamic> map, String filename) async {
  //   final file = await _createJsonFile(map, "/players", filename);
  //   // Share the file
  //   await Share.shareXFiles([XFile(file.path)]);
  // }

  Future<void> sharePlayersJson(
      List<Map<String, dynamic>> mapList, String filename) async {
    final file =
        await _createJsonFile({"players": mapList}, "/players", filename);

    await Share.shareXFiles([XFile(file.path)]);
  }

  Future<File> _createJsonFile(
      Map<String, dynamic> map, String path, String filename) async {
    String jsonString = _generateJson(map);

    final file = File("${cacheDirectory.path}$path/$filename.json");
    await file.create(recursive: true);
    await file.writeAsString(jsonString);

    return file;
  }

  String _generateJson(Map<String, dynamic> map) =>
      jsonEncode(map, toEncodable: (nonEncodable) {
        if (nonEncodable is DateTime) {
          return nonEncodable.microsecondsSinceEpoch;
        }
        return "DEV_ERROR: " + nonEncodable.toString();
      });
}

// ignore: non_constant_identifier_names
final ShareHandler = _ShareHandler();
