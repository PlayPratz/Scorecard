import 'package:scorecard/handlers/ulid.dart';
import 'package:scorecard/modules/cricket_match/models/cricket_match_model.dart';
import 'package:scorecard/modules/cricket_match/models/cricket_match_rules_model.dart';
import 'package:scorecard/modules/cricket_match/models/innings_model.dart';
import 'package:scorecard/modules/team/models/team_model.dart';
import 'package:scorecard/modules/venue/models/venue_model.dart';
import 'package:scorecard/repositories/cricket_match_repository.dart';
import 'package:scorecard/repositories/provider/repository_provider.dart';

class CricketMatchService {
  ScheduledCricketMatch createCricketMatch({
    required Team team1,
    required Team team2,
    required Venue venue,
    required GameRules rules,
  }) {
    final match = ScheduledCricketMatch(
      id: ULID.generate(),
      team1: team1,
      team2: team2,
      startsAt: DateTime.now(),
      venue: venue,
      rules: rules,
    );

    // Add match to repository
    _repository.scheduleCricketMatch(match);

    return match;
  }

  CricketGame initializeCricketGame(
    ScheduledCricketMatch scheduledMatch, {
    required Toss toss,
    required Lineup lineup1,
    required Lineup lineup2,
  }) {
    final match =
        InitializedCricketMatch.fromScheduled(scheduledMatch, toss: toss);

    final CricketGame game =
        CricketGame.auto(match, lineup1: lineup1, lineup2: lineup2);

    // Update match in repository
    _repository.initializeCricketGame(game);

    return game;
  }

  void commenceCricketGame(CricketGame game) {
    // Update match in repository
    _repository.commenceCricketGame(game);

    final match = game.match;
    if (match.toss.winner == match.team1 &&
            match.toss.choice == TossChoice.bat ||
        match.toss.winner == match.team2 &&
            match.toss.choice == TossChoice.field) {
      _startFirstInningsInGame(
        game,
        battingTeam: match.team1,
        battingLineup: game.lineup1,
        bowlingTeam: match.team2,
        bowlingLineup: game.lineup2,
      );
    } else {
      _startFirstInningsInGame(
        game,
        battingTeam: match.team2,
        battingLineup: game.lineup2,
        bowlingTeam: match.team1,
        bowlingLineup: game.lineup1,
      );
    }
  }

  void _startFirstInningsInGame(
    CricketGame game, {
    required Team battingTeam,
    required Lineup battingLineup,
    required Team bowlingTeam,
    required Lineup bowlingLineup,
  }) {
    final Innings innings = switch (game) {
      LimitedOversGame() => LimitedOversInnings(
          inningsNumber: _getNextInningsNumber(game),
          rules: game.rules,
          battingTeam: battingTeam,
          battingLineup: battingLineup,
          bowlingTeam: bowlingTeam,
          bowlingLineup: bowlingLineup,
        ),
      UnlimitedOversGame() => UnlimitedOversInnings(
          inningsNumber: _getNextInningsNumber(game),
          rules: game.rules,
          battingTeam: battingTeam,
          battingLineup: battingLineup,
          bowlingTeam: bowlingTeam,
          bowlingLineup: bowlingLineup,
        ),
    };
    game.innings.add(innings);
    _repository.putLastInningsOfGame(game);
  }

  void startNextInningsInGame(CricketGame game,
      {required bool shouldSwitchRoles}) {
    late final Team battingTeam;
    late final Lineup battingLineup;
    late final Team bowlingTeam;
    late final Lineup bowlingLineup;

    final previousInnings = game.innings.last;

    if (shouldSwitchRoles) {
      battingTeam = previousInnings.bowlingTeam;
      battingLineup = previousInnings.bowlingLineup;
      bowlingTeam = previousInnings.battingTeam;
      bowlingLineup = previousInnings.battingLineup;
    } else {
      battingTeam = previousInnings.battingTeam;
      battingLineup = previousInnings.battingLineup;
      bowlingTeam = previousInnings.bowlingTeam;
      bowlingLineup = previousInnings.bowlingLineup;
    }

    final Innings innings = switch (game) {
      LimitedOversGame() => LimitedOversInnings(
          inningsNumber: _getNextInningsNumber(game),
          rules: game.rules,
          battingTeam: battingTeam,
          battingLineup: battingLineup,
          bowlingTeam: bowlingTeam,
          bowlingLineup: bowlingLineup,
        ),
      UnlimitedOversGame() => UnlimitedOversInnings(
          inningsNumber: _getNextInningsNumber(game),
          rules: game.rules,
          battingTeam: battingTeam,
          battingLineup: battingLineup,
          bowlingTeam: bowlingTeam,
          bowlingLineup: bowlingLineup,
        ),
    };
    game.innings.add(innings);
  }

  int _getNextInningsNumber(CricketGame game) => game.innings.length + 1;

  CricketMatchRepository get _repository =>
      RepositoryProvider().getCricketMatchRepository();
}
