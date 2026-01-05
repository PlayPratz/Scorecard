DROP TABLE IF EXISTS players;
CREATE TABLE players (id INTEGER PRIMARY KEY,
                    handle TEXT UNIQUE NOT NULL,
                    name TEXT NOT NULL,
                    full_name TEXT,
                    date_of_birth DATETIME);

DROP TABLE IF EXISTS venues;
CREATE TABLE venues (id INTEGER PRIMARY KEY,
                    handle TEXT UNIQUE NOT NULL,
                    name TEXT NOT NULL,
                    city TEXT,
                    country TEXT);

DROP TABLE IF EXISTS quick_matches;
CREATE TABLE quick_matches (id INTEGER PRIMARY KEY,
                    handle TEXT UNIQUE NOT NULL,
                    type INTEGER NOT NULL,
                    stage INTEGER NOT NULL,
                    starts_at DATETIME NOT NULL,
                    venue_id REFERENCES venues(id),
                    overs_per_innings INTEGER NOT NULL,
                    balls_per_over INTEGER NOT NULL);

DROP TABLE IF EXISTS quick_innings;
CREATE TABLE quick_innings (id INTEGER PRIMARY KEY,
                    match_id INTEGER NOT NULL REFERENCES quick_matches(id),
                    innings_number INTEGER NOT NULL,
                    type INTEGER NOT NULL,
                    status INTEGER,
                    overs_limit INTEGER NOT NULL,
                    balls_per_over INTEGER NOT NULL,
                    runs INTEGER DEFAULT 0,
                    wickets INTEGER DEFAULT 0,
                    balls INTEGER DEFAULT 0,
                    overs INTEGER AS (balls/balls_per_over) STORED,
                    overs_balls INTEGER AS (balls%balls_per_over) STORED,
                    extras_no_balls INTEGER DEFAULT 0,
                    extras_wides INTEGER DEFAULT 0,
                    extras_byes INTEGER DEFAULT 0,
                    extras_leg_byes INTEGER DEFAULT 0,
                    extras_penalties INTEGER DEFAULT 0,
                    extras_total INTEGER AS (extras_no_balls+extras_wides+extras_byes+extras_leg_byes+extras_penalties) STORED,
                    run_rate REAL AS (1.0*runs*balls_per_over/balls) STORED,
                    balls_left INTEGER AS (overs_limit*balls_per_over - balls) STORED,
                    target_runs INTEGER,
                    runs_required INTEGER AS (target_runs-runs) STORED,
                    required_run_rate REAL AS (1.0*runs_required*balls_per_over/balls) STORED,
                    batter1_id INTEGER REFERENCES players(id),
                    batter2_id INTEGER REFERENCES players(id),
                    striker INTEGER,
                    bowler_id INTEGER REFERENCES players(id),
                    UNIQUE(match_id, innings_number));

CREATE INDEX match_innings_index ON quick_innings(match_id);

DROP TABLE IF EXISTS posts;
CREATE TABLE posts (id INTEGER PRIMARY KEY,
                    match_id INTEGER NOT NULL REFERENCES quick_matches (id),
                    innings_id INTEGER NOT NULL REFERENCES quick_innings (id),
                    innings_type INTEGER NOT NULL,
                    innings_number INTEGER NOT NULL,
                    day_number INTEGER,
                    session_number INTEGER,
               		timestamp DATETIME NOT NULL,
                    over_index INTEGER DEFAULT -1,
                    ball_index INTEGER DEFAULT -1,
                    type INTEGER NOT NULL,
                    bowler_id INTEGER REFERENCES players (id),
                    batter_id INTEGER REFERENCES players (id),
                    non_striker_id INTEGER REFERENCES players(id),
                    next_player_id INTEGER REFERENCES players (id),
                    total_runs INTEGER,
                    bowler_runs INTEGER,
                    batter_runs INTEGER,
                    is_boundary INTEGER,
                    extras_no_balls INTEGER,
                    extras_wides INTEGER,
                    extras_byes INTEGER,
                    extras_leg_byes INTEGER,
                    extras_penalties INTEGER,
                    extras_total INTEGER AS (extras_no_balls+extras_wides+extras_byes+extras_leg_byes+extras_penalties) STORED,
                    wicket_type INTEGER,
                    wicket_batter_id INTEGER REFERENCES players (id),
                    wicket_fielder_id INTEGER REFERENCES players (id),
                    runs_at INTEGER DEFAULT -1,
                    wickets_at INTEGER DEFAULT -1,
                    is_counted_for_bowler INTEGER AS(IIF(type=0 AND (extras_no_balls+extras_wides)<=0,1,0)) STORED,
                    is_counted_for_batter INTEGER AS(IIF(type=0 AND extras_wides <= 0,1,0)) STORED,
                    comment TEXT);

