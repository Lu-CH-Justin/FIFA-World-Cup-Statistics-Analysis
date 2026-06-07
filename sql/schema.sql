create database wcstats;

use wcstats;

create table teams (
teamid varchar(20) primary key,
teamname varchar(20),
region varchar(20)
);

create table players(
pid varchar(20) primary key,
pfname varchar(20),
plname varchar(20),
bod date,
position varchar(20),
wc_counts int,
list_of_wc varchar(20)
);

create table goals (
tid varchar(20),
mid varchar(20),
teamid varchar(20),
pid varchar(20),
minutes int,
pen bool,
og bool
);

create table tournaments (
tid varchar(20) primary key,
year int,
host varchar(20),
winner varchar(20),
no_of_teams int
);

create table matches (
mid varchar(20) primary key,
tid varchar(20),
stage_name varchar(20),
home_teamid varchar(20),
away_teamid varchar(20),
result varchar(20),
home_score int,
away_score int
);

create table bookings (
mid varchar(20),
tid varchar(20),
teamid varchar(20),
pid varchar(20),
minutes int,
booking varchar(20)
);
