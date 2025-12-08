CREATE TABLE players (id TEXT PRIMARY KEY,
                    name TEXT NOT NULL);

CREATE TABLE quick_matches (id TEXT PRIMARY KEY,
                    type INTEGER NOT NULL,
                    stage INTEGER NOT NULL,
                    starts_at DATETIME NOT NULL,
                    rules_overs_per_innings INTEGER NOT NULL,
                    rules_balls_per_over INTEGER NOT NULL,
                    rules_no_ball_penalty INTEGER NOT NULL,
                    rules_wide_penalty INTEGER NOT NULL);

CREATE TABLE quick_innings (id INTEGER PRIMARY KEY,
                    match_id TEXT NOT NULL REFERENCES quick_matches (id),
                    innings_number INTEGER NOT NULL,
                    type INTEGER NOT NULL,
                    is_ended INTEGER DEFAULT 0,
                    is_declared INTEGER DEFAULT 0,
                    is_forfeited INTEGER DEFAULT 0,
                    overs_limit INTEGER NOT NULL,
                    balls_per_over INTEGER NOT NULL,
                    target_runs INTEGER,
                    runs INTEGER DEFAULT 0,
                    wickets INTEGER DEFAULT 0,
                    balls INTEGER DEFAULT 0,
                    overs INTEGER AS (balls/6) STORED,
                    overs_balls INTEGER AS (balls%6) STORED,
                    extras_no_balls INTEGER DEFAULT 0,
                    extras_wides INTEGER DEFAULT 0,
                    extras_byes INTEGER DEFAULT 0,
                    extras_leg_byes INTEGER DEFAULT 0,
                    extras_penalties INTEGER DEFAULT 0,
                    extras_total INTEGER AS (extras_no_balls + extras_wides + extras_byes + extras_leg_byes + extras_penalties) STORED,
                    batter1_id TEXT REFERENCES players (id),
                    batter2_id TEXT REFERENCES players (id),
                    striker_id TEXT REFERENCES players (id),
                    bowler_id TEXT REFERENCES players (id));

CREATE TABLE posts (id INTEGER PRIMARY KEY,
                    match_id TEXT NOT NULL REFERENCES quick_matches (id),
                    innings_id INTEGER NOT NULL REFERENCES quick_innings (id),
                    innings_number INTEGER NOT NULL REFERENCES quick_innings (innings_number),
                    day_number INTEGER,
                    session_number INTEGER,
                    index_over INTEGER NOT NULL,
                    index_ball INTEGER NOT NULL,
               		timestamp DATETIME NOT NULL,
                    type INTEGER NOT NULL,
                    bowler_id TEXT REFERENCES players (id),
                    batter_id TEXT REFERENCES players (id),
                    previous_id TEXT REFERENCES players (id),
                    total_runs INTEGER,
                    bowler_runs INTEGER,
                    batter_runs INTEGER,
                    is_boundary INTEGER,
                    extras_no_balls INTEGER,
                    extras_wides INTEGER,
                    extras_byes INTEGER,
                    extras_leg_byes INTEGER,
                    extras_penalties INTEGER,
                    wicket_type INTEGER,
                    wicket_batter_id TEXT REFERENCES players (id),
                    wicket_fielder_id TEXT REFERENCES players (id),
                    is_counted_for_bowler INTEGER NOT NULL,
                    is_counted_for_batter INTEGER NOT NULL,
                    comment TEXT);

CREATE INDEX post_type_index ON posts (type);

CREATE VIEW balls AS SELECT id, match_id, innings_id, innings_number, day_number, session_number,
                            index_over, index_ball, timestamp,
                            bowler_id, batter_id, total_runs, bowler_runs, batter_runs, is_boundary,
                            extras_no_balls, extras_wides, extras_byes, extras_leg_byes, extras_penalties,
                            wicket_type, wicket_batter_id, wicket_fielder_id
                            FROM posts WHERE type = 0;

CREATE TRIGGER update_innings_score
AFTER INSERT ON posts
WHEN new.type = 0
BEGIN
    UPDATE quick_innings SET
    runs = runs + new.total_runs,
    balls = balls + new.is_counted_for_bowler,
    extras_no_balls = extras_no_balls + new.extras_no_balls,
    extras_wides = extras_wides + new.extras_wides,
    extras_byes = extras_byes + new.extras_byes,
    extras_leg_byes = extras_leg_byes + new.extras_leg_byes,
    extras_penalties = extras_penalties + new.extras_penalties
    WHERE id = new.innings_id;
END;

CREATE TRIGGER revert_innings_score
AFTER DELETE ON posts
WHEN old.type = 0
BEGIN
    UPDATE quick_innings SET
    runs = runs - old.total_runs,
    balls = balls - old.is_counted_for_bowler,
    extras_no_balls = extras_no_balls - old.extras_no_balls
    extras_wides = extras_wides - old.extras_wides,
    extras_byes = extras_byes - old.extras_byes,
    extras_leg_byes = extras_leg_byes - old.extras_leg_byes,
    extras_penalties = extras_penalties - old.extras_penalties
    WHERE id = new.innings_id;
END;

