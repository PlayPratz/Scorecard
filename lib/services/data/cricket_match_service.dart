import 'dart:collection';
import 'package:scorecard/models/cricket_match.dart';
import 'package:scorecard/repositories/generic_repository.dart';

/// Services all tasks related to a [CricketMatch]es.
class CricketMatchService {
  final IRepository<CricketMatch> _cricketMatchRepository;

  CricketMatchService(
      {required IRepository<CricketMatch> cricketMatchRepository})
      : _cricketMatchRepository = cricketMatchRepository;

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

  Future<void> save(CricketMatch cricketMatch) async {
    await _cricketMatchRepository.add(cricketMatch);
  }

  Future<void> delete(CricketMatch cricketMatch) async {
    await _cricketMatchRepository.delete(cricketMatch.id);
  }
}
