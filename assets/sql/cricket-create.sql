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
                        allow_last_man BOOLEAN,
                        days_of_play INTEGER,
                        sessions_per_day INTEGER,
                        innings_per_side INTEGER,
                        overs_per_innings INTEGER,
                        overs_per_bowler INTEGER);

CREATE TABLE matches (id TEXT PRIMARY KEY,
                      stage INTEGER NOT NULL,
                      team1_id TEXT NOT NULL,
                      team2_id TEXT NOT NULL,
                      venue_id TEXT NOT NULL,
                      starts_at DATETIME NOT NULL,
                      game_rules_id INTEGER NOT NULL,
                      game_rules_type INTEGER NOT NULL,
                      toss_winner_id TEXT,
                      toss_choice INTEGER,
                      result_type INTEGER,
                      result_winner_id TEXT,
                      result_loser_id TEXT,
                      result_margin_1 INTEGER,
                      result_margin_2 INTEGER,
                      potm_id TEXT,
                      FOREIGN KEY (team1_id) references teams (id),
                      FOREIGN KEY (team2_id) references teams (id),
                      FOREIGN KEY (venue_id) REFERENCES venues (id),
                      FOREIGN KEY (game_rules_id, game_rules_type) REFERENCES game_rules (id, type),
                      FOREIGN KEY (toss_winner_id) REFERENCES teams (id),
                      FOREIGN KEY (result_winner_id) REFERENCES teams (id),
                      FOREIGN KEY (result_loser_id) REFERENCES teams (id),
                      FOREIGN KEY (potm_id) REFERENCES players (id));

create view matches_expanded AS
select m.id, m.stage, m.starts_at,
		m.toss_winner_id, m.toss_choice,
		m.result_type, m.result_winner_id, m.result_loser_id, m.result_margin_1, m.result_margin_2, m.potm_id,
        m.venue_id as venue_id, v.name AS venue_name,
        gr.type as rules_type, gr.balls_per_over as rules_balls_per_over,
        	gr.no_ball_penalty AS rules_no_ball_penalty, gr.wide_penalty AS rules_wide_penalty,
            gr.only_single_batter AS rules_only_single_batter, gr.allow_last_man AS rules_allow_last_man,
            gr.days_of_play AS rules_days_of_play, gr.sessions_per_day AS rules_session_per_day, gr.innings_per_side AS rules_innings_per_side,
            gr.overs_per_innings AS rules_overs_per_innings, gr.overs_per_bowler AS rules_overs_per_bowler,
        t1.id as team1_id, t1.name as team1_name, t1.short as team1_short, t1.color AS team1_color,
 		t2.id as team2_id, t2.name as team2_name, t2.short as team2_short, t2.color AS team2_color
        FROM matches m
        JOIN venues v on m.venue_id = v.id
        JOIN game_rules gr on m.game_rules_id = gr.id
        JOIN teams t1 on m.team1_id = t1.id
        JOIN teams t2 on m.team2_id = t2.id;

CREATE TABLE lineups (match_id TEXT NOT NULL,
                      team_id TEXT NOT NULL,
                      player_id TEXT NOT NULL,
                      is_captain BOOLEAN NOT NULL,
                      PRIMARY KEY (match_id, team_id, player_id),
                      FOREIGN KEY (match_id) REFERENCES matches (id),
                      FOREIGN KEY (team_id) REFERENCES teams (id),
                      FOREIGN KEY (player_id) REFERENCES players (id));

