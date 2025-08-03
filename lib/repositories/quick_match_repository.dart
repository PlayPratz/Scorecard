import 'package:scorecard/handlers/ulid.dart';
import 'package:scorecard/modules/quick_match/quick_match_model.dart';

class QuickMatchRepository {
  final _repo = <String, QuickMatch>{};

  Future<List<QuickMatch>> getAllMatches() async => _repo.values.toList();

  Future<void> createMatch() async {
    final match =
        QuickMatch(UlidHandler.generate(), startsAt: DateTime.now().toUtc());

    _repo[match.id] = match;
  }

  Future<void> saveMatch(QuickMatch quickMatch) async {
    _repo[quickMatch.id] = quickMatch;
  }
}
