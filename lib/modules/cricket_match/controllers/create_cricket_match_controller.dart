import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:scorecard/modules/cricket_match/models/cricket_match_rules_model.dart';
import 'package:scorecard/modules/team/models/team_model.dart';

class TeamSelectController with ChangeNotifier {
  Team? _team1;
  Team? _team2;

  void _dispatchState() {
    notifyListeners();
  }

  Team? get team1 => _team1;
  set team1(Team? x) {
    _team1 = x;
    if (_team2 == x) {
      _team2 = null;
    }
    _dispatchState();
  }

  Team? get team2 => _team2;
  set team2(Team? x) {
    _team2 = x;
    if (_team1 == x) {
      _team1 = null;
    }
    _dispatchState();
  }
}

class TeamSelectState {
  final Team? team;

  TeamSelectState(this.team);
}

class LimitedOverGameRulesController with ChangeNotifier {
  int _ballsPerOver = 6;
  int _noBallPenalty = 1;
  int _widePenalty = 1;
  int _oversPerInnings = 10;
  int _oversPerBowler = 10;

  LimitedOversRules rules = LimitedOversRules(
    ballsPerOver: 6,
    widePenalty: 1,
    noBallPenalty: 1,
    oversPerInnings: 10,
    oversPerBowler: 10,
  );

  // LimitedOverGameRulesController(super.value);

  void _dispatchState() {
    rules = LimitedOversRules(
        ballsPerOver: _ballsPerOver,
        widePenalty: _widePenalty,
        noBallPenalty: _noBallPenalty,
        oversPerInnings: _oversPerInnings,
        oversPerBowler: _oversPerBowler);
    notifyListeners();
  }

  set ballsPerOver(int x) {
    _ballsPerOver = x;
    _dispatchState();
  }

  set noBallPenalty(int x) {
    _noBallPenalty = x;
    _dispatchState();
  }

  set widePenalty(int x) {
    _widePenalty = x;
    _dispatchState();
  }

  set overPerInnings(int x) {
    _oversPerInnings = x;
    if (_oversPerBowler > x) {
      _oversPerBowler = x;
    }
    _dispatchState();
  }

  set oversPerBowler(int x) {
    _oversPerBowler = x;
    _dispatchState();
  }
}

// enum MatchType {
//   limitedOvers,
//   unlimitedOvers,
// }
