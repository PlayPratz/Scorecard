import 'package:scorecard/modules/quick_match/post_ball_and_extras_model.dart';
import 'package:scorecard/modules/quick_match/quick_match_model.dart';

class QuickInningsRepository {
  final _inningsTable = <QuickInnings>[];
  final _postTable = <InningsPost>[];

  Future<void> create(QuickInnings innings) async {
    _inningsTable.add(innings);
  }

  Future<void> save(QuickInnings innings) async {
    _inningsTable.removeWhere((i) =>
        i.matchId == innings.matchId &&
        i.inningsNumber == innings.inningsNumber);
    _inningsTable.add(innings);
  }

  Future<void> createPost(InningsPost post) async {
    _postTable.add(post);
  }

  Future<void> deletePost(InningsPost post) async {
    _postTable.remove(post);
  }

  Future<QuickInnings?> loadLast(String matchId) async {
    for (int i = _inningsTable.length - 1; i >= 0; i--) {
      if (_inningsTable[i].matchId == matchId) {
        return _inningsTable[i];
      }
    }
    return null;
  }

  Future<List<QuickInnings>> loadAll(String matchId) async {
    return _inningsTable.where((i) => i.matchId == matchId).toList();
  }
}
