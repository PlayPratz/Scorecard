import 'package:scorecard/modules/cricket_match/models/cricket_match_model.dart';

/// Caches a [CricketGame] for a given [CricketMatch]
/// The way this app is designed, only a single [CricketGame] can be loaded at
/// once
class CricketGameCache {
  static final _cache = <String, CricketGame>{};

  CricketGameCache._();

  /// Caches the given [CricketGame] for the respective [CricketMatch].
  static void store(CricketMatch cricketMatch, CricketGame cricketGame) {
    clear();
    _cache[cricketMatch.id] = cricketGame;
  }

  /// Clears the [CricketGame] from the cache
  static void clear() {
    _cache.clear();
  }

  /// Even though this Cache can store only one CricketGame object at a time,
  /// it accepts an [InitializedCricketMatch] argument to ensure that
  /// an incorrect [CricketGame] instance is not returned.
  static CricketGame of(InitializedCricketMatch cricketMatch) =>
      _cache[cricketMatch.id]!;
}
