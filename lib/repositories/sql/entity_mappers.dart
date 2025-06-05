import 'package:scorecard/modules/cricket_match/models/cricket_friendly_model.dart';
import 'package:scorecard/modules/cricket_match/models/cricket_match_model.dart';
import 'package:scorecard/modules/cricket_match/models/cricket_match_rules_model.dart';
import 'package:scorecard/modules/cricket_match/models/innings_model.dart';
import 'package:scorecard/modules/cricket_match/models/wicket_model.dart';
import 'package:scorecard/modules/player/player_model.dart';
import 'package:scorecard/modules/team/models/team_model.dart';
import 'package:scorecard/modules/venue/models/venue_model.dart';
import 'package:scorecard/repositories/sql/db/game_rules_table.dart';
import 'package:scorecard/repositories/sql/db/innings_table.dart';
import 'package:scorecard/repositories/sql/db/lineups_view.dart';
import 'package:scorecard/repositories/sql/db/players_in_match_table.dart';
import 'package:scorecard/repositories/sql/db/matches_expanded_view.dart';
import 'package:scorecard/repositories/sql/db/matches_table.dart';
import 'package:scorecard/repositories/sql/db/players_table.dart';
import 'package:scorecard/repositories/sql/db/posts_table.dart';
import 'package:scorecard/repositories/sql/db/teams_table.dart';
import 'package:scorecard/repositories/sql/db/venues_table.dart';

class EntityMappers {
  EntityMappers._();

  static PlayersEntity repackPlayer(Player player) => PlayersEntity(
        id: player.id,
        name: player.name,
        full_name: player.fullName,
      );

  static Player unpackPlayer(PlayersEntity entity) => Player(
        id: entity.id,
        name: entity.name,
        fullName: entity.full_name,
      );

  static TeamsEntity repackTeam(Team team) => TeamsEntity(
        id: team.id,
        name: team.name,
        short: team.short,
        color: team.color,
      );

  static Team unpackTeam(TeamsEntity entity) => Team(
        id: entity.id,
        short: entity.short,
        name: entity.name,
        color: entity.color,
      );

  static VenueEntity repackVenue(Venue venue) => VenueEntity(
        id: venue.id,
        name: venue.name,
      );

  static Venue unpackVenue(VenueEntity entity) => Venue(
        id: entity.name,
        name: entity.id,
      );

  static GameRulesEntity repackGameRules(GameRules rules) => switch (rules) {
        UnlimitedOversRules() => GameRulesEntity(
            id: rules.id,
            type: _gameRulesToInt(rules),
            balls_per_over: rules.ballsPerOver,
            no_ball_penalty: rules.noBallPenalty,
            wide_penalty: rules.widePenalty,
            only_single_batter: rules.onlySingleBatter,
            last_wicket_batter: rules.lastWicketBatter,
            days_of_play: rules.daysOfPlay,
            sessions_per_day: rules.sessionsPerDay,
            innings_per_side: rules.inningsPerSide,
          ),
        LimitedOversRules() => GameRulesEntity(
            id: rules.id,
            type: _gameRulesToInt(rules),
            balls_per_over: rules.ballsPerOver,
            no_ball_penalty: rules.noBallPenalty,
            wide_penalty: rules.widePenalty,
            only_single_batter: rules.onlySingleBatter,
            last_wicket_batter: rules.lastWicketBatter,
            overs_per_innings: rules.oversPerInnings,
            overs_per_bowler: rules.oversPerBowler,
          ),
      };

  static GameRules unpackGameRules(GameRulesEntity entity) =>
      switch (entity.type) {
        0 => UnlimitedOversRules(
            id: entity.id,
            ballsPerOver: entity.balls_per_over,
            noBallPenalty: entity.no_ball_penalty,
            widePenalty: entity.wide_penalty,
            onlySingleBatter: entity.only_single_batter,
            lastWicketBatter: entity.last_wicket_batter,
            daysOfPlay: entity.days_of_play!,
            sessionsPerDay: entity.sessions_per_day!,
            inningsPerSide: entity.innings_per_side!,
          ),
        1 => LimitedOversRules(
            id: entity.id,
            ballsPerOver: entity.balls_per_over,
            noBallPenalty: entity.no_ball_penalty,
            widePenalty: entity.wide_penalty,
            onlySingleBatter: entity.only_single_batter,
            lastWicketBatter: entity.last_wicket_batter,
            oversPerInnings: entity.overs_per_innings!,
            oversPerBowler: entity.overs_per_bowler!,
          ),
        _ => throw UnsupportedError(
            "GameRules.type out of bounds (id: ${entity.id}, type: ${entity.type})"),
      };

