CREATE TABLE players (id TEXT PRIMARY KEY,
                      name TEXT NOT NULL,
                      full_name TEXT);

CREATE TABLE teams (id TEXT PRIMARY KEY,
                    name TEXT NOT NULL,
                    short TEXT NOT NULL,
                    color INTEGER);

CREATE TABLE venues (id TEXT PRIMARY KEY, name TEXT);

CREATE TABLE game_rules (id INTEGER PRIMARY KEY,
                        type INTEGER,
                        balls_per_over INTEGER,
                        no_ball_penalty INTEGER,
                        wide_penalty INTEGER,
                        only_single_batter BOOLEAN,
                        last_wicket_batter BOOLEAN,
                        days_of_play INTEGER,
                        sessions_per_day INTEGER,
                        innings_per_side INTEGER,
                        overs_per_innings INTEGER,
                        overs_per_bowler INTEGER);

CREATE TABLE matches (id TEXT PRIMARY KEY,
                      type INTEGER NOT NULL,
                      stage INTEGER NOT NULL,
                      team1_id TEXT NOT NULL REFERENCES teams (id),
                      team2_id TEXT NOT NULL REFERENCES teams (id),
                      venue_id TEXT NOT NULL REFERENCES venues (id),
                      starts_at DATETIME NOT NULL,
                      rules_id INTEGER NOT NULL REFERENCES game_rules (id),
                      toss_winner_id TEXT REFERENCES teams (id),
                      toss_choice INTEGER,
                      result_type INTEGER,
                      result_winner_id TEXT REFERENCES teams (id),
                      result_loser_id TEXT REFERENCES teams (id),
                      result_margin_1 INTEGER,
                      result_margin_2 INTEGER,
                      potm_id TEXT REFERENCES teams (id));

CREATE VIEW matches_expanded AS
SELECT m.id, m.type, m.stage, m.starts_at,
		m.toss_winner_id, m.toss_choice,
		m.result_type, m.result_winner_id, m.result_loser_id, m.result_margin_1, m.result_margin_2, m.potm_id,
        m.venue_id as venue_id, v.name AS venue_name,
        gr.id as rules_id, gr.type as rules_type, gr.balls_per_over as rules_balls_per_over,
        	gr.no_ball_penalty AS rules_no_ball_penalty, gr.wide_penalty AS rules_wide_penalty,
            gr.only_single_batter AS rules_only_single_batter, gr.last_wicket_batter AS rules_last_wicket_batter,
            gr.days_of_play AS rules_days_of_play, gr.sessions_per_day AS rules_session_per_day, gr.innings_per_side AS rules_innings_per_side,
            gr.overs_per_innings AS rules_overs_per_innings, gr.overs_per_bowler AS rules_overs_per_bowler,
        t1.id as team1_id, t1.name as team1_name, t1.short as team1_short, t1.color AS team1_color,
 		t2.id as team2_id, t2.name as team2_name, t2.short as team2_short, t2.color AS team2_color
        FROM matches m
        JOIN venues v on m.venue_id = v.id
        JOIN game_rules gr on m.rules_id = gr.id
        JOIN teams t1 on m.team1_id = t1.id
        JOIN teams t2 on m.team2_id = t2.id;

CREATE TABLE players_in_match (match_id TEXT NOT NULL REFERENCES matches (id),
                      team_id TEXT NOT NULL REFERENCES teams (id),
                      player_id TEXT NOT NULL REFERENCES players (id),
                      is_captain BOOLEAN NOT NULL,
                      opponent_team_id TEXT NOT NULL REFERENCES teams (id),
                      is_match_completed BOOLEAN DEFAULT FALSE,
                      -- Batting
                      batter_number INTEGER,
                      runs_scored INTEGER,
                      balls_faced INTEGER,
                      is_out BOOLEAN,
                      is_retired BOOLEAN,
                      strike_rate DOUBLE,
                      -- Bowling
                      runs_conceded INTEGER,
                      wickets_taken DOUBLE,
                      maidens_bowled INTEGER,
                      balls_bowled INTEGER,
                      economy DOUBLE,
                      PRIMARY KEY (match_id, team_id, player_id));

CREATE VIEW lineups AS
SELECT match_id, team_id, player_id, is_captain, opponent_team_id, name, full_name
FROM players_in_match
JOIN players WHERE players_in_match.player_id = players.id;

CREATE TABLE innings (match_id TEXT NOT NULL REFERENCES matches (id),
                      innings_number INTEGER NOT NULL,
                      type INTEGER NOT NULL,
                      batting_team_id TEXT NOT NULL REFERENCES teams (id),
                      bowling_team_id TEXT NOT NULL REFERENCES teams (id),
                      is_forfeited BOOLEAN NOT NULL,
                      is_declared BOOLEAN NOT NULL,
                      batter1_id TEXT REFERENCES players (id),
                      batter2_id TEXT REFERENCES players (id),
                      striker_id TEXT REFERENCES players (id),
                      bowler_id TEXT REFERENCES players (id),
                      target_runs INTEGER,
                      PRIMARY KEY (match_id, innings_number));

CREATE TABLE posts (id INTEGER PRIMARY KEY,
                    match_id TEXT NOT NULL,
                    innings_number INTEGER NOT NULL,
                    day_number INTEGER,
                    session_number INTEGER,
                    index_over INTEGER NOT NULL,
                    index_ball INTEGER NOT NULL,
               		timestamp DATETIME NOT NULL,
                    type INTEGER NOT NULL,
                    bowler_id TEXT REFERENCES players (id),
                    batter_id TEXT REFERENCES players (id),
                    runs_scored INTEGER,
                    bowling_extra_type INTEGER,
                    bowling_extra_penalty INTEGER,
                    batting_extra_type INTEGER,
                    batting_extra_runs INTEGER,
                    wicket_type INTEGER,
                    wicket_batter_id TEXT REFERENCES players (id),
                    wicket_fielder_id TEXT REFERENCES players (id),
                    comment TEXT,
                    FOREIGN KEY (match_id, innings_number) REFERENCES innings (match_id, innings_number));

CREATE VIEW balls AS SELECT id, match_id, innings_number, day_number, session_number, index_over, index_ball, timestamp,
                            bowler_id, batter_id, runs_scored,
                            bowling_extra_type, bowling_extra_penalty, batting_extra_type, batting_extra_runs,
                            wicket_type, wicket_batter_id, wicket_bowler_id, wicket_fielder_id
                            FROM posts WHERE type = 0;