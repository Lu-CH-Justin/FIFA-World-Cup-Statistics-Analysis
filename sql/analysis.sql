/* =============================================================================
   Section 1: Goal Scoring Analysis
   ============================================================================= */
   
-- Top goal scorers of all time

select p.pid, p.pfname, p.plname, count(*) as goals 
from players p join goals g 
on p.pid = g.pid and g.og = 0
group by p.pid 
order by goals desc;


-- Top goal scoring teams of all time

select t.teamname, count(*) as goals 
from teams t join goals g 
on t.teamid = g.teamid and g.og = 0
group by g.teamid 
order by goals desc;


-- Top goal scoring regions of all time

select t.region, count(*) as goals 
from teams t join goals g 
on t.teamid = g.teamid and g.og = 0
group by t.region 
order by goals desc;


-- Most goal scorers of every world cup

with goals_stats as (
select g.tid, p.pid, p.pfname, p.plname, count(*) as goals, dense_rank() over (partition by tid order by count(*) desc) as rnk
from goals g join players p
on g.pid = p.pid and g.og = 0
group by g.tid, p.pid
order by tid, goals desc
)
select * 
from goals_stats 
where rnk = 1;


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
on p.pid = g.pid and g.og = 0
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
    else 'extra time'
end as parts,
    count(*) as goals
from goals
group by parts;


/* =============================================================================
   Section 2: Match Analysis
   ============================================================================= */
   
-- Matches per stage

select tid, stage_name, count(*) as matches 
from matches 
group by tid, stage_name 
order by tid desc, matches desc;


-- Most goals in a single match

with goals_counts_by_match as (
select g.mid, m.home_teamid, m.away_teamid, m.home_score, m.away_score, count(*) as goals
from goals g join matches m
on g.mid = m.mid
group by g.mid
order by goals desc
)
select g.mid, t1.teamname, t2.teamname, g.home_score, g.away_score, g.goals
from goals_counts_by_match g join teams t1 
on g.home_teamid = t1.teamid 
join teams t2 on g.away_teamid = t2.teamid;


-- Average goals per match by World Cup

with goals_by_match as (
select g.tid, g.mid, count(*) as goals
from goals g join matches m
on g.mid = m.mid
group by g.tid, g.mid
)
select t.year, round(avg(goals),2) as avg_goals_per_match
from goals_by_match g join tournaments t
on g.tid = t.tid
group by t.year;


/* =============================================================================
   Section 3: Discipline Analysis
   ============================================================================= */
   
-- Bookings by minute
   
select minutes, count(*) as bookings 
from bookings
group by minutes
order by minutes;


-- Bookings by match

select mid, count(*) as bookings 
from bookings 
group by mid
order by mid;


-- Bookings by match by World Cup

select t.year, count(*) / count(distinct mid) as avg_bookings_per_match
from bookings b join tournaments t
on b.tid = t.tid
group by t.year;


-- Bookings by half

select
case 
	when minutes between 0 and 45 then 'first half'
	when minutes between 46 and 90 then 'second half'
    else 'extra time'
    end as parts,
    count(*) as bookings
from bookings
group by parts;


-- Most booked teams

select t.teamname, count(*) as bookings 
from bookings b join teams t
on b.teamid = t.teamid
group by b.teamid
order by bookings desc;


/* =============================================================================
   Section 4: Tournament Analysis
   ============================================================================= */
   
-- Host win percentage

select round(100 * (sum(
case 
	when winner = host then 1 else 0 
end) / count(*)),2) as host_win_percentage
from tournaments;


-- Most goals in a single world cup

select t.year, count(*) as goals 
from goals g join tournaments t
on g.tid = t.tid
group by t.year
order by goals desc;


-- Number of own goals of every World Cup

select t.year, count(*) as own_goals
from goals g join tournaments t
on g.tid = t.tid
and g.og = 1
group by t.year
order by own_goals desc;


-- Running total goals by World Cup

with goals_counts as (
select t.year, count(*) as goals
from goals g join tournaments t
on g.tid = t.tid
group by t.year
order by t.year
)
select year, goals, sum(goals) over (order by year) as run_total_goals
from goals_counts;


/* =============================================================================
   Section 5: Player Analysis
   ============================================================================= */
   
-- Age view

create view age_at_wc as 
select * , latest_wc - year(bod) as age_at_wc 
from players 
where bod != 0000-00-00 and year(bod) < latest_wc;


-- Oldest player

select pfname, plname, age_at_wc
from age_at_wc
where age_at_wc in (select max(age_at_wc) from age_at_wc);


-- Youngest Player

select pfname, plname, age_at_wc
from age_at_wc
where age_at_wc in (select min(age_at_wc) from age_at_wc);


-- Most Apperances

select pfname, plname, wc_counts
from players
order by wc_counts desc;


/* =============================================================================
   Section 6: Men vs Women Comparison
   ============================================================================= */

-- Average goals per match

select t.type, round(count(*) / count(distinct g.mid),2) as avg_goals_per_match
from goals g join matches m
on g.mid = m.mid
join tournaments t
on g.tid = t.tid
group by t.type;


-- Average goals per World Cup
with goals_count_by_type as (
select g.tid, t.type, count(*) as goals 
from goals g join tournaments t
on g.tid = t.tid
group by g.tid
)
select type, round(avg(goals),2) as avg_goals_per_world_cup
from goals_count_by_type 
group by type;


-- Average bookings per match
select t.type, count(*) / count(distinct mid) as avg_bookings_per_match 
from bookings b join tournaments t 
on b.tid = t.tid 
group by t.type;


-- Average bookings per World Cup

with bookings_count_by_type as (
select b.tid, t.type, count(*) as bookings 
from bookings b join tournaments t
on b.tid = t.tid
group by b.tid
)
select type, round(avg(bookings),2) as avg_bookings_per_world_cup
from bookings_count_by_type 
group by type;


-- Host win percentage
select type,
round(100 * (sum(
case 
	when host = winner then 1 else 0
end) / count(*)),2) as host_win_percentage
from tournaments
group by type;
