create database if not exists wcstats;

use wcstats;

create table teams (
id varchar(10) primary key,
name varchar(50),
region varchar(50)
);

create table players(
id varchar(10) primary key,
given_name varchar(50),
family_name varchar(50),
bod date,
position varchar(20),
wc_counts int,
list_of_wc varchar(100),
latest_wc int
);

create table tournaments (
id varchar(20) primary key,
year int,
host varchar(50),
winner varchar(50),
no_of_teams int,
type varchar(10)
);

create table matches (
id varchar(20) primary key,
tournament_id varchar(20),
stage_name varchar(20),
home_team_id varchar(20),
away_team_id varchar(20),
result varchar(50),
home_score int,
away_score int,
constraint fk_tour_matches foreign key (tournament_id) references tournaments(id),
constraint fk_teams_home_matches foreign key (home_team_id) references teams(id),
constraint fk_teams_away_matches foreign key (away_team_id) references teams(id)
);

create table goals (
match_id varchar(20),
team_id varchar(20),
player_id varchar(20),
minutes int,
pen bool,
og bool,
constraint fk_matches_goals foreign key (match_id) references matches(id),
constraint fk_teams_goals foreign key (team_id) references teams(id),
constraint fk_players_goals foreign key (player_id) references players(id)
);

create table bookings (
match_id varchar(20),
team_id varchar(20),
player_id varchar(20),
minutes int,
booking varchar(20),
constraint fk_matches_bookings foreign key (match_id) references matches(id),
constraint fk_teams_bookings foreign key (team_id) references teams(id),
constraint fk_players_bookings foreign key (player_id) references players(id)
);