  static int _gameRulesToInt(GameRules rules) => switch (rules) {
        UnlimitedOversRules() => 0,
        LimitedOversRules() => 1,
      };

  static MatchesEntity repackFriendly(CricketFriendly friendly) {
    final stage = friendly is CompletedCricketMatch ? 2 : 1;

    return MatchesEntity(
      id: friendly.id,
      type: 9,
      stage: stage,
      team1_id: "",
      team2_id: "",
      venue_id: "",
      starts_at: friendly.startsAt,
      rules_id: friendly.rules.id!,
    );
  }

  static MatchesEntity repackMatch(CricketMatch match) {
    if (match is CompletedCricketMatch) {
      final result = _DecipheredResult(match.result);
      return MatchesEntity(
        id: match.id,
        type: _gameRulesToInt(match.rules),
        stage: 4,
        team1_id: match.team1.id,
        team2_id: match.team2.id,
        venue_id: match.venue.id,
        starts_at: match.startsAt,
        rules_id: match.rules.id!,
        toss_winner_id: match.toss.winner.id,
        toss_choice: _tossChoiceToInt(match.toss.choice),
        result_type: result.type,
        result_winner_id: result.winnerId,
        result_loser_id: result.loserId,
        result_margin_1: result.margin1,
        result_margin_2: result.margin2,
        potm_id: match.playerOfTheMatch?.id,
      );
    } else if (match is OngoingCricketMatch) {
      return MatchesEntity(
        id: match.id,
        type: _gameRulesToInt(match.rules),
        stage: 3,
        team1_id: match.team1.id,
        team2_id: match.team2.id,
        venue_id: match.venue.id,
        starts_at: match.startsAt,
        rules_id: match.rules.id!,
        toss_winner_id: match.toss.winner.id,
        toss_choice: _tossChoiceToInt(match.toss.choice),
      );
    } else if (match is InitializedCricketMatch) {
      return MatchesEntity(
        id: match.id,
        type: _gameRulesToInt(match.rules),
        stage: 2,
        team1_id: match.team1.id,
        team2_id: match.team2.id,
        venue_id: match.venue.id,
        starts_at: match.startsAt,
        rules_id: match.rules.id!,
        toss_winner_id: match.toss.winner.id,
        toss_choice: _tossChoiceToInt(match.toss.choice),
      );
    } else if (match is ScheduledCricketMatch) {
      return MatchesEntity(
        id: match.id,
        type: _gameRulesToInt(match.rules),
        stage: 1,
        team1_id: match.team1.id,
        team2_id: match.team2.id,
        venue_id: match.venue.id,
        starts_at: match.startsAt,
        rules_id: match.rules.id!,
      );
    } else {
      throw UnsupportedError("Match of unknown type (id: ${match.id})");
    }
  }

