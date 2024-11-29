import 'package:scorecard/modules/cricket_match/models/cricket_match_model.dart';
import 'package:scorecard/modules/cricket_match/models/cricket_match_rules_model.dart';
import 'package:scorecard/modules/cricket_match/models/innings_model.dart';
import 'package:scorecard/modules/cricket_match/models/wicket_model.dart';
import 'package:scorecard/modules/player/player_model.dart';
import 'package:scorecard/modules/team/models/team_model.dart';
import 'package:scorecard/modules/venue/models/venue_model.dart';
import 'package:scorecard/repositories/sql/db/game_rules_table.dart';
import 'package:scorecard/repositories/sql/db/innings_table.dart';
import 'package:scorecard/repositories/sql/db/lineups_expanded_view.dart';
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
            allow_last_man: rules.allowLastMan,
            days_of_play: rules.daysOfPlay,
            sessions_per_day: rules.sessionsPerDay,
            innings_per_side: rules.inningsPerSide,
          ),
        // TODO: Handle this case.
        LimitedOversRules() => GameRulesEntity(
            id: rules.id,
            type: _gameRulesToInt(rules),
            balls_per_over: rules.ballsPerOver,
            no_ball_penalty: rules.noBallPenalty,
            wide_penalty: rules.widePenalty,
            only_single_batter: rules.onlySingleBatter,
            allow_last_man: rules.allowLastMan,
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
            allowLastMan: entity.allow_last_man,
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
            allowLastMan: entity.allow_last_man,
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

  static MatchesEntity repackMatch(CricketMatch match) {
    if (match is CompletedCricketMatch) {
      return MatchesEntity(
        id: match.id,
        type: _gameRulesToInt(match.rules),
        stage: 4,
        team1_id: match.team1.id,
        team2_id: match.team2.id,
        venue_id: match.venue.id,
        starts_at: match.startsAt,
        game_rules_id: match.rules.id!,
        toss_winner_id: match.toss.winner.id,
        toss_choice: _tossChoiceToInt(match.toss.choice),
        result_type: null,
        result_winner_id: null,
        result_loser_id: null,
        result_margin_1: null,
        result_margin_2: null,
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
        game_rules_id: match.rules.id!,
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
        game_rules_id: match.rules.id!,
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
        game_rules_id: match.rules.id!,
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

    if (stage == 1) {
      return ScheduledCricketMatch(
        id: id,
        team1: team1,
        team2: team2,
        startsAt: startsAt,
        venue: venue,
        rules: rules,
      );
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

    // TODO
    throw UnimplementedError("CompletedCricketMatch");
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

  static InningsEntity repackInnings(Innings innings,
          {required String matchId}) =>
      InningsEntity(
        match_id: matchId,
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
        target_runs: innings.target,
      );

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
      0 => UnlimitedOversInnings(
          inningsNumber: inningsEntity.innings_number,
          battingTeam: battingTeam,
          battingLineup: battingLineup,
          bowlingTeam: bowlingTeam,
          bowlingLineup: bowlingLineup,
          rules: rules as UnlimitedOversRules,
        ),
      1 => LimitedOversInnings(
          inningsNumber: inningsEntity.innings_number,
          battingTeam: battingTeam,
          battingLineup: battingLineup,
          bowlingTeam: bowlingTeam,
          bowlingLineup: bowlingLineup,
          rules: rules as LimitedOversRules,
        ),
      _ => throw UnsupportedError(
          "innings.type not in bounds (match_id: ${inningsEntity.match_id})"),
    };

    return innings;
  }

  static int _inningsType(Innings innings) => switch (innings) {
        UnlimitedOversInnings() => 0,
        LimitedOversInnings() => 1,
      };

  static PostsEntity repackLimitedOversPost(InningsPost post,
          {required String matchId, required int inningsNumber, int? id}) =>
      switch (post) {
        Ball() => PostsEntity(
            id: id,
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
            wicket_bowler_id: post.wicket?.bowler?.id,
            wicket_fielder_id: post.wicket?.fielder.id,
            bowling_extra_type: _bowlingExtraTypeToInt(post.bowlingExtra),
            bowling_extra_penalty: post.bowlingExtraRuns,
            batting_extra_type: _battingExtraType(post.battingExtra),
            batting_extra_runs: post.battingExtraRuns,
            comment: post.comment,
          ),
        BowlerRetire() => PostsEntity(
            id: id,
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
            id: id,
            match_id: matchId,
            innings_number: inningsNumber,
            index_over: post.index.over,
            index_ball: post.index.ball,
            timestamp: post.timestamp,
            type: 2,
            bowler_id: post.next.id,
            previous_player_id: post.previous?.id,
            comment: post.comment,
          ),
        BatterRetire() => PostsEntity(
            id: id,
            match_id: matchId,
            innings_number: inningsNumber,
            index_over: post.index.over,
            index_ball: post.index.ball,
            timestamp: post.timestamp,
            type: 3,
            batter_id: post.retired.batter.id,
            comment: post.comment,
          ),
        NextBatter() => PostsEntity(
            id: id,
            match_id: matchId,
            innings_number: inningsNumber,
            index_over: post.index.over,
            index_ball: post.index.ball,
            timestamp: post.timestamp,
            type: 4,
            batter_id: post.next.id,
            previous_player_id: post.previous?.id,
            comment: post.comment,
          ),
        RunoutBeforeDelivery() => PostsEntity(
            id: id,
            match_id: matchId,
            innings_number: inningsNumber,
            index_over: post.index.over,
            index_ball: post.index.ball,
            timestamp: post.timestamp,
            type: 5,
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
        _ => throw UnsupportedError("batting_extra_type out of bounds!"),
      };

  static int? _wicketTypeToInt(Wicket? wicket) => switch (wicket) {
        null => null,
        BowledWicket() => 0,
        HitWicket() => 1,
        LbwWicket() => 2,
        CaughtWicket() => 3,
        StumpedWicket() => 4,
        RunoutWicket() => 5,
        TimedOutWicket() => 6,
      };

  static InningsPost unpackLimitedOversPost(
    PostsEntity entity, {
    required Map<String, Player> players,
  }) =>
      switch (entity.type) {
        0 => Ball(
            index: PostIndex(entity.index_over, entity.index_ball),
            timestamp: entity.timestamp,
            comment: entity.comment,
            bowler: players[entity.bowler_id]!,
            batter: players[entity.batter_id]!,
            runsScoredByBatter: entity.runs_scored!,
            wicket: wickets[entity.wicket_id],
            bowlingExtra: _decipherBowlingExtra(
                entity.bowling_extra_type, entity.bowling_extra_penalty),
            battingExtra: _decipherBattingExtra(
                entity.batting_extra_type, entity.batting_extra_runs),
          ),
        1 => BowlerRetire(
            index: PostIndex(entity.index_over, entity.index_ball),
            timestamp: entity.timestamp,
            comment: entity.comment,
            bowler: players[entity.bowler_id]!,
          ),
        2 => NextBowler(
            index: PostIndex(entity.index_over, entity.index_ball),
            timestamp: entity.timestamp,
            comment: entity.comment,
            next: players[entity.bowler_id]!,
            previous: players[entity.previous_player_id],
          ),
        3 => BatterRetire(
            index: PostIndex(entity.index_over, entity.index_ball),
            timestamp: entity.timestamp,
            comment: entity.comment,
            retired: Ret,
          ),
        4 => NextBatter(
            index: PostIndex(entity.index_over, entity.index_ball),
            timestamp: entity.timestamp,
            comment: entity.comment,
            previous: players[entity.previous_player_id]!,
            next: players[entity.batter_id]!,
          ),
        5 => RunoutBeforeDelivery(
            index: PostIndex(entity.index_over, entity.index_ball),
            timestamp: entity.timestamp,
            comment: entity.comment,
            wicket: wickets[entity.wicket_id]! as RunoutWicket,
          ),
        _ =>
          throw UnsupportedError("posts.type out of bounds! (id:${entity.id})"),
      };
}
