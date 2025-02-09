import 'package:scorecard/handlers/ulid.dart';
import 'package:scorecard/modules/cricket_match/cache/cricket_game_cache.dart';
import 'package:scorecard/modules/cricket_match/models/cricket_match_model.dart';
import 'package:scorecard/modules/cricket_match/models/cricket_match_rules_model.dart';
import 'package:scorecard/modules/cricket_match/models/innings_model.dart';
import 'package:scorecard/modules/cricket_match/services/innings_service.dart';
import 'package:scorecard/modules/team/models/team_model.dart';
import 'package:scorecard/modules/venue/models/venue_model.dart';
import 'package:scorecard/repositories/cricket_match_repository.dart';
import 'package:scorecard/repositories/provider/repository_provider.dart';

class CricketMatchService {
  Future<Iterable<ScheduledCricketMatch>> getAllMatches() async {
    final result = await _repository.loadAllCricketMatches();
    return result.cast();
  }

  /// Creates a cricket match from the provided data. Also saves the same in
  /// the repository
  Future<ScheduledCricketMatch> createCricketMatch({
    required Team team1,
    required Team team2,
    required GameRules rules,
  }) async {
    if (rules.id == null) {
      final rulesId = await _repository.saveGameRules(rules);
      rules.id = rulesId;
    }

    final match = ScheduledCricketMatch(
      id: UlidHandler.generate(),
      team1: team1,
      team2: team2,
      startsAt: DateTime.now(),
      venue: Venue(id: "default", name: "default"), // TODO
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
    final initializedMatch = InitializedCricketMatch.fromScheduled(
      scheduledMatch,
      toss: toss,
    );

    final game =
        CricketGame.auto(scheduledMatch, lineup1: lineup1, lineup2: lineup2);

    // Update match in repository (stage = 2)
    await _repository.saveCricketMatch(initializedMatch, update: true);

    // Store lineups
    await _repository.saveLineupsOfGame(game, update: false);

    // Cache
    CricketGameCache.store(initializedMatch, game);

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

    final game = CricketGameCache.of(ongoingMatch);

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

    await _startInningsInGame(
      game,
      battingTeam: battingTeam,
      battingLineup: battingLineup,
      bowlingTeam: bowlingTeam,
      bowlingLineup: bowlingLineup,
      target: null,
    );

    return ongoingMatch;
  }

  Future<CricketMatch> progressMatch(OngoingCricketMatch cricketMatch) async {
    final game = CricketGameCache.of(cricketMatch);
    if (game is LimitedOversGame) {
      if (game.innings.length == 2) {
        return await _endMatch(cricketMatch);
      } else {
        final innings = await startNextInningsInGame(game,
            shouldSwitchRoles: true, target: game.innings.first.runs + 1);
        return cricketMatch;
      }
    } else {
      throw UnimplementedError("Unlimited Overs Game!");
    }
  }

  Future<Innings> startNextInningsInGame(
    CricketGame game, {
    required bool shouldSwitchRoles,
    required int? target,
  }) async {
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
        bowlingLineup: bowlingLineup,
        target: target);

    return innings;
  }

  Future<Innings> _startInningsInGame(
    CricketGame game, {
    required Team battingTeam,
    required Lineup battingLineup,
    required Team bowlingTeam,
    required Lineup bowlingLineup,
    required int? target,
  }) async {
    final Innings innings = switch (game) {
      LimitedOversGame() => LimitedOversInnings(
          matchId: game.matchId,
          inningsNumber: _getNextInningsNumber(game),
          rules: game.rules,
          battingTeam: battingTeam,
          battingLineup: battingLineup,
          bowlingTeam: bowlingTeam,
          bowlingLineup: bowlingLineup,
        ),
      UnlimitedOversGame() => UnlimitedOversInnings(
          matchId: game.matchId,
          inningsNumber: _getNextInningsNumber(game),
          rules: game.rules,
          battingTeam: battingTeam,
          battingLineup: battingLineup,
          bowlingTeam: bowlingTeam,
          bowlingLineup: bowlingLineup,
        ),
    };
    innings.target = target;
    game.innings.add(innings);
    await _repository.storeLastInningsOfGame(game);
    return innings;
  }

  Future<CompletedCricketMatch> _endMatch(
      OngoingCricketMatch cricketMatch) async {
    final game = CricketGameCache.of(cricketMatch);
    switch (game) {
      case UnlimitedOversGame():
        throw UnimplementedError("I haven't coded for Unlimited Overs yet :-(");
      case LimitedOversGame():
        int team1Runs = 0;
        int team2Runs = 0;

        for (final innings in game.innings) {
          if (innings.battingTeam == game.team1) {
            team1Runs += innings.runs;
          } else if (innings.battingTeam == game.team2) {
            team2Runs += innings.runs;
          }
        }

        final LimitedOversMatchResult result;

        if (team1Runs == team2Runs) {
          result = TieResult(team1: game.team1, team2: game.team2);
        } else if (team1Runs > team2Runs &&
                game.innings.first.battingTeam == game.team1 ||
            team2Runs > team1Runs &&
                game.innings.first.battingTeam == game.team2) {
          result = WinByDefendingResult(
              winner: game.innings.first.battingTeam,
              loser: game.innings.first.bowlingTeam,
              runsMargin: (team1Runs - team2Runs).abs());
        } else {
          result = WinByChasingResult(
            winner: game.innings.last.battingTeam,
            loser: game.innings.last.bowlingTeam,
            wicketsLeft: -1,
            ballsToSpare: game.innings.last.ballsLeft,
          );
        }

        final completedMatch = CompletedCricketMatch.fromOngoing(cricketMatch,
            result: result, playerOfTheMatch: null); // TODO POTM

        await _repository.saveCricketMatch(completedMatch, update: true);

        return completedMatch;
    }
  }

  int _getNextInningsNumber(CricketGame game) => game.innings.length + 1;

  /// Fetches the [CricketGame] data for the provided [CricketMatch]
  /// from the repository and stores it within the cricket match's object
  Future<CricketGame> getGameForMatch(
      InitializedCricketMatch cricketMatch) async {
    final game = await _repository.loadCricketGameForMatch(cricketMatch);
    if (cricketMatch is OngoingCricketMatch) {
      // Since it's an OngoingMatch, it will have Innings and Posts as well
      // All of this must be loaded from the repository
      final allInnings =
          (await _repository.loadAllInningsOfGame(game)).toList();
      final inningsNumberToPostMap = await _repository.loadAllPostsOfGame(game);
      for (int i = 0; i < allInnings.length; i++) {
        if (inningsNumberToPostMap.containsKey(i + 1)) {
          await InningsService()
              .loadInnings(allInnings[i], inningsNumberToPostMap[i + 1]!);
        }
      }
      game.innings.addAll(allInnings.cast<LimitedOversInnings>());
    }
    // Cache the Cricket Game
    CricketGameCache.store(cricketMatch, game);

    return game;
  }

  CricketMatchRepository get _repository =>
      RepositoryProvider().getCricketMatchRepository();
}