  static CricketMatch unpackMatch(MatchesExpandedEntity entity) {
    final id = entity.matchesEntity.id;
    final stage = entity.matchesEntity.stage;

    if (stage < 1 || stage > 4) {
      throw UnsupportedError(
          "stage out of bounds (match_id: $id, stage: $stage)");
    }

    final team1 = unpackTeam(entity.team1Entity);
    final team2 = unpackTeam(entity.team2Entity);
    final venue = unpackVenue(entity.venueEntity);
    final rules = unpackGameRules(entity.gameRulesEntity);
    final startsAt = entity.matchesEntity.starts_at;

    final scheduledMatch = ScheduledCricketMatch(
      id: id,
      team1: team1,
      team2: team2,
      startsAt: startsAt,
      venue: venue,
      rules: rules,
    );

    if (stage == 1) {
      return scheduledMatch;
    }

    // InitializedCricketMatch

    // Parse Toss
    final tossWinnerId = entity.matchesEntity.toss_winner_id;
    final Team tossWinner =
        _tossWinner(tossWinnerId, team1: team1, team2: team2, matchId: id);
    final tossChoice =
        _intToTossChoice(entity.matchesEntity.toss_choice, matchId: id);
    final toss = Toss(choice: tossChoice, winner: tossWinner);

    // Parse Lineups
    // late final Lineup lineup1;
    // late final Lineup lineup2;

    if (stage == 2) {
      return InitializedCricketMatch(
        id: id,
        team1: team1,
        team2: team2,
        startsAt: startsAt,
        venue: venue,
        rules: rules,
        toss: toss,
      );
    }

    // final CricketGame game = await fetchGameFromId!(id);
    if (stage == 3) {
      return OngoingCricketMatch(
        id: id,
        team1: team1,
        team2: team2,
        startsAt: startsAt,
        venue: venue,
        rules: rules,
        toss: toss,
      );
    }

    assert(stage == 4);

    final resultWinnerId = entity.matchesEntity.result_winner_id;
    final resultLoserId = entity.matchesEntity.result_loser_id;

    final resultMargin1 = entity.matchesEntity.result_margin_1;
    final resultMargin2 = entity.matchesEntity.result_margin_2;
    final resultType = entity.matchesEntity.result_type;

    final result = switch (resultType) {
      0 => TieResult(
          team1: team1,
          team2: team2,
        ),
      1 => WinByDefendingResult(
          winner: resultWinnerId == team1.id
              ? team1
              : resultWinnerId == team2.id
                  ? team2
                  : throw UnsupportedError(
                      "result_winner_id out of bounds! (match_id: $id"),
          loser: resultLoserId == team1.id
              ? team1
              : resultLoserId == team2.id
                  ? team2
                  : throw UnsupportedError(
                      "result_loser_id out of bounds! (match_id: $id"),
          runsMargin: resultMargin1!,
        ),
      2 => WinByChasingResult(
          winner: resultWinnerId == team1.id
              ? team1
              : resultWinnerId == team2.id
                  ? team2
                  : throw UnsupportedError(
                      "result_winner_id out of bounds! (match_id: $id"),
          loser: resultLoserId == team1.id
              ? team1
              : resultLoserId == team2.id
                  ? team2
                  : throw UnsupportedError(
                      "result_loser_id out of bounds! (match_id: $id"),
          wicketsLeft: resultMargin1!,
          ballsToSpare: resultMargin2!,
        ),
      _ => throw UnsupportedError(
          "result_type out of bounds! (id: $id result_type: ${entity.matchesEntity.result_type})"),
    };

    return CompletedCricketMatch(
      id: id,
      team1: team1,
      team2: team2,
      startsAt: startsAt,
      venue: venue,
      rules: rules,
      toss: toss,
      result: result,
      playerOfTheMatch:
          null, // TODO find a solution for this, possible move to CricketGame
    );
  }

  static int _tossChoiceToInt(TossChoice choice) => switch (choice) {
        TossChoice.bat => 1,
        TossChoice.field => 0,
      };

  static TossChoice _intToTossChoice(int? choice, {required String matchId}) =>
      switch (choice) {
        1 => TossChoice.bat,
        0 => TossChoice.field,
        _ => throw UnsupportedError(
            "toss_choice out of bounds (match_id: $matchId, choice:$choice)")
      };

  static Team _tossWinner(tossWinnerId,
      {required Team team1, required Team team2, required String matchId}) {
    if (tossWinnerId == team1.id) {
      return team1;
    } else if (tossWinnerId == team2.id) {
      return team2;
    } else {
      throw UnsupportedError(
          "toss_winner out of bounds (match_id: $matchId, toss_winner_id: $tossWinnerId)");
    }
  }

  static List<PlayersInMatchEntity> repackLineup(
    Lineup lineup, {
    required String matchId,
    required String teamId,
    required String opponentTeamId,
    required bool isMatchCompleted,
    Map<Player, BatterInnings>? batters,
    Map<Player, BowlerInnings>? bowlers,
  }) =>
      lineup.players
          .map((player) => PlayersInMatchEntity(
                match_id: matchId,
                team_id: teamId,
                player_id: player.id,
                is_captain: lineup.captain == player,
                opponent_team_id: opponentTeamId,
                is_match_completed: isMatchCompleted,
                batter_number: batters != null
                    ? batters.keys.toList().indexOf(player) + 1
                    : null,
                runs_scored: batters?[player]?.runsScored,
                balls_faced: batters?[player]?.ballsFaced,
                is_out: batters?[player]?.isOut,
                is_retired: batters?[player]?.isRetired,
                strike_rate: batters?[player]?.strikeRate,
                runs_conceded: bowlers?[player]?.runsConceded,
                wickets_taken: bowlers?[player]?.wicketsTaken,
                maidens_bowled: bowlers?[player]?.maidensBowled,
                balls_bowled: bowlers?[player]?.ballsBowled,
                economy: bowlers?[player]?.economy,
              ))
          .toList();

