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
                    is_completed INTEGER DEFAULT 0,
                    is_declared INTEGER DEFAULT 0,
                    is_forfeited INTEGER DEFAULT 0,
                    is_ended INTEGER DEFAULT 0,
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
                    innings_number INTEGER NOT NULL,
                    day_number INTEGER,
                    session_number INTEGER,
               		timestamp DATETIME NOT NULL,
                    index_over INTEGER NOT NULL,
                    index_ball INTEGER NOT NULL,
                    type INTEGER NOT NULL,
                    bowler_id TEXT REFERENCES players (id),
                    bowling_score_id INTEGER REFERENCES bowling_scores (id),
                    batter_id TEXT REFERENCES players (id),
                    batting_score_id INTEGER REFERENCES batting_scores (id),
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
                            timestamp, index_over, index_ball,
                            bowler_id, bowling_score_id, batter_id, batting_score_id,
                            total_runs, bowler_runs, batter_runs, is_boundary,
                            extras_no_balls, extras_wides, extras_byes, extras_leg_byes, extras_penalties,
                            wicket_type, wicket_batter_id, wicket_fielder_id,
                            is_counted_for_bowler, is_counted_for_batter
                            FROM posts WHERE type = 0;

CREATE VIEW wickets AS SELECT id, match_id, innings_id, innings_number, day_number, session_number,
                              timestamp, index_over, index_ball,
                              wicket_type, wicket_batter_id, bowler_id, wicket_fielder_id
                              FROM balls WHERE wicket_type IS NOT NULL;

CREATE VIEW players_in_match AS SELECT match_id, batter_id AS player_id FROM posts WHERE batter_id IS NOT NULL
                                UNION SELECT match_id, bowler_id FROM posts WHERE bowler_id IS NOT NULL
                                UNION SELECT match_id, wicket_fielder_id FROM posts WHERE wicket_fielder_id IS NOT NULL;

CREATE TRIGGER update_innings_score
AFTER INSERT ON posts
WHEN new.type IN (0,6)
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
WHEN old.type IN (0, 6)
BEGIN
    UPDATE quick_innings SET
    runs = runs - old.total_runs,
    balls = balls - old.is_counted_for_bowler,
    extras_no_balls = extras_no_balls - old.extras_no_balls,
    extras_wides = extras_wides - old.extras_wides,
    extras_byes = extras_byes - old.extras_byes,
    extras_leg_byes = extras_leg_byes - old.extras_leg_byes,
    extras_penalties = extras_penalties - old.extras_penalties
    WHERE id = old.innings_id;
END;

CREATE TRIGGER update_innings_wicket
AFTER INSERT ON posts
WHEN new.wicket_type >= -1
BEGIN
    UPDATE quick_innings SET wickets = wickets - 1
    WHERE id = new.innings_id;
END;

CREATE TRIGGER update_innings_wicket
AFTER DELETE ON posts
WHEN old.wicket_type >= -1
BEGIN
    UPDATE quick_innings SET wickets = wickets - 1
    WHERE id = old.innings_id;
END;

CREATE TABLE batting_scores (id INTEGER PRIMARY KEY,
                    match_id TEXT NOT NULL REFERENCES quick_matches (id),
                    innings_id INTEGER NOT NULL REFERENCES quick_innings (id),
                    innings_number INTEGER NOT NULL,
                    player_id TEXT NOT NULL REFERENCES players (id),
                    batting_at INTEGER DEFAULT 0,
                    runs_scored INTEGER DEFAULT 0,
                    balls_faced INTEGER DEFAULT 0,
                    not_out INTEGER AS (IIF(wicket_type IS NULL, 1, 0)) STORED,
                    wicket_type INTEGER,
                    wicket_bowler_id TEXT REFERENCES players (id),
                    wicket_fielder_id TEXT REFERENCES players (id),
                    fours_scored INTEGER DEFAULT 0,
                    sixes_scored INTEGER DEFAULT 0,
                    boundaries_scored INTEGER AS (fours_scored+sixes_scored) STORED,
                    strike_rate REAL AS ((runs_scored/balls_faced) * 100) STORED);

CREATE VIEW batting_stats AS
                    WITH batting_stats AS
                    (SELECT bs.player_id AS id, p.name,
                    COUNT(DISTINCT bs.match_id) AS matches, COUNT(bs.player_id) AS innings,
                    SUM(bs.runs_scored) AS runs_scored, SUM(bs.balls_faced) AS balls_faced,
                    COUNT(CASE WHEN bs.not_out = 0 THEN NULL ELSE 1 END) AS not_outs,
                    COUNT(bs.wicket_type) AS outs,
                    MAX(bs.runs_scored) AS high_score
                    FROM batting_scores AS bs, players AS p
                    WHERE p.id = bs.player_id  GROUP BY player_id)
                    SELECT *, 100.0*runs_scored/balls_faced AS strike_rate,
                    COALESCE(1.0*runs_scored/outs, 1.0*runs_scored) AS average
                    FROM batting_stats ORDER BY runs_scored DESC, balls_faced ASC, outs ASC;

