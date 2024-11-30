import 'package:scorecard/handlers/ulid.dart';
import 'package:scorecard/modules/cricket_match/models/cricket_match_model.dart';
import 'package:scorecard/modules/cricket_match/models/cricket_match_rules_model.dart';
import 'package:scorecard/modules/cricket_match/models/innings_model.dart';
import 'package:scorecard/modules/cricket_match/services/innings_service.dart';
import 'package:scorecard/modules/team/models/team_model.dart';
import 'package:scorecard/modules/venue/models/venue_model.dart';
import 'package:scorecard/repositories/cricket_match_repository.dart';
import 'package:scorecard/repositories/provider/repository_provider.dart';

class CricketMatchService {
  /// Creates a cricket match from the provided data. Also saves the same in
  /// the repository
  Future<ScheduledCricketMatch> createCricketMatch({
    required Team team1,
    required Team team2,
    required Venue venue,
    required GameRules rules,
  }) async {
    final match = ScheduledCricketMatch(
      id: ULID.generate(),
      team1: team1,
      team2: team2,
      startsAt: DateTime.now(),
      venue: venue,
      rules: rules,
    );

    // Add match to repository (stage = 1)
    await _repository.saveCricketMatch(match, update: false);

    return match;
  }

  Future<InitializedCricketMatch> initializeCricketMatch(
    ScheduledCricketMatch scheduledMatch, {
    required Toss toss,
    required Lineup lineup1,
    required Lineup lineup2,
  }) async {
    final game =
        CricketGame.auto(scheduledMatch, lineup1: lineup1, lineup2: lineup2);

    final initializedMatch = InitializedCricketMatch.fromScheduled(
      scheduledMatch,
      toss: toss,
      game: game,
    );

    // Update match in repository (stage = 2)
    await _repository.saveCricketMatch(initializedMatch, update: true);

    // Store lineups
    await _repository.saveLineupsOfGame(game, update: false);

    return initializedMatch;
  }

  Future<OngoingCricketMatch> commenceCricketMatch(
      InitializedCricketMatch initializedMatch) async {
    final ongoingMatch = OngoingCricketMatch.fromInitialized(initializedMatch);

    // Update match in repository (stage = 3)
    await _repository.saveCricketMatch(ongoingMatch, update: true);

    final Team battingTeam;
    final Lineup battingLineup;
    final Team bowlingTeam;
    final Lineup bowlingLineup;

    final game = ongoingMatch.game;

    if (ongoingMatch.toss.winner == ongoingMatch.team1 &&
            ongoingMatch.toss.choice == TossChoice.bat ||
        ongoingMatch.toss.winner == ongoingMatch.team2 &&
            ongoingMatch.toss.choice == TossChoice.field) {
      battingTeam = game.team1;
      battingLineup = game.lineup1;
      bowlingTeam = game.team2;
      bowlingLineup = game.lineup2;
    } else {
      battingTeam = game.team2;
      battingLineup = game.lineup2;
      bowlingTeam = game.team1;
      bowlingLineup = game.lineup1;
    }

    await _startInningsInGame(game,
        battingTeam: battingTeam,
        battingLineup: battingLineup,
        bowlingTeam: bowlingTeam,
        bowlingLineup: bowlingLineup);

    return ongoingMatch;
  }

  Future<Innings> startNextInningsInGame(CricketGame game,
      {required bool shouldSwitchRoles}) async {
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

    final innings = await _startInningsInGame(game,
        battingTeam: battingTeam,
        battingLineup: battingLineup,
        bowlingTeam: bowlingTeam,
        bowlingLineup: bowlingLineup);

    return innings;
  }

  Future<Innings> _startInningsInGame(
    CricketGame game, {
    required Team battingTeam,
    required Lineup battingLineup,
    required Team bowlingTeam,
    required Lineup bowlingLineup,
  }) async {
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
    await _repository.storeLastInningsOfGame(game);

    return innings;
  }

  int _getNextInningsNumber(CricketGame game) => game.innings.length + 1;

  /// Fetches the [CricketGame] data for the provided [CricketMatch]
  /// from the repository and stores it within the cricket match's object
  Future<void> getGameForMatch(InitializedCricketMatch cricketMatch) async {
    final game = await _repository.loadCricketGameForMatch(cricketMatch);
    if (cricketMatch is OngoingCricketMatch) {
      // Since it's an OngoingMatch, it will have Innings and Posts as well
      // All of this must be loaded from the repository
      final allInnings =
          (await _repository.loadAllInningsOfGame(game)).toList();
      final inningsNumberToPostMap = await _repository.loadAllPostsOfGame(game);
      for (int i = 0; i < allInnings.length; i++) {
        InningsService().loadInnings(allInnings[i], inningsNumberToPostMap[i]!);
      }
      game.innings.addAll(allInnings);
    }
    // Initialize the CricketGame in the match
    cricketMatch.game = game;
  }

  CricketMatchRepository get _repository =>
      RepositoryProvider().getCricketMatchRepository();
}