  static List<Lineup> unpackLineups(
    Iterable<LineupsExpandedEntity> lineupsExpandedEntities, {
    required String matchId,
    required String team1Id,
    required String team2Id,
  }) {
    final players1 = <Player>[];
    Player? captain1;
    final players2 = <Player>[];
    Player? captain2;

    for (final entity in lineupsExpandedEntities) {
      if (entity.lineupsEntity.team_id == team1Id) {
        final player = unpackPlayer(entity.playersEntity);
        players1.add(player);
        if (entity.lineupsEntity.is_captain) {
          captain1 = player;
        }
      } else if (entity.lineupsEntity.team_id == team2Id) {
        final player = unpackPlayer(entity.playersEntity);
        players2.add(player);
        if (entity.lineupsEntity.is_captain) {
          captain2 = player;
        }
      }
    }

    return [
      Lineup(players: players1, captain: captain1!),
      Lineup(players: players2, captain: captain2!)
    ];
  }

  static InningsEntity repackInnings(Innings innings) => InningsEntity(
        match_id: innings.matchId,
        innings_number: innings.inningsNumber,
        type: _inningsType(innings),
        batting_team_id: innings.battingTeam.id,
        bowling_team_id: innings.bowlingTeam.id,
        is_forfeited: innings.isForfeited,
        is_declared: innings.isDeclared,
        batter1_id: innings.batter1?.player.id,
        batter2_id: innings.batter2?.player.id,
        striker_id: innings.striker?.player.id,
        bowler_id: innings.bowler?.player.id,
        target_runs:
            innings is SecondLimitedOversInnings ? innings.target : null,
      );

  static int _inningsType(Innings innings) => switch (innings) {
        UnlimitedOversInnings() => 10,
        FirstLimitedOversInnings() => 21,
        SecondLimitedOversInnings() => 22,
      };

  static Innings unpackInnings(
    InningsEntity inningsEntity, {
    // required Team team1,
    // required Lineup lineup1,
    // required Team team2,
    // required Lineup lineup2,
    required GameRules rules,
    required Map<String, Team> teamMap,
    required Map<Team, Lineup> lineupMap,
  }) {
    final Team battingTeam = teamMap[inningsEntity.batting_team_id]!;
    final Lineup battingLineup = lineupMap[battingTeam]!;
    final Team bowlingTeam = teamMap[inningsEntity.bowling_team_id]!;
    final Lineup bowlingLineup = lineupMap[bowlingTeam]!;

    final innings = switch (inningsEntity.type) {
      10 => UnlimitedOversInnings(
          matchId: inningsEntity.match_id,
          inningsNumber: inningsEntity.innings_number,
          battingTeam: battingTeam,
          battingLineup: battingLineup,
          bowlingTeam: bowlingTeam,
          bowlingLineup: bowlingLineup,
          rules: rules as UnlimitedOversRules,
        ),
      21 => FirstLimitedOversInnings(
          matchId: inningsEntity.match_id,
          inningsNumber: inningsEntity.innings_number,
          battingTeam: battingTeam,
          battingLineup: battingLineup,
          bowlingTeam: bowlingTeam,
          bowlingLineup: bowlingLineup,
          rules: rules as LimitedOversRules,
        ),
      22 => SecondLimitedOversInnings(
          matchId: inningsEntity.match_id,
          inningsNumber: inningsEntity.innings_number,
          battingTeam: battingTeam,
          battingLineup: battingLineup,
          bowlingTeam: bowlingTeam,
          bowlingLineup: bowlingLineup,
          rules: rules as LimitedOversRules,
          target: inningsEntity.target_runs!,
        ),
      _ => throw UnsupportedError(
          "innings.type not in bounds (match_id: ${inningsEntity.match_id})"),
    };

    return innings;
  }