CREATE TRIGGER create_batting_score
AFTER INSERT ON posts
WHEN new.type = 4
BEGIN
    INSERT INTO batting_scores (match_id, innings_id, innings_number, player_id)
    VALUES (new.match_id, new.innings_id, new.innings_number, new.batter_id);

    UPDATE posts SET batting_score_id = LAST_INSERT_ROWID() WHERE id = new.id;
END;

CREATE TRIGGER delete_batting_score
AFTER DELETE ON posts
WHEN old.type = 4
BEGIN
    DELETE FROM batting_scores WHERE id = old.batting_score_id;
END;

CREATE TRIGGER update_batting_wicket
AFTER INSERT ON posts
WHEN new.wicket_type IS NOT NULL
BEGIN
    UPDATE batting_scores SET
    wicket_type = new.wicket_type,
    wicket_bowler_id = new.bowler_id,
    wicket_fielder_id = new.wicket_fielder_id
    WHERE id = new.batting_score_id;
END;

CREATE TRIGGER revert_batting_wicket
AFTER DELETE ON posts
WHEN old.wicket_type IS NOT NULL
BEGIN
    UPDATE batting_scores SET
    wicket_type = null,
    wicket_bowler_id = null,
    wicket_fielder_id = null
    WHERE id = old.batting_score_id;
END;

CREATE TABLE bowling_scores (id INTEGER PRIMARY KEY,
                    match_id TEXT NOT NULL REFERENCES quick_matches(id),
                    innings_id INTEGER NOT NULL REFERENCES quick_innings(id),
                    innings_number INTEGER NOT NULL,
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

CREATE VIEW bowling_stats AS
                    WITH bowling_stats AS
                    (SELECT bs.player_idASas id, p.name,
                    COUNT(DISTINCT bs.match_id) AS matches, COUNT(bs.player_id) AS innings,
                    SUM(bs.balls_bowled) AS balls_bowled, SUM(bs.runs_conceded) AS runs_conceded,
                    SUM(bs.wickets_taken) AS wickets_taken
                    FROM bowling_scores AS bs, players AS p
                    WHERE p.id = bs.player_id  GROUP BY player_id)
                    SELECT *, balls_bowled/6 AS overs_bowled, balls_bowled%6 AS overs_balls_bowled,
                    6.0*runs_conceded/balls_bowled AS economy,
                    1.0*runs_conceded/wickets_taken AS average,
                    1.0*balls_bowled/wickets_taken AS strike_rate
                    FROM bowling_stats ORDER BY wickets_taken DESC, runs_conceded ASC, balls_bowled DESC;

CREATE TRIGGER create_bowling_score
AFTER INSERT ON posts
WHEN new.type = 2
BEGIN
    INSERT INTO bowling_scores (match_id, innings_id, innings_number, player_id)
    VALUES (new.match_id, new.innings_id, new.innings_number, new.bowler_id);

    UPDATE posts SET bowling_score_id = LAST_INSERT_ROWID() WHERE id = new.id;
END;

CREATE TRIGGER delete_bowling_score
AFTER DELETE ON posts
WHEN old.type = 2
BEGIN
    DELETE FROM bowling_scores WHERE id = old.bowling_score_id;
END;

CREATE TRIGGER update_bowling_wicket
AFTER INSERT ON posts
WHEN new.type = 0 AND new.wicket_type IS NOT NULL
BEGIN
    UPDATE bowling_scores SET
    wickets_taken = wickets_taken + 1
    WHERE id = new.bowling_score_id;
END;

CREATE TRIGGER revert_bowling_wicket
AFTER DELETE ON posts
WHEN old.type = 0 AND old.wicket_type IS NOT NULL
BEGIN
    UPDATE bowling_scores SET
    wickets_taken = wickets_taken - 1
    WHERE id = old.bowling_score_id;
END;

CREATE TRIGGER update_player_score
AFTER INSERT ON posts
WHEN new.type = 0
BEGIN
   UPDATE batting_scores SET
   runs_scored = runs_scored + new.batter_runs,
   balls_faced = balls_faced + new.is_counted_for_batter
   WHERE id = new.batting_score_id;

   UPDATE bowling_scores SET
   runs_conceded = runs_conceded + new.bowler_runs,
   balls_bowled = balls_bowled + new.is_counted_for_bowler
   WHERE id = new.bowling_score_id;
END;

CREATE TRIGGER revert_player_score
AFTER DELETE ON posts
WHEN old.type = 0
BEGIN
   UPDATE batting_scores SET
   runs_scored = runs_scored - old.batter_runs,
   balls_faced = balls_faced - old.is_counted_for_batter
   WHERE id = old.batting_score_id;

   UPDATE bowling_scores SET
   runs_conceded = runs_conceded - old.bowler_runs,
   balls_bowled = balls_bowled - old.is_counted_for_bowler
   WHERE id = old.bowling_score_id;
END;