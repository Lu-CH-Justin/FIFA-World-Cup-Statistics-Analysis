load data local infile 'C:/Users/user/Downloads/teams.csv' into table teams
fields terminated by ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
ignore 1 rows
(@key_id, teamid, teamname, @s, @s, @s, @s, region, @s, @s, @s, @s, @s, @s);

load data local infile 'C:/Users/user/Downloads/players.csv' into table players
fields terminated by ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
ignore 1 rows
(@key_id, pid, plname, pfname, bod, @s, @s, @s, @s, @s, wc_counts, list_of_wc, @s, position);	

load data local infile 'C:/Users/user/Downloads/goals.csv' into table goals
fields terminated by ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
ignore 1 rows
(@key_id, @s, tid, @s, mid, @s, @s, @s, @s, teamid, @s, @s, @s, @s, pid, @s, @s, @s, @s, @s, @s, @s, minutes, @s, @s, og, pen);

load data local infile 'C:/Users/user/Downloads/tournaments.csv' into table tournaments
fields terminated by ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
ignore 1 rows
(@key_id, tid, @s, year, @s, @s, host, winner, @s, no_of_teams, @s, @s, @s, @s, @s, @s, @s, @s);

load data local infile 'C:/Users/user/Downloads/matches.csv' into table matches
fields terminated by ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
ignore 1 rows
(@key_id, tid, @s, mid, @s, stage_name, @s, @s, @s, @s, @s, @s, @s, @s, @s, @s, @s, home_teamid, @s, @s, away_teamid, @s, @s, @s, home_score, away_score, @s, @s, @s, @s, @s, @s, @s, result);

load data local infile 'C:/Users/user/Downloads/bookings.csv' into table bookings
fields terminated by ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
ignore 1 rows
(@key_id, @s, tid, @s, mid, @s, @s, @s, @s, teamid, @s, @s, @s, @s, pid, @s, @s, @s, @s, minutes, @s, @s, @s, @s, @s, @s, booking);