  static PostsEntity repackLimitedOversPost(InningsPost post,
          {required String matchId, required int inningsNumber}) =>
      switch (post) {
        Ball() => PostsEntity(
            id: post.id,
            match_id: matchId,
            innings_number: inningsNumber,
            index_over: post.index.over,
            index_ball: post.index.ball,
            timestamp: post.timestamp,
            type: 0,
            bowler_id: post.bowler.id,
            batter_id: post.batter.id,
            runs_scored: post.runsScoredByBatter,
            wicket_type: _wicketTypeToInt(post.wicket),
            wicket_batter_id: post.wicket?.batter.id,
            wicket_fielder_id: post.wicket is FielderWicket
                ? (post.wicket as FielderWicket).fielder.id
                : null,
            bowling_extra_type: _bowlingExtraTypeToInt(post.bowlingExtra),
            bowling_extra_penalty: post.bowlingExtraRuns,
            batting_extra_type: _battingExtraType(post.battingExtra),
            batting_extra_runs: post.battingExtraRuns,
            comment: post.comment,
          ),
        BowlerRetire() => PostsEntity(
            id: post.id,
            match_id: matchId,
            innings_number: inningsNumber,
            index_over: post.index.over,
            index_ball: post.index.ball,
            timestamp: post.timestamp,
            type: 1,
            bowler_id: post.bowler.id,
            comment: post.comment,
          ),
        NextBowler() => PostsEntity(
            id: post.id,
            match_id: matchId,
            innings_number: inningsNumber,
            index_over: post.index.over,
            index_ball: post.index.ball,
            timestamp: post.timestamp,
            type: 2,
            bowler_id: post.next.id,
            wicket_fielder_id: post.previous?.id,
            comment: post.comment,
          ),
        BatterRetire() => PostsEntity(
            id: post.id,
            match_id: matchId,
            innings_number: inningsNumber,
            index_over: post.index.over,
            index_ball: post.index.ball,
            timestamp: post.timestamp,
            type: 3,
            wicket_batter_id: post.retired.batter.id,
            wicket_type: _retiredTypeToInt(post.retired),
            comment: post.comment,
          ),
        NextBatter() => PostsEntity(
            id: post.id,
            match_id: matchId,
            innings_number: inningsNumber,
            index_over: post.index.over,
            index_ball: post.index.ball,
            timestamp: post.timestamp,
            type: 4,
            batter_id: post.next.id,
            wicket_batter_id: post.previous?.id,
            comment: post.comment,
          ),
        RunoutBeforeDelivery() => PostsEntity(
            id: post.id,
            match_id: matchId,
            innings_number: inningsNumber,
            index_over: post.index.over,
            index_ball: post.index.ball,
            timestamp: post.timestamp,
            type: 5,
            wicket_type: _wicketTypeToInt(post.wicket),
            wicket_batter_id: post.wicket.batter.id,
            wicket_fielder_id: post.wicket.fielder.id,
            comment: post.comment,
          ),
      };

  static int? _bowlingExtraTypeToInt(BowlingExtra? bowlingExtra) =>
      switch (bowlingExtra) {
        null => null,
        Wide() => 0,
        NoBall() => 1,
      };

  static BowlingExtra? _decipherBowlingExtra(int? extra, int? penalty) =>
      switch (extra) {
        0 => Wide(penalty!),
        1 => NoBall(penalty!),
        null => null,
        _ => throw UnsupportedError("bowling_extra_type out of bounds!"),
      };

  static int? _battingExtraType(BattingExtra? battingExtra) =>
      switch (battingExtra) {
        null => null,
        Bye() => 0,
        LegBye() => 1,
      };

  static BattingExtra? _decipherBattingExtra(int? extra, int? runs) =>
      switch (extra) {
        0 => Bye(runs!),
        1 => LegBye(runs!),
        null => null,
        _ => throw UnsupportedError("batting_extra_type out of bounds!"),
      };

  static int? _retiredTypeToInt(Retired retired) => switch (retired) {
        RetiredDeclared() => 0,
        RetiredHurt() => 1,
      };

  static Retired _decipherRetired(
          PostsEntity entity, Map<String, Player> playerMap) =>
      switch (entity.wicket_type) {
        0 => RetiredDeclared(batter: playerMap[entity.wicket_batter_id]!),
        1 => RetiredHurt(batter: playerMap[entity.wicket_batter_id]!),
        // null => null,
        _ => throw UnsupportedError(
            "retired_type (stored in wicket_type) out of bounds! (id: ${entity.id}, wicket_type: ${entity.wicket_type})")
      };

  static int? _wicketTypeToInt(Wicket? wicket) => switch (wicket) {
        BowledWicket() => 0,
        HitWicket() => 1,
        LbwWicket() => 2,
        CaughtWicket() => 3,
        StumpedWicket() => 4,
        RunoutWicket() => 5,
        TimedOutWicket() => 6,
        null => null,
      };

