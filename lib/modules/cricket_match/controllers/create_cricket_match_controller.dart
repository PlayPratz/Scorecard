import 'package:flutter/cupertino.dart';
import 'package:scorecard/modules/cricket_match/models/cricket_match_model.dart';
import 'package:scorecard/modules/cricket_match/models/cricket_match_rules_model.dart';
import 'package:scorecard/modules/cricket_match/services/cricket_match_service.dart';
import 'package:scorecard/modules/team/models/team_model.dart';
import 'package:scorecard/modules/venue/models/venue_model.dart';

class CreateCricketMatchController {
  final team1 = ValueNotifier<Team?>(null);
  final team2 = ValueNotifier<Team?>(null);

  final ballsPerOver = ValueNotifier<int>(6);
  final noBallPenalty = ValueNotifier<int>(1);
  final wideBallPenalty = ValueNotifier<int>(1);

  final oversPerInnings = ValueNotifier<int>(10);
  final oversPerBowler = ValueNotifier<int>(10);

  final venue = ValueNotifier<Venue?>(null); // TODO add default value

  final matchType = MatchType.limitedOvers;

  // final _stateController = StreamController<CreateCricketMatchState>();
  // Stream<CreateCricketMatchState> get stateStream => _stateController.stream;

  CricketMatch scheduleMatch() {
    if (team1.value == null || team2.value == null) {
      throw UnsupportedError("Please select two teams");
    }

    if (venue.value == null) {
      throw UnsupportedError("Please select a venue");
    }

    late final GameRules rules;
    if (matchType == MatchType.limitedOvers) {
      rules = LimitedOversRules(
        widePenalty: wideBallPenalty.value,
        noBallPenalty: noBallPenalty.value,
        ballsPerOver: ballsPerOver.value,
        oversPerInnings: oversPerInnings.value,
        oversPerBowler: oversPerBowler.value,
      );
    } else {
      throw UnsupportedError("Unlimited Overs not supported");
    }

    final match = CricketMatchService().createCricketMatch(
      team1: team1.value!,
      team2: team2.value!,
      venue: venue.value!,
      rules: rules,
    );

    return match;
  }
}

// class CreateCricketMatchState {
//   final Team team1;
//   final Team team2;
//
//   final int ballsPerOver;
//   final int noBallPenalty;
//   final int wideBallPenalty;
//
//   CreateCricketMatchState({
//     required this.team1,
//     required this.team2,
//     required this.ballsPerOver,
//     required this.noBallPenalty,
//     required this.wideBallPenalty,
//   });
// }

enum MatchType {
  limitedOvers,
  unlimitedOvers,
}
