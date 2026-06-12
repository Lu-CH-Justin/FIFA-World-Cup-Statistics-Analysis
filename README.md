<h1 align="center"> FIFA World Cup Statistics Analysis </h1>

![Image Alt](https://ichef.bbci.co.uk/ace/standard/976/cpsprodpb/f015/live/d2e52270-2c4a-11f1-934f-036468834728.jpg.webp)

## 
**Tools Used**: MySQL, Python (Pandas, SQLAlchemy)

**Dataset used**: [The Fjelstul World Cup Database](https://github.com/jfjelstul/worldcup)

Citation:
> Fjelstul, Joshua C. *The Fjelstul World Cup Database* (v1.2.0). July 19, 2023.

The source dataset contains many tables and attributes. For this project, I selected the columns most relevant to tournament, team, player, match, goal, and disciplinary analysis, and organized them into a simplified relational database schema optimized for exploration and analysis.

## Motivation

As I continue developing my skills in data analytics, I wanted to work on a project that would allow me to apply SQL in a practical setting while exploring a topic I am genuinely passionate about. As a football fan, the FIFA World Cup provides a great dataset filled with historical records, player performances, team achievements, and tournament trends spanning decades.

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

<img width="1085" height="819" alt="image" src="https://github.com/user-attachments/assets/b0f2b1dd-d846-454d-b059-a4db07dd829e" />

## ETL Process

To automate data ingestion and preparation, a Python ETL pipeline was developed using Pandas and SQLAlchemy.

### Extract

* Retrieved CSV datasets directly from the Fjelstul World Cup Database GitHub repository.
* Loaded tournament, team, player, match, goal, and booking data into Pandas DataFrames.

### Transform

* Selected only the columns relevant to the project schema.
* Renamed columns to align with database naming conventions.
* Derived player positions from positional indicators.
* Created a `latest_wc` field to identify each player's most recent World Cup appearance.
* Classified tournaments as Men's or Women's competitions.
* Standardized and cleaned missing or unavailable values.

### Load

* Loaded transformed datasets into a normalized MySQL database using SQLAlchemy.
* Enforced primary key and foreign key relationships through the database schema.
* Prepared the data for analytical SQL querying.

## Skills Demonstrated

- ETL Pipeline Development
- Data Cleaning & Transformation
- Data Modeling
- Database Normalization
- Joins
- Aggregate Functions
- Common Table Expressions (CTEs)
- Window Functions
- Views
- Ranking Functions

## Project Workflow

Raw CSV Files

↓

Python ETL (Pandas)

↓

MySQL Relational Database

↓

SQL Analysis Queries

↓

Insights & Findings

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
	select m.tournament_id,
	g.player_id,
	count(*) as goals,
	dense_rank() over (partition by m.tournament_id order by count(*) desc) as rnk
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
```
Result:

<img width="500" alt="image" src="https://github.com/user-attachments/assets/88e5c367-dad5-4641-9811-387bfdd00431" />


### Top goal scoring regions
```SQL
select t.region, count(*) as goals 
from teams t join goals g 
on t.id = g.team_id and g.og = 0
group by t.region 
order by goals desc;
```
Result:

<img width="300" alt="image" src="https://github.com/user-attachments/assets/c978dbaf-5f9a-4102-a419-c4408146fc49" />


### Average goals per match
```SQL
select t.year,
round(sum(home_score + away_score) / count(distinct m.id),2) as avg_goals_per_match
from matches m join tournaments t
on m.tournament_id = t.id
group by t.year;
```

Result:

<img width="500" alt="image" src="https://github.com/user-attachments/assets/e269ec48-2325-4b31-bb3a-504fa11a39bd" />

### Booking by half
```SQL
select
case 
	when minutes between 0 and 45 then 'first half'
	when minutes between 46 and 90 then 'second half'
    else 'extra time / stoppage'
end as parts,
    count(*) as bookings
from bookings
group by parts;
```

Result:

<img width="500" alt="image" src="https://github.com/user-attachments/assets/58034f85-5b97-4122-80af-969e576b1326" />


### Running total goals by World Cup
```SQL
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
```

Result:

<img width="500" alt="image" src="https://github.com/user-attachments/assets/16e567a9-e104-4e9a-a226-c04b131e2d4f" />

### Average goals per match (Men vs Women)
```SQL
select t.type,
round(sum(m.home_score + m.away_score) / count(distinct m.id),2) as avg_goals_per_match
from matches m join tournaments t
on m.tournament_id = t.id
group by t.type;
```

Result:

<img width="500" alt="image" src="https://github.com/user-attachments/assets/a9694fb7-64c8-44b2-8b06-5e53bc20344c" />

### The complete set of 28 analysis queries can be found in `analysis.sql`

## Key Findings

- Brazil recorded the highest number of goals in World Cup history.
- Europe produced the largest share of World Cup goals among all regions.
- Goal scoring was more frequent in the second half than in the first half.
- Host nations won only a small percentage of World Cups despite the home advantage.
- Men's and Women's World Cups exhibited different scoring and disciplinary patterns.

## Conclusion

Through the analysis of historical FIFA World Cup data, several interesting patterns and trends emerged. The project identified the most prolific goal scorers, highest-scoring teams and regions, tournament-specific top scorers, and differences in scoring patterns across player positions and match periods. The analysis also revealed insights into disciplinary trends, host nation performance, player demographics, and long-term scoring trends throughout World Cup history.

In addition to analytical querying, the project demonstrates a complete data workflow by integrating Python-based ETL processes with relational database design and SQL analysis. This approach enabled raw World Cup data to be transformed into a structured analytical database capable of supporting meaningful exploration and reporting.
