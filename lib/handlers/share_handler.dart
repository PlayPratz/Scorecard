import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:scorecard/models/cricket_match.dart';
import 'package:scorecard/repositories/cricket_match_repository.dart';
import 'package:scorecard/util/strings.dart';
import 'package:share_plus/share_plus.dart';

/// Handles all requests related to sharing (and in the future, importing) data
/// to outside the app
class _ShareHandler {
  late final Directory cacheDirectory;

  Future<void> initialize() async {
    cacheDirectory = await getTemporaryDirectory();
  }

  Future<void> shareCricketMatch(CricketMatch cricketMatch) async {
    // JSONify the CricketMatch
    String jsonString = jsonEncode(
      CricketMatchDTO.of(cricketMatch).toMap(),
      toEncodable: (nonEncodable) {
        if (nonEncodable is DateTime) {
          return nonEncodable.microsecondsSinceEpoch;
        }
        return "DEV_ERROR: " + nonEncodable.toString();
      },
    );

    // Create a temporary file
    final file = File(
        "${cacheDirectory.path}/matches/${Strings.getCricketMatchTitle(cricketMatch)}-${cricketMatch.id}.json");
    await file.create(recursive: true);
    await file.writeAsString(jsonString);

    // Share the file
    await Share.shareXFiles([XFile(file.path)]);
  }
}

// ignore: non_constant_identifier_names
final ShareHandler = _ShareHandler();
