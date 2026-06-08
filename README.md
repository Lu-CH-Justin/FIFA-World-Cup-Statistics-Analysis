<h1 align="center"> FIFA World Cup Statistics Analysis </h1>

![Image Alt](https://ichef.bbci.co.uk/ace/standard/976/cpsprodpb/f015/live/d2e52270-2c4a-11f1-934f-036468834728.jpg.webp)

## 
**Tools Used**: Excel, MySQL

**Dataset used**: [The Fjelstul World Cup Database](https://github.com/jfjelstul/worldcup)

Citation:
> Fjelstul, Joshua C. *The Fjelstul World Cup Database* (v1.2.0). July 19, 2023.

The source dataset contains many tables and attributes. For this project, I selected the columns most relevant to tournament, team, player, match, goal, and disciplinary analysis, and organized them into a simplified relational database schema optimized for exploration and analysis.

## Motivation

As I continue developing my skills in data analytics, I wanted to work on a project that would allow me to apply SQL in a practical setting while exploring a topic I am genuinely passionate about. As a football fan, the FIFA World Cup provides a fascinating dataset filled with historical records, player performances, team achievements, and tournament trends spanning decades.

Through this project, I designed and analyzed a World Cup database using SQL, with the goal of transforming raw data into meaningful insights. The project applies database design and analytical SQL techniques to uncover historical trends, player performance patterns, and tournament-level insights from FIFA World Cup data.

## Project Overview

The FIFA World Cup Database is a comprehensive collection of historical tournament data covering both the Men's FIFA World Cup (1930 - 2022) and Women's FIFA World Cups (1991 - 2022). The dataset contains information on tournaments, matches, teams, players, goals, and disciplinary records, providing a rich foundation of over 1,000 matches and 10,000 players through 30 editions of World Cups for exploration and analysis.

### What's Included
- Teams: 88 National teams that have participated in World Cup tournaments.
- Tournaments: Information of historical FIFA World Cup tournaments from both Men's and Women's competitions.
- Goals: Data on over 3,600 goals event data across World Cup matches.
- Players: Details of over 10,000 players including position and World Cup appearances.
- Matches: More than 1,200 recorded matches from every World Cup.
- Bookings: Yellow and red card records across World Cup matches.

## Database Schema

![Image Alt](https://www.image2url.com/r2/default/images/1780835897149-83f78e18-97b9-4e56-a4ee-9d9767b25ed9.png)

## Analysis Questions

### Goal Scoring Analysis
- Who are the highest goal scorers in World Cup history?
- Which teams have scored the most goals?
- Which region has produced the most goals?
- Who was the top scorer in each World Cup?
- How do goals vary by player position?
- How many goals were penalties vs non-penalties?

### Match Analysis

- Which World Cup had the highest scoring matches?
- What is the average goals per match by tournament?
- How many matches were played in each stage?

### Discipline Analysis

- Which teams received the most bookings?
- How are bookings distributed across match minutes?
- What is the average number of bookings per match?

### Tournament Analysis

- How often does the host nation go on to win the tournament?
- Which World Cups recorded the highest total number of goals?
- How has cumulative goal scoring evolved throughout World Cup history?

### Player Analysis

- Who are the oldest players to participate in a World Cup?
- Who are the youngest players to participate in a World Cup?
- Which players have appeared in the most World Cup tournaments?

### Men's vs Women's World Cup Comparison

- How does the average number of goals per match compare between competitions?
- How does the average number of goals per tournament compare?
- How does the average number of bookings per match compare?

## Sample Queries

### Top scorer per World Cup
```SQL
with goals_stats as (
select g.tid, p.pid, p.pfname, p.plname, count(*) as goals,
dense_rank() over (partition by tid order by count(*) desc) as rnk
from goals g join players p
on g.pid = p.pid and g.og = 0
group by g.tid, p.pid
order by tid, goals desc
)
select * 
from goals_stats 
where rnk = 1;
```
Result:

<img width="500" alt="image" src="https://github.com/user-attachments/assets/85cbd147-1f6b-46d3-8957-2b9cb297b328" />


### Top goal scoring regions
```SQL
select t.region, count(*) as goals 
from teams t join goals g 
on t.teamid = g.teamid and g.og = 0
group by t.region 
order by goals desc;
```
Result:

<img width="300" alt="image" src="https://github.com/user-attachments/assets/f715f85b-c1bc-4531-97ec-96c367672853" />


### Average goals per match
```SQL
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
```

Result:

<img width="500" alt="image" src="https://github.com/user-attachments/assets/d3d75728-270b-4e77-b697-f01c6134c7e4" />

### Booking by half
```SQL
select
case 
	when minutes between 0 and 45 then 'first half'
	when minutes between 46 and 90 then 'second half'
    else 'extra time'
end as parts,
    count(*) as bookings
from bookings
group by parts;
```

Result:

<img width="500" alt="image" src="https://github.com/user-attachments/assets/f872668b-3fb7-4181-a28d-0fb6c33d9278" />

### Running total goals by World Cup
```SQL
with goals_counts as (
select t.year, count(*) as goals
from goals g join tournaments t
on g.tid = t.tid
group by t.year
order by t.year
)
select year, goals, sum(goals) over (order by year) as run_total_goals
from goals_counts;
```

Result:

<img alt="image" src="https://github.com/user-attachments/assets/953f4d4c-7158-43ba-8d1b-7b0b7ba1785c" width='500'/>

### Average goals per match (Men vs Women)
```SQL
select t.type, round(count(*) / count(distinct g.mid),2) as avg_goals_per_match
from goals g join matches m
on g.mid = m.mid
join tournaments t
on g.tid = t.tid
group by t.type;
```

Result:

<img width="500" alt="image" src="https://github.com/user-attachments/assets/4c699c59-24f8-47d3-be76-2642a422c95f" />

### The complete set of 28 analysis queries can be found in `sql/analysis.sql`

## Key Findings

- Brazil emerged as the highest-scoring nation in World Cup history.
- Goal scoring was more frequent in the second half than in the first half.
- Host nations won only a small percentage of World Cups despite the perceived home advantage.
- Forwards accounted for the majority of goals scored across tournaments.
- Men's and Women's World Cups exhibited different scoring and disciplinary patterns.

## Conclusion

Through the analysis of historical FIFA World Cup data, several interesting patterns and trends emerged. The project identified the most prolific goal scorers, highest-scoring teams and regions, tournament-specific top scorers, and differences in scoring patterns across player positions and match periods. The analysis also revealed insights into disciplinary trends, host nation performance, player demographics, and long-term scoring trends throughout World Cup history.

By comparing Men's and Women's FIFA World Cups, the project highlighted differences in scoring rates, disciplinary records, and tournament outcomes while providing a broader perspective on the evolution of international football competitions. Overall, the project demonstrates how historical football data can be used to uncover meaningful patterns, compare performances across eras, and provide a deeper understanding of the factors that have shaped the FIFA World Cup throughout its history.