CREATE TABLE batting_scores (id INTEGER PRIMARY KEY,
                    match_id TEXT NOT NULL REFERENCES quick_matches (id),
                    innings_id INTEGER NOT NULL REFERENCES quick_innings (id),
                    player_id TEXT NOT NULL REFERENCES players (id),
                    runs_scored INTEGER DEFAULT 0,
                    balls_faced INTEGER DEFAULT 0,
                    not_out INTEGER AS IIF(wicket_type IS NULL, 0, 1) STORED,
                    wicket_type INTEGER,
                    wicket_bowler_id TEXT REFERENCES players (id),
                    wicket_fielder_id TEXT REFERENCES players (id),
                    fours_scored INTEGER DEFAULT 0,
                    sixes_scored INTEGER DEFAULT 0,
                    boundaries_scored INTEGER AS (fours_scored+sixes_scored) STORED,
                    batting_strike_rate REAL AS ((runs_scored/balls_faced) * 100) STORED);

CREATE TRIGGER create_batting_score
AFTER INSERT ON posts
WHEN new.type = 4
BEGIN
    INSERT INTO batting_scores (id, match_id, innings_id, player_id)
    VALUES (new.id, new.match_id, new.innings_id, new.batter_id);
END;

CREATE TRIGGER delete_batting_score
AFTER DELETE ON posts
WHEN old.type = 4
BEGIN
    DELETE FROM batting_scores WHERE id = old.id;
END;

CREATE TRIGGER update_batting_wicket
AFTER INSERT ON posts
WHEN (new.type = 0 AND new.wicket_type IS NOT NULL) OR new.type = 3 OR new.type = 5
BEGIN
    UPDATE batting_scores SET
    wicket_type = new.wicket_type,
    wicket_bowler_id = new.bowler_id,
    wicket_fielder_id = new.wicket_fielder_id
    WHERE player_id = new.batter_id AND innings_id = new.innings_id;
END;

CREATE TRIGGER revert_batting_wicket
AFTER DELETE ON posts
WHEN (old.type = 0 AND old.wicket_type IS NOT NULL) OR old.type = 3 OR old.type = 5
BEGIN
    UPDATE batting_scores SET
    wicket_type = null,
    wicket_bowler_id = null,
    wicket_fielder_id = null
    WHERE player_id = old.batter_id AND innings_id = old.innings_id;
END;

CREATE TABLE bowling_scores (id INTEGER PRIMARY KEY,
                    match_id TEXT NOT NULL REFERENCES quick_matches(id),
                    innings_id INTEGER NOT NULL REFERENCES quick_innings(id),
                    player_id TEXT NOT NULL REFERENCES players(id),
                    balls_bowled INTEGER DEFAULT 0,
                    overs_bowled INTEGER AS (balls_bowled/6) STORED,
                    overs_balls_bowled INTEGER AS (balls_bowled%6) STORED,
                    runs_conceded INTEGER DEFAULT 0,
                    wickets_taken INTEGER DEFAULT 0,
                    extras_no_balls INTEGER DEFAULT 0,
                    extras_wides INTEGER DEFAULT 0,
                    extras_total INTEGER AS (extras_no_balls + extras_wides) STORED,
                    bowling_economy REAL AS ((runs_conceded/balls_bowled)*6) STORED,
                    catches_taken INTEGER DEFAULT 0);

CREATE TRIGGER create_bowling_score
AFTER INSERT ON posts
WHEN new.type = 2
BEGIN
    INSERT INTO bowling_scores (id, match_id, innings_id, player_id)
    VALUES (new.id, new.match_id, new.innings_id, new.bowler_id);
END;

CREATE TRIGGER delete_bowling_score
AFTER DELETE ON posts
WHEN old.type = 2
BEGIN
    DELETE FROM bowling_scores WHERE id = old.id;
END;

CREATE TRIGGER update_bowling_wicket
AFTER INSERT ON posts
WHEN new.type = 0 AND new.wicket_type IS NOT NULL
BEGIN
    UPDATE bowling_scores SET
    wickets_taken = wickets_taken + 1
    WHERE player_id = new.bowler_id AND innings_id = new.innings_id;
END;

CREATE TRIGGER revert_bowling_wicket
AFTER DELETE ON posts
WHEN old.type = 0 AND old.wicket_type IS NOT NULL
BEGIN
    UPDATE bowling_scores SET
    wickets_taken = wickets_taken - 1
    WHERE player_id = new.bowler_id AND innings_id = new.innings_id;
END;

CREATE TRIGGER update_player_score
AFTER INSERT ON posts
WHEN new.type = 0
BEGIN
   UPDATE batting_scores SET
   runs_scored = runs_scored + new.batter_runs,
   balls_faced = balls_faced + new.is_counted_for_batter,
   WHERE player_id = new.batter_id AND innings_id = new.innings_id;

   UPDATE bowling_scores SET
   runs_conceded = runs_conceded + new.bowler_runs,
   balls_bowled = balls_bowled + new.is_counted_for_bowler
   WHERE player_id = new.bowler_id AND innings_id = new.innings_id;
END;

CREATE TRIGGER revert_player_score
AFTER DELETE ON posts
WHEN old.type = 0
BEGIN
   UPDATE batting_scores SET
   runs_scored = runs_scored - old.batter_runs,
   balls_faced = balls_faced - old.is_counted_for_batter
   WHERE player_id = old.batter_id AND innings_id = old.innings_id;

   UPDATE bowling_scores SET
   runs_conceded = runs_conceded - old.bowler_runs,
   balls_bowled = balls_bowled - old.is_counted_for_bowler
   WHERE player_id = old.bowler_id AND innings_id = old.innings_id;
END;