CREATE INDEX post_type_index ON posts(type);
CREATE INDEX post_innings_index ON posts(innings_id);
CREATE INDEX post_batter_index ON posts(batter_id);
CREATE INDEX post_bowler_index ON posts(bowler_id);

DROP VIEW IF EXISTS balls;
CREATE VIEW balls AS SELECT id, match_id, innings_id, innings_type, innings_number, day_number, session_number,
                            timestamp, over_index, ball_index,
                            bowler_id, batter_id, non_striker_id,
                            total_runs, bowler_runs, batter_runs, is_boundary,
                            extras_no_balls, extras_wides, extras_byes, extras_leg_byes, extras_penalties, extras_total,
                            wicket_type, wicket_batter_id, wicket_fielder_id,
                            runs_at, wickets_at,
                            is_counted_for_bowler, is_counted_for_batter
                            FROM posts WHERE type = 0;

DROP VIEW IF EXISTS wickets;
CREATE VIEW wickets AS SELECT id, match_id, innings_id, innings_type, innings_number, day_number, session_number,
                              timestamp, over_index, ball_index,
                              wicket_type, wicket_batter_id AS batter_id,
                              bowler_id, wicket_fielder_id AS fielder_id,
                              runs_at, wickets_at
                              FROM balls WHERE wicket_type IS NOT NULL;

DROP TABLE IF EXISTS batting_scores;
CREATE TABLE batting_scores (id INTEGER PRIMARY KEY,
                    match_id INTEGER NOT NULL REFERENCES quick_matches(id),
                    innings_id INTEGER NOT NULL REFERENCES quick_innings(id),
                    innings_type INTEGER NOT NULL,
                    innings_number INTEGER NOT NULL,
                    player_id INTEGER NOT NULL REFERENCES players(id),
                    batting_at INTEGER NOT NULL,
                    runs_scored INTEGER DEFAULT 0,
                    balls_faced INTEGER DEFAULT 0,
                    not_out INTEGER AS (IIF(wicket_type IS NULL, 1, 0)) STORED,
                    wicket_type INTEGER,
                    wicket_bowler_id INTEGER REFERENCES players(id),
                    wicket_fielder_id INTEGER REFERENCES players(id),
                    fours_scored INTEGER DEFAULT 0,
                    sixes_scored INTEGER DEFAULT 0,
                    boundaries_scored INTEGER AS (fours_scored+sixes_scored) STORED,
                    strike_rate REAL AS (100.0*runs_scored/balls_faced) STORED,
                    UNIQUE (innings_id, batting_at));

CREATE INDEX batting_scores_index ON batting_scores (innings_id, player_id, batting_at);

DROP VIEW IF EXISTS batting_stats;
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

