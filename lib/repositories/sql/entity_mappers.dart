import 'package:scorecard/modules/cricket_match/models/cricket_match_model.dart';
import 'package:scorecard/modules/cricket_match/models/cricket_match_rules_model.dart';
import 'package:scorecard/modules/cricket_match/models/innings_model.dart';
import 'package:scorecard/modules/player/player_model.dart';
import 'package:scorecard/modules/team/models/team_model.dart';
import 'package:scorecard/modules/venue/models/venue_model.dart';
import 'package:scorecard/repositories/sql/db/game_rules_table.dart';
import 'package:scorecard/repositories/sql/db/innings_table.dart';
import 'package:scorecard/repositories/sql/db/lineups_table.dart';
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
            "GameRules.type out of bounds (id: ${entity.id}, type: ${entity.type}"),
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
      throw UnsupportedError("Match of unknown type (id: ${match.id}");
    }
  }

  Future<CricketMatch> unpackMatch(MatchesExpandedEntity entity) async {
    final id = entity.matchesEntity.id;
    final stage = entity.matchesEntity.stage;

    if (stage < 1 || stage > 4) {
      throw UnsupportedError(
          "stage out of bounds (match_id: $id, stage: $stage");
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
            "toss_choice out of bounds (match_id: $matchId, choice:$choice")
      };

  static Team _tossWinner(tossWinnerId,
      {required Team team1, required Team team2, required String matchId}) {
    if (tossWinnerId == team1.id) {
      return team1;
    } else if (tossWinnerId == team2.id) {
      return team2;
    } else {
      throw UnsupportedError(
          "toss_winner out of bounds (match_id: $matchId, toss_winner_id: $tossWinnerId");
    }
  }

  static List<LineupsEntity> lineup(
    Lineup lineup, {
    required String matchId,
    required String teamId,
  }) =>
      lineup.players
          .map((player) => LineupsEntity(
                match_id: matchId,
                team_id: teamId,
                player_id: player.id,
                is_captain: lineup.captain == player,
              ))
          .toList();

  static InningsEntity innings(Innings innings,
          {required String matchId, required int inningsNumber}) =>
      InningsEntity(
        match_id: matchId,
        innings_number: inningsNumber,
        type: _inningsType(innings),
        batting_team_id: innings.battingTeam.id,
        bowling_team_id: innings.bowlingTeam.id,
        is_forfeited: innings.isForfeited,
        is_declared: innings.isDeclared,
        batter1_id: innings.batter1?.player.id,
        batter2_id: innings.batter2?.player.id,
        bowler_id: innings.bowler?.player.id,
        target_runs: innings.target,
      );

  static int _inningsType(Innings innings) => switch (innings) {
        UnlimitedOversInnings() => 0,
        LimitedOversInnings() => 1,
      };

  static PostsEntity limitedOversPost(InningsPost post,
          {required String matchId,
          required int inningsNumber,
          int? id,
          int? wicketId}) =>
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
            wicket_id: wicketId,
            bowling_extra_type: _bowlingExtraType(post.bowlingExtra),
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
            wicket_id: wicketId,
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
            wicket_id: wicketId,
            comment: post.comment,
          ),
      };

  static int? _bowlingExtraType(BowlingExtra? bowlingExtra) =>
      switch (bowlingExtra) {
        null => null,
        Wide() => 0,
        NoBall() => 1,
      };

  static int? _battingExtraType(BattingExtra? battingExtra) =>
      switch (battingExtra) {
        null => null,
        Bye() => 0,
        LegBye() => 1,
      };
}
