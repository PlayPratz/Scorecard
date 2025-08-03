import 'package:scorecard/modules/quick_match/ball_and_extras_model.dart';
import 'package:scorecard/modules/quick_match/match_rules_model.dart';
import 'package:scorecard/modules/quick_match/quick_match_model.dart';
import 'package:scorecard/repositories/quick_innings_repository.dart';
import 'package:scorecard/repositories/quick_match_repository.dart';

class QuickMatchService {
  Future<QuickMatch> createQuickMatch(QuickMatchRules rules) async {
    final match = await _matchRepo.createMatch(rules);
    return match;
  }

  Future<QuickInnings> createInnings(QuickMatch match, {int? target}) async {
    int inningsNumber = target == null ? 1 : 2;
    final innings = QuickInnings.of(match, inningsNumber);
    await _inningsRepo.createInnings(innings);

    return innings;
  }

  Future<void> createPost(InningsPost post) async {
    await _inningsRepo.createPost(post);
  }

  QuickMatchRepository get _matchRepo => QuickMatchRepository();
  QuickInningsRepository get _inningsRepo => QuickInningsRepository();
}