  static Wicket? _decipherWicket(
          PostsEntity entity, Map<String, Player> playerMap) =>
      switch (entity.wicket_type) {
        0 => BowledWicket(
            batter: playerMap[entity.wicket_batter_id]!,
            bowler: playerMap[entity.bowler_id]!,
          ),
        1 => HitWicket(
            batter: playerMap[entity.wicket_batter_id]!,
            bowler: playerMap[entity.bowler_id]!,
          ),
        2 => LbwWicket(
            batter: playerMap[entity.wicket_batter_id]!,
            bowler: playerMap[entity.bowler_id]!,
          ),
        3 => CaughtWicket(
            batter: playerMap[entity.wicket_batter_id]!,
            bowler: playerMap[entity.bowler_id]!,
            fielder: playerMap[entity.wicket_fielder_id]!),
        4 => StumpedWicket(
            batter: playerMap[entity.wicket_batter_id]!,
            bowler: playerMap[entity.bowler_id]!,
            wicketkeeper: playerMap[entity.wicket_fielder_id]!),
        5 => RunoutWicket(
            batter: playerMap[entity.wicket_batter_id]!,
            fielder: playerMap[entity.wicket_fielder_id]!),
        6 => TimedOutWicket(batter: playerMap[entity.wicket_batter_id]!),
        null => null,
        _ => throw UnsupportedError(
            "wicket_type out of bounds! (id: ${entity.id}, wicket_type: ${entity.wicket_type})"),
      };

  static InningsPost unpackLimitedOversPost(
    PostsEntity entity, {
    required Map<String, Player> playerMap,
  }) =>
      switch (entity.type) {
        0 => Ball(
            id: entity.id,
            index: PostIndex(entity.index_over, entity.index_ball),
            timestamp: entity.timestamp,
            comment: entity.comment,
            bowler: playerMap[entity.bowler_id]!,
            batter: playerMap[entity.batter_id]!,
            runsScoredByBatter: entity.runs_scored!,
            wicket: _decipherWicket(entity, playerMap),
            bowlingExtra: _decipherBowlingExtra(
                entity.bowling_extra_type, entity.bowling_extra_penalty),
            battingExtra: _decipherBattingExtra(
                entity.batting_extra_type, entity.batting_extra_runs),
          ),
        1 => BowlerRetire(
            id: entity.id,
            index: PostIndex(entity.index_over, entity.index_ball),
            timestamp: entity.timestamp,
            comment: entity.comment,
            bowler: playerMap[entity.bowler_id]!,
          ),
        2 => NextBowler(
            id: entity.id,
            index: PostIndex(entity.index_over, entity.index_ball),
            timestamp: entity.timestamp,
            comment: entity.comment,
            next: playerMap[entity.bowler_id]!,
            previous: playerMap[entity.wicket_fielder_id],
          ),
        3 => BatterRetire(
            id: entity.id,
            index: PostIndex(entity.index_over, entity.index_ball),
            timestamp: entity.timestamp,
            comment: entity.comment,
            retired: _decipherRetired(entity, playerMap),
          ),
        4 => NextBatter(
            id: entity.id,
            index: PostIndex(entity.index_over, entity.index_ball),
            timestamp: entity.timestamp,
            comment: entity.comment,
            next: playerMap[entity.batter_id]!,
            previous: playerMap[entity.wicket_batter_id],
          ),
        5 => RunoutBeforeDelivery(
            id: entity.id,
            index: PostIndex(entity.index_over, entity.index_ball),
            timestamp: entity.timestamp,
            comment: entity.comment,
            wicket: _decipherWicket(entity, playerMap) as RunoutWicket,
          ),
        _ =>
          throw UnsupportedError("posts.type out of bounds! (id:${entity.id})"),
      };
}

class _DecipheredResult {
  final int type;
  final String? winnerId;
  final String? loserId;
  final int margin1;
  final int? margin2;

  _DecipheredResult._(
      {required this.type,
      required this.winnerId,
      required this.loserId,
      required this.margin1,
      required this.margin2});

  factory _DecipheredResult(CricketMatchResult result) => switch (result) {
        TieResult() => _DecipheredResult._(
            type: 0,
            winnerId: null,
            loserId: null,
            margin1: 0,
            margin2: null,
          ),
        WinByDefendingResult() => _DecipheredResult._(
            type: 1,
            winnerId: result.winner.id,
            loserId: result.loser.id,
            margin1: result.runsMargin,
            margin2: null,
          ),
        WinByChasingResult() => _DecipheredResult._(
            type: 2,
            winnerId: result.winner.id,
            loserId: result.loser.id,
            margin1: result.wicketsLeft,
            margin2: result.ballsToSpare,
          ),
      };
}