DROP TABLE IF EXISTS partnerships;
CREATE TABLE partnerships (id INTEGER PRIMARY KEY,
                    match_id INTEGER NOT NULL REFERENCES quick_matches(id),
                    innings_id INTEGER NOT NULL REFERENCES quick_innings(id),
                    innings_type INTEGER NOT NULL,
                    innings_number INTEGER NOT NULL,
                    runs_scored INTEGER DEFAULT 0,
                    balls_faced INTEGER DEFAULT 0,
                    batter1_id INTEGER NOT NULL REFERENCES players(id),
                    batter1_runs_scored INTEGER DEFAULT 0,
                    batter1_balls_faced INTEGER DEFAULT 0,
                    batter2_id INTEGER REFERENCES players(id),
                    batter2_runs_scored INTEGER DEFAULT 0,
                    batter2_balls_faced INTEGER DEFAULT 0,
                    extras_no_balls INTEGER DEFAULT 0,
                    extras_wides INTEGER DEFAULT 0,
                    extras_byes INTEGER DEFAULT 0,
                    extras_leg_byes INTEGER DEFAULT 0,
                    extras_penalties INTEGER DEFAULT 0,
                    extras_total INTEGER AS (extras_no_balls+extras_wides+extras_byes+extras_leg_byes+extras_penalties) STORED);

DROP TABLE IF EXISTS bowling_scores;
CREATE TABLE bowling_scores (id INTEGER PRIMARY KEY,
                    match_id INTEGER NOT NULL REFERENCES quick_matches(id),
                    innings_id INTEGER NOT NULL REFERENCES quick_innings(id),
                    innings_type INTEGER NOT NULL,
                    innings_number INTEGER NOT NULL,
                    player_id INTEGER NOT NULL REFERENCES players(id),
                    balls_bowled INTEGER DEFAULT 0,
                    overs_bowled INTEGER AS (balls_bowled/6) STORED,
                    overs_balls_bowled INTEGER AS (balls_bowled%6) STORED,
                    runs_conceded INTEGER DEFAULT 0,
                    wickets_taken INTEGER DEFAULT 0,
                    extras_no_balls INTEGER DEFAULT 0,
                    extras_wides INTEGER DEFAULT 0,
                    extras_total INTEGER AS (extras_no_balls + extras_wides) STORED,
                    economy REAL AS (6.0*runs_conceded/balls_bowled) STORED,
                    UNIQUE(innings_id, player_id));

CREATE INDEX bowling_scores_index ON bowling_scores (innings_id, player_id);

