CREATE TABLE players (id TEXT PRIMARY KEY,
                      name TEXT NOT NULL);

CREATE TABLE quick_matches (id TEXT PRIMARY KEY,
                      type INTEGER NOT NULL,
                      stage INTEGER NOT NULL,
                      starts_at DATETIME NOT NULL,
                      rules_balls_per_over INTEGER NOT NULL,
                      rules_balls_per_innings INTEGER NOT NULL,
                      rules_no_ball_penalty INTEGER NOT NULL,
                      rules_wide_penalty INTEGER NOT NULL,
                      rules_only_single_batter BOOLEAN NOT NULL);

CREATE TABLE quick_innings (id INTEGER PRIMARY KEY,
                      match_id TEXT NOT NULL REFERENCES quick_matches (id),
                      innings_number INTEGER NOT NULL,
                      type INTEGER NOT NULL,
                      is_declared BOOLEAN NOT NULL,
                      batter1_id TEXT REFERENCES players (id),
                      batter2_id TEXT REFERENCES players (id),
                      striker_id TEXT REFERENCES players (id),
                      bowler_id TEXT REFERENCES players (id),
                      target_runs INTEGER);

CREATE TABLE posts (id INTEGER PRIMARY KEY,
                    match_id TEXT NOT NULL REFERENCES quick_matches(id),
                    innings_id INTEGER NOT NULL REFERENCES quick_innings(id),
                    index_over INTEGER NOT NULL,
                    index_ball INTEGER NOT NULL,
               		timestamp DATETIME NOT NULL,
                    type INTEGER NOT NULL,
                    bowler_id TEXT REFERENCES players (id),
                    batter_id TEXT REFERENCES players (id),
                    total_runs INTEGER,
                    bowler_runs INTEGER,
                    batter_runs INTEGER,
                    is_boundary INTEGER,
                    bowling_extra_type INTEGER,
                    bowling_extra_penalty INTEGER,
                    batting_extra_type INTEGER,
                    batting_extra_runs INTEGER,
                    wicket_type INTEGER,
                    wicket_batter_id TEXT REFERENCES players (id),
                    wicket_fielder_id TEXT REFERENCES players (id),
                    comment TEXT);

CREATE INDEX post_type_index ON posts (type);

CREATE VIEW balls AS SELECT id, match_id, index_over, index_ball, timestamp,
                            bowler_id, batter_id,total_runs, bowler_runs, batter_runs, is_boundary,
                            bowling_extra_type, bowling_extra_penalty, batting_extra_type, batting_extra_runs,
                            wicket_type, wicket_batter_id, wicket_fielder_id
                            FROM posts WHERE type = 0;