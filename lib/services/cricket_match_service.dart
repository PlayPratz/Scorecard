import 'dart:collection';
import 'package:scorecard/handlers/photo_handler.dart';
import 'package:scorecard/handlers/share_handler.dart';
import 'package:scorecard/models/cricket_match.dart';
import 'package:scorecard/repositories/cricket_match_repository.dart';
import 'package:scorecard/repositories/generic_repository.dart';
import 'package:scorecard/util/strings.dart';

/// Services all tasks related to a [CricketMatch]es.
class CricketMatchService {
  final IRepository<CricketMatch> _cricketMatchRepository;

  CricketMatchService({
    required IRepository<CricketMatch> cricketMatchRepository,
  }) : _cricketMatchRepository = cricketMatchRepository;

  Future<void> initialize() async {}

  Future<List<CricketMatch>> _getSortedByDate() async {
    final cricketMatches = await _cricketMatchRepository.getAll();

    // Sort teams by the timestamp of creation
    // TODO sort by updatedAt instead of createdAt
    cricketMatches.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return cricketMatches;
  }

  Future<UnmodifiableListView<CricketMatch>> getOngoing() async {
    final cricketMatches = await _getSortedByDate();
    return UnmodifiableListView(
        cricketMatches.where((cricketMatch) => !cricketMatch.isCompleted));
  }

  Future<UnmodifiableListView<CricketMatch>> getCompleted() async {
    final cricketMatches = await _getSortedByDate();
    return UnmodifiableListView(
        cricketMatches.where((cricketMatch) => cricketMatch.isCompleted));
  }

  Future<void> open(CricketMatch cricketMatch) async {
    // Clear previous cache, if any
    PhotoHandler.clearPlayerPhotoCache();

    // Store photos in cache
    for (final player in cricketMatch.home.squad) {
      await PhotoHandler.getPlayerPhoto(player.id, storeInCache: true);
    }
    for (final player in cricketMatch.away.squad) {
      await PhotoHandler.getPlayerPhoto(player.id, storeInCache: true);
    }
  }

  // Future<void> close(CricketMatch cricketMatch) async {
  //   // Remove photos from cache
  //   for (final player in cricketMatch.home.squad) {
  //     await PhotoHandler.clearPlayerPhotoFromCache(player.id);
  //   }
  //   for (final player in cricketMatch.away.squad) {
  //     await PhotoHandler.clearPlayerPhotoFromCache(player.id);
  //   }
  // }

  Future<void> save(CricketMatch cricketMatch) async {
    await _cricketMatchRepository.add(cricketMatch);
  }

  Future<void> delete(CricketMatch cricketMatch) async {
    await _cricketMatchRepository.delete(cricketMatch.id);
  }

  Future<void> share(CricketMatch cricketMatch) async {
    final cricketMatchDTO = CricketMatchDTO.of(cricketMatch);
    ShareHandler.shareCricketMatchesJson([cricketMatchDTO.toMap()],
        "${Strings.getCricketMatchTitle(cricketMatch)}-${cricketMatch.id}");
  }
}