DROP VIEW IF EXISTS bowling_stats;
CREATE VIEW bowling_stats AS
                    WITH bowling_stats AS
                    (SELECT bs.player_id AS id, p.name,
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

DROP TABLE IF EXISTS players_in_match;
CREATE TABLE players_in_match (id INTEGER PRIMARY KEY,
                    match_id INTEGER NOT NULL REFERENCES quick_matches(id),
                    player_id INTEGER NOT NULL REFERENCES players(id),
                    UNIQUE(match_id, player_id));

DROP VIEW IF EXISTS players_in_match_expanded;
CREATE VIEW players_in_match_expanded AS
                    SELECT players.* from players_in_match INNER JOIN players ON players.id = players_in_match.player_id;

DROP TABLE IF EXISTS lookup_wicket;
CREATE TABLE lookup_wicket (type INTEGER PRIMARY KEY,
                    code TEXT NOT NULL UNIQUE);
INSERT INTO lookup_wicket(type, code) VALUES
                    (101, 'bowled'),
                    (111, 'lbw'),
                    (131, 'hit wicket'),
                    (151, 'caught'),
                    (152, 'caught and bowled'),
                    (171, 'stumped'),
                    (191, 'run out'),
                    (201, 'obstructing the field'),
                    (211, 'hit the ball twice'),
                    (301, 'timed out'),
                    (401, 'retired - out'),
                    (501, 'retired - not out');

DROP TABLE IF EXISTS lookup_post;
CREATE TABLE lookup_post (type INTEGER PRIMARY KEY,
                    code TEXT NOT NULL UNIQUE);
INSERT INTO lookup_post (type, code) VALUES
                    (0, 'ball'),
                    (1, 'bowler retire'),
                    (2, 'next bowler'),
                    (3, 'batter retire'),
                    (4, 'next batter'),
                    (5, 'wicket before delivery'),
                    (6, 'penalty'),
                    (7, 'break');

DROP TABLE IF EXISTS lookup_innings_state;
CREATE TABLE lookup_innings_state (type INTEGER PRIMARY KEY,
                    code TEXT NOT NULL UNIQUE);
INSERT INTO lookup_innings_state (type, code) VALUES
                    (101, 'scheduled'),
                    (201, 'in progress'),
                    (202, 'pick bowler'),
                    (203, 'pick batter'),
                    (301, 'innings break'),
                    (302, 'drinks break'),
                    (303, 'meal break'),
                    (304, 'lunch break'),
                    (305, 'tea break'),
                    (401, 'suspended'),
                    (501, 'called off'),
                    (601, 'all out'),
                    (602, 'batter unavailable'),
                    (603, 'declared'),
                    (604, 'forfeited'),
                    (605, 'mutual agreement'),
                    (606, 'out of overs'),
                    (608, 'out of time'),
                    (609, 'target achieved');

DROP TRIGGER IF EXISTS create_batting_score;
CREATE TRIGGER create_batting_score
AFTER INSERT ON posts
WHEN new.type = 4
BEGIN
    INSERT OR IGNORE INTO batting_scores (match_id, innings_id, innings_type, innings_number, player_id, batting_at)
    VALUES (new.match_id, new.innings_id, new.innings_type, new.innings_number, new.batter_id);
END;

DROP TRIGGER IF EXISTS delete_batting_score;
CREATE TRIGGER delete_batting_score
AFTER DELETE ON posts
WHEN old.type = 4
BEGIN
    DELETE FROM batting_scores WHERE id =
    (SELECT id FROM batting_scores
    WHERE innings_id=old.innings_id AND player_id=old.batter_id
    ORDER BY id DESC LIMIT 1);

    DELETE FROM partnerships
    WHERE innings_id=old.innings_id AND partnership_number=old.partnership_number;
END;

DROP TRIGGER IF EXISTS create_bowling_score;
CREATE TRIGGER create_bowling_score
AFTER INSERT ON posts
WHEN new.type = 2
BEGIN
    INSERT OR IGNORE INTO bowling_scores (match_id, innings_id, innings_type, innings_number, player_id)
    VALUES (new.match_id, new.innings_id, new.innings_type, new.innings_number, new.bowler_id);
END;

DROP TRIGGER IF EXISTS delete_bowling_score;
CREATE TRIGGER delete_bowling_score
AFTER INSERT ON posts
WHEN old.type = 2
BEGIN
    DELETE FROM bowling_scores WHERE innings_id=old.innings_id AND player_id=old.bowler_id;
END;

DROP TRIGGER IF EXISTS update_innings_wicket;
CREATE TRIGGER update_innings_wicket
AFTER INSERT ON posts
WHEN new.wicket_type != 501
BEGIN
    UPDATE quick_innings SET wickets = wickets + 1 WHERE id = new.innings_id;
END;

DROP TRIGGER IF EXISTS revert_innings_wicket;
CREATE TRIGGER revert_innings_wicket
AFTER DELETE ON posts
WHEN old.wicket_type != 501
BEGIN
    UPDATE quick_innings SET wickets = wickets -1 WHERE id = old.innings_id;
END;

DROP TRIGGER IF EXISTS update_bowling_wicket;
CREATE TRIGGER update_bowling_wicket
AFTER INSERT ON posts
WHEN new.wicket_type < 190
BEGIN
     UPDATE bowling_scores SET wickets_taken = wickets_taken + 1
     WHERE innings_id = new.innings_id AND player_id = new.bowler_id;
END;

DROP TRIGGER IF EXISTS revert_bowling_wicket;
CREATE TRIGGER revert_bowling_wicket
AFTER DELETE ON posts
WHEN old.wicket_type < 190
BEGIN
     UPDATE bowling_scores SET wickets_taken = wickets_taken - 1
     WHERE innings_id = old.innings_id AND player_id = old.bowler_id;
END;

DROP TRIGGER IF EXISTS update_batting_wicket;
CREATE TRIGGER update_batting_wicket
AFTER INSERT ON posts
WHEN new.wicket_type IS NOT NULL
BEGIN
    UPDATE batting_scores SET
    wicket_type = new.wicket_type,
    wicket_bowler_id = IIF(new.wicket_type<190, new.bowler_id, null),
    wicket_fielder_id = new.wicket_fielder_id
    WHERE innings_id = new.innings_id AND player_id = new.wicket_batter_id;
END;

DROP TRIGGER IF EXISTS revert_batting_wicket;
CREATE TRIGGER revert_batting_wicket
AFTER DELETE ON posts
WHEN new.wicket_type IS NOT NULL
BEGIN
    UPDATE batting_scores SET
    wicket_type = null,
    wicket_bowler_id = null,
    wicket_fielder_id = null
    WHERE innings_id = old.innings_id AND player_id = old.wicket_batter_id;
END;

DROP TRIGGER IF EXISTS update_scores;
CREATE TRIGGER update_scores
AFTER INSERT ON posts
WHEN new.type IN (0, 6)
BEGIN
    UPDATE quick_innings SET
    runs =  runs + new.total_runs,
    balls = balls + new.is_counted_for_bowler,
    extras_no_balls = extras_no_balls +  new.extras_no_balls,
    extras_wides = extras_wides + new.extras_wides,
    extras_byes = extras_byes + new.extras_byes,
    extras_leg_byes = extras_leg_byes + new.extras_leg_byes,
    extras_penalties = extras_penalties + new.extras_penalties
    WHERE id = new.innings_id;

    UPDATE posts SET (runs_at, wickets_at)
    = (SELECT runs, wickets FROM quick_innings as qi WHERE qi.id = new.innings_id)
    WHERE id = new.id;

    UPDATE batting_scores SET
    runs_scored = runs_scored + new.batter_runs,
    balls_faced = balls_faced + new.is_counted_for_batter
    WHERE innings_id = new.innings_id AND player_id = new.batter_id;

    UPDATE bowling_scores SET
    runs_conceded = runs_conceded + new.bowler_runs,
    balls_bowled = balls_bowled + new.is_counted_for_bowler
    WHERE innings_id = new.innings_id AND player_id = new.bowler_id;
END;

DROP TRIGGER IF EXISTS revert_scores;
CREATE TRIGGER revert_scores
AFTER DELETE ON posts
WHEN old.type IN (0, 6)
BEGIN
    UPDATE quick_innings SET
    runs =  runs - old.total_runs,
    balls = balls - old.is_counted_for_bowler,
    extras_no_balls = extras_no_balls - old.extras_no_balls,
    extras_wides = extras_wides - old.extras_wides,
    extras_byes = extras_byes - old.extras_byes,
    extras_leg_byes = extras_leg_byes - old.extras_leg_byes,
    extras_penalties = extras_penalties - old.extras_penalties
    WHERE id = old.innings_id;

    UPDATE posts SET (runs_at, wickets_at)
    = (SELECT runs, wickets FROM quick_innings as qi WHERE qi.id = old.innings_id)
    WHERE id = old.id;

    UPDATE batting_scores SET
    runs_scored = runs_scored - old.batter_runs,
    balls_faced = balls_faced - old.is_counted_for_batter
    WHERE innings_id = old.innings_id AND player_id = old.batter_id;

    UPDATE bowling_scores SET
    runs_conceded = runs_conceded - old.bowler_runs,
    balls_bowled = balls_bowled - old.is_counted_for_bowler
    WHERE innings_id = old.innings_id AND player_id = old.bowler_id;
END;