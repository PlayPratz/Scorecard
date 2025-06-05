import 'package:scorecard/handlers/ulid.dart';
import 'package:scorecard/modules/cricket_match/cache/cricket_game_cache.dart';
import 'package:scorecard/modules/cricket_match/models/cricket_friendly_model.dart';
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

    // final game = CricketGameCache.of(ongoingMatch);

    // if (ongoingMatch.toss.winner == ongoingMatch.team1 &&
    //         ongoingMatch.toss.choice == TossChoice.bat ||
    //     ongoingMatch.toss.winner == ongoingMatch.team2 &&
    //         ongoingMatch.toss.choice == TossChoice.field) {
    //   battingTeam = game.team1;
    //   battingLineup = game.lineup1;
    //   bowlingTeam = game.team2;
    //   bowlingLineup = game.lineup2;
    // } else {
    //   battingTeam = game.team2;
    //   battingLineup = game.lineup2;
    //   bowlingTeam = game.team1;
    //   bowlingLineup = game.lineup1;
    // }
    //
    // await _startInningsInGame(
    //   game,
    //   battingTeam: battingTeam,
    //   battingLineup: battingLineup,
    //   bowlingTeam: bowlingTeam,
    //   bowlingLineup: bowlingLineup,
    //   target: null,
    // );

    return ongoingMatch;
  }

  Future<CricketFriendly> createCricketFriendly(
      {required LimitedOversRules rules}) async {
    final cricketFriendly = InProgressCricketFriendly(
        id: UlidHandler.generate(), rules: rules, startsAt: DateTime.now());

    await _repository.saveCricketFriendly(cricketFriendly);
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

class LimitedOversMatchService extends CricketMatchService {
  Future<void> startFirstInnings(
    LimitedOversGame game, {
    required Team battingTeam,
    required Lineup battingLineup,
    required Team bowlingTeam,
    required Lineup bowlingLineup,
  }) async {
    final innings = FirstLimitedOversInnings(
      matchId: game.matchId,
      battingTeam: battingTeam,
      battingLineup: battingLineup,
      bowlingTeam: bowlingTeam,
      bowlingLineup: bowlingLineup,
      rules: game.rules,
    );

    await _repository.saveInnings(innings);

    game.innings.add(innings);
  }

  Future<void> _startSecondInnings(
    LimitedOversGame game, {
    required FirstLimitedOversInnings firstInnings,
    required int target,
  }) async {
    final innings = SecondLimitedOversInnings.from(firstInnings);

    await _repository.saveInnings(innings);
    game.innings.add(innings);
  }

  Future<void> endCurrentInnings(
      OngoingCricketMatch match, LimitedOversGame game) async {
    if (game.innings.length == 1) {
      // First innings over; start second innings
      final firstInnings = game.innings.single;
      if (firstInnings is! FirstLimitedOversInnings) {
        throw UnsupportedError(
            "The First Innings is not of type FirstLimitedOversInnings! matchId: ${game.matchId}");
      }
      await _startSecondInnings(game,
          firstInnings: firstInnings, target: firstInnings.runs + 1);
    } else if (game.innings.length == 2) {
      // Second innings over; prepare result
      final firstInnings = game.innings[0];
      final secondInnings = game.innings[1];
      if (firstInnings is! FirstLimitedOversInnings) {
        throw UnsupportedError(
            "The First Innings is not of type FirstLimitedOversInnings! matchId: ${game.matchId}");
      }
      if (secondInnings is! SecondLimitedOversInnings) {
        throw UnsupportedError(
            "The Second Innings is not of type SecondLimitedOversInnings! matchId: ${game.matchId}");
      }

      await _generateResult(match, game, firstInnings, secondInnings);
    }
  }

  Future<void> _generateResult(
      OngoingCricketMatch match,
      LimitedOversGame game,
      FirstLimitedOversInnings firstInnings,
      SecondLimitedOversInnings secondInnings) async {
    late LimitedOversMatchResult result;
    if (firstInnings.runs > secondInnings.runs) {
      result = WinByDefendingResult(
        winner: firstInnings.battingTeam,
        loser: secondInnings.battingTeam,
        runsMargin: firstInnings.runs - secondInnings.runs,
      );
    } else if (firstInnings.runs < secondInnings.runs) {
      // TODO Handle changed target/DLS
      result = WinByChasingResult(
        winner: secondInnings.battingTeam,
        loser: firstInnings.battingTeam,
        ballsToSpare: secondInnings.ballsLeft,
        wicketsLeft: -1, // TODO
      );
    } else {
      result = TieResult(team1: game.team1, team2: game.team2);
    }

    final completedMatch = CompletedCricketMatch.fromOngoing(match,
        result: result, playerOfTheMatch: null);

    // Save to repository
    await _repository.saveCricketMatch(completedMatch, update: true);
  }
}
