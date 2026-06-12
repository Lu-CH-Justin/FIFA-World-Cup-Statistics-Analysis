/* ====================================
   Section 1: Goal Scoring Analysis
   ==================================== */
   
-- Top goal scorers of all time

select p.id, p.given_name, p.family_name, count(*) as goals 
from players p join goals g 
on p.id = g.player_id and g.og = 0
group by p.id 
order by goals desc;


-- Top goal scoring teams of all time

select t.name, count(*) as goals 
from teams t join goals g 
on t.id = g.team_id and g.og = 0
group by g.team_id 
order by goals desc;


-- Top goal scoring regions of all time

select t.region, count(*) as goals 
from teams t join goals g 
on t.id = g.team_id and g.og = 0
group by t.region 
order by goals desc;


-- Most goal scorers of every world cup

with goals_stats as (
select m.tournament_id, g.player_id, count(*) as goals, dense_rank() over (partition by m.tournament_id order by count(*) desc) as rnk
from goals g join matches m
on g.match_id = m.id and g.og = 0
group by m.tournament_id, g.player_id
order by m.tournament_id, goals desc
)
select t.year, p.given_name, p.family_name, g.goals 
from goals_stats g join players p
on p.id = g.player_id and rnk = 1
join tournaments t
on g.tournament_id = t.id;


-- Penalty vs Non-Penalty goals

select
case
	when pen = 1 then 'Penalty'
   else 'Non-Penalty'
end as goal_type,
count(*) as goals
from goals
group by goal_type;


-- Goals by position

select p.position, count(*) as goals
from players p join goals g
on p.id = g.player_id and g.og = 0
group by p.position
order by goals desc;


-- Goals by minute

select minutes, count(*) as goals 
from goals
group by minutes
order by minutes;


-- Goals by half

select
case 
	when minutes between 0 and 45 then 'first half'
	when minutes between 46 and 90 then 'second half'
   else 'extra time / stoppage'
end as parts,
   count(*) as goals
from goals
group by parts;


/* ====================================
   Section 2: Match Analysis
   ==================================== */
   
-- Matches per stage

select tournament_id, stage_name, count(*) as matches 
from matches 
group by tournament_id, stage_name 
order by tournament_id desc, matches desc;


-- Most goals in a single match

select m.id, t1.name as home_team, t2.name as away_team, m.home_score, m.away_score, (m.home_score + m.away_score) as goals
from matches m join teams t1
on m.home_team_id = t1.id
join teams t2
on m.away_team_id = t2.id
order by goals desc;


-- Average goals per match by World Cup

select t.year, round(sum(home_score + away_score) / count(distinct m.id),2) as avg_goals_per_match
from matches m join tournaments t
on m.tournament_id = t.id
group by t.year;


/* ====================================
   Section 3: Discipline Analysis
   ==================================== */
   
-- Bookings by minute
   
select minutes, count(*) as bookings 
from bookings
group by minutes
order by minutes;


-- Bookings by match

select m.id, count(b.match_id) as bookings
from matches m left join bookings b
on m.id = b.match_id
group by m.id
order by m.id;


-- Bookings per match by World Cup

select t.year, count(b.match_id) / count(distinct m.id) as avg_bookings_per_match
from matches m join tournaments t
on m.tournament_id = t.id
left join bookings b
on m.id = b.match_id
group by t.year;


-- Bookings by half

select
case 
	when minutes between 0 and 45 then 'first half'
	when minutes between 46 and 90 then 'second half'
    else 'extra time / stoppage'
end as parts,
    count(*) as bookings
from bookings
group by parts;


-- Most booked teams

select t.name, count(*) as bookings 
from bookings b join teams t
on b.team_id = t.id
group by b.team_id
order by bookings desc;


/* ====================================
   Section 4: Tournament Analysis
   ==================================== */
   
-- Host win percentage

select round(100 * (sum(
case 
	when winner = host then 1 else 0 
end) / count(*)),2) as host_win_percentage
from tournaments;


-- Most goals in a single world cup

select t.year, count(*) as goals 
from goals g join matches m
on g.match_id = m.id
join tournaments t
on m.tournament_id = t.id
group by t.year
order by goals desc;


-- Number of own goals of every World Cup

select t.year, count(*) as own_goals
from goals g join matches m
on g.match_id = m.id and g.og = 1
join tournaments t
on m.tournament_id = t.id
group by t.year
order by own_goals desc;


-- Running total goals by World Cup

with goals_counts as (
select t.year, count(*) as goals
from goals g join matches m
on g.match_id = m.id
join tournaments t
on m.tournament_id = t.id
group by t.year
)
select year, goals, sum(goals) over (order by year) as run_total_goals
from goals_counts;


/* ====================================
   Section 5: Player Analysis
   ==================================== */
   
-- Age view

create view age_at_wc as 
select * , latest_wc - year(bod) as age_at_wc 
from players 
where bod is not null and year(bod) < latest_wc;


-- Oldest player

select given_name, family_name, age_at_wc
from age_at_wc
where age_at_wc in (select max(age_at_wc) from age_at_wc);


-- Youngest Player

select given_name, family_name, age_at_wc
from age_at_wc
where age_at_wc in (select min(age_at_wc) from age_at_wc);


/* ====================================
   Section 6: Men vs Women Comparison
   ==================================== */

-- Average goals per match

select t.type, round(sum(m.home_score + m.away_score) / count(distinct m.id),2) as avg_goals_per_match
from matches m join tournaments t
on m.tournament_id = t.id
group by t.type;


-- Average goals per World Cup

select t.type, sum(m.home_score + m.away_score) / count(distinct m.tournament_id) as avg_goals_per_tournaments
from matches m join tournaments t
on m.tournament_id = t.id
group by t.type;


-- Average bookings per match

select t.type, count(b.match_id) / count(distinct m.id) as avg_bookings_per_match 
from matches m join tournaments t
on m.tournament_id = t.id
left join bookings b
on m.id = b.match_id 
group by t.type;


-- Average bookings per World Cup

with bookings_count_by_tournament as (
select m.tournament_id, count(b.match_id) as bookings 
from matches m left join bookings b
on m.id = b.match_id
group by m.tournament_id
)
select t.type, round(avg(bookings),2) as avg_bookings_per_world_cup
from bookings_count_by_tournament b join tournaments t
on b.tournament_id = t.id
group by t.type;


-- Host win percentage

select type,
round(100 * (sum(
case 
	when host = winner then 1 else 0
end) / count(*)),2) as host_win_percentage
from tournaments
group by type;