CREATE TABLE innings (match_id TEXT NOT NULL,
                      innings_number INTEGER NOT NULL,
                      type INTEGER NOT NULL,
                      batting_team_id TEXT NOT NULL,
                      bowling_team_id TEXT NOT NULL,
--                      game_rules_id TEXT NOT NULL,
                      is_forfeited BOOLEAN NOT NULL,
                      is_declared BOOLEAN NOT NULL,
                      batter1_id TEXT,
                      batter2_id TEXT,
                      bowler_id TEXT,
                      target_runs INTEGER,
                      PRIMARY KEY (match_id, innings_number)
                      FOREIGN KEY (match_id) REFERENCES matches(id),
                      FOREIGN KEY (batting_team_id) REFERENCES team (id),
                      FOREIGN KEY (bowling_team_id) REFERENCES team (id),
                      FOREIGN KEY (batter1_id) REFERENCES players (id),
                      FOREIGN KEY (batter2_id) REFERENCES players (id),
                      FOREIGN KEY (bowler_id) REFERENCES players (id));

--CREATE TABLE batter_innings (id INTEGER PRIMARY KEY,
--                             player_id TEXT NOT NULL,
--  							 match_id TEXT NOT NULL,
--                             innings_number INTEGER NOT NULL,
--                             day_number INTEGER,
--                             session_number INTEGER,
--                             runs_scored INTEGER,
--                             balls_faced INTEGER,
--                             FOREIGN KEY (player_id) REFERENCES players (id),
--                             FOREIGN KEY (match_id, innings_number) REFERENCES innings (match_id, innings_number));
--
-- select batter_id, SUM(balls.runs_scored) as total_runs FROM balls GROUP BY batter_id;

--CREATE TABLE bowler_innings (id INTEGER PRIMARY KEY,
--                             player_id TEXT NOT NULL,
--  							 match_id TEXT NOT NULL,
--                             innings_number INTEGER NOT NULL,
--                             day_number INTEGER,
--                             session_number INTEGER,
--                             runs_conceded INTEGER,
--                             maidens INTEGER,
--                             wickets INTEGER,
--                             balls_bowled INTEGER,
--                             FOREIGN KEY (player_id) REFERENCES players (id)
--                             FOREIGN KEY (match_id, innings_number) REFERENCES innings (match_id, innings_number));

CREATE TABLE wickets (id INTEGER PRIMARY KEY,
                      match_id TEXT NOT NULL,
                      innings_number INTEGER NOT NULL,
                      day_number INTEGER,
                      session_number INTEGER,
					  type INTEGER NOT NULL,
                      batter_id TEXT NOT NULL,
                      bowler_id TEXT,
                      fielder_id TEXT,
                      FOREIGN KEY (match_id, innings_number) REFERENCES innings(match_id, innings_number));

CREATE TABLE posts (id INTEGER PRIMARY KEY,
                    match_id TEXT NOT NULL,
                    innings_number INTEGER NOT NULL,
                    day_number INTEGER,
                    session_number INTEGER,
                    index_over INTEGER NOT NULL,
                    index_ball INTEGER NOT NULL,
               		timestamp DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                    type INTEGER NOT NULL,
                    bowler_id TEXT,
                    batter_id TEXT,
                    runs_scored INTEGER,
                    wicket_id INTEGER,
                    bowling_extra_type INTEGER,
                    bowling_extra_penalty INTEGER,
                    batting_extra_type INTEGER,
                    batting_extra_runs INTEGER,
                    previous_player_id TEXT,
                    FOREIGN KEY (match_id, innings_number) REFERENCES innings(match_id, innings_number),
                   	FOREIGN KEY (bowler_id) REFERENCES players (id),
                   	FOREIGN KEY (batter_id) REFERENCES players (id),
                    FOREIGN KEY (wicket_id) REFERENCES wickets (id),
                    FOREIGN KEY (previous_player_id) REFERENCES players(id),
                    FOREIGN KEY (bowler_id) REFERENCES players (id));

--CREATE INDEX post_match_index ON posts (match_id);
--CREATE INDEX post_type_index on posts (type);

create view balls as select id, match_id, innings_number, day_number, session_number, index_over, index_ball, timestamp, 
                            bowler_id, batter_id, runs_scored, wicket_id,
                            bowling_extra_type, bowling_extra_penalty, batting_extra_type, batting_extra_runs
                            FROM posts where type = 0;