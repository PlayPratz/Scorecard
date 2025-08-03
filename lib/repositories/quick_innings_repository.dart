import 'package:scorecard/modules/quick_match/ball_and_extras_model.dart';
import 'package:scorecard/modules/quick_match/quick_match_model.dart';

class QuickInningsRepository {
  final _inningsTable = <QuickInnings>[];

  final _postTable = <InningsPost>[];

  Future<void> createInnings(QuickInnings innings) async {
    _inningsTable.add(innings);
  }

  Future<void> createPost(InningsPost post) async {
    _postTable.add(post);
  }
}
