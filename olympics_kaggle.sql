-- source : https://www.kaggle.com/datasets/heesoo37/120-years-of-olympic-history-athletes-and-results
use olympics_kaggle;
select * from athlete_events;
select * from noc_regions;

-- How many olympics games have been held?
select count(distinct games) total_games_held from athlete_events;

-- List down all Olympics games held so far.
select distinct year,season,city from athlete_events
order by year;

-- Mention the total no of nations who participated in each olympics game?
with countries as
              (select games, region
              from athlete_events a
              join noc_regions nr 
              ON nr.noc=a.noc
              group by games, region)
select games, count(*) countries_participated 
from countries
group by 1
order by 1;

-- Which year saw the highest and lowest no of countries participating in olympics?
with countries as
              (select games, region
              from athlete_events a
              join noc_regions nr 
              ON nr.noc=a.noc
              group by games, region),
country_count as (select games, count(*) countries_participated 
from countries
group by 1
order by 1)
select 'highest_no_of_countries_participated' as criteria, games,  countries_participated  from country_count
where countries_participated  = (select max(countries_participated ) from country_count)
union
select 'lowest_no_of_countries_participated' as criteria, games, countries_participated  from country_count
where countries_participated  = (select min(countries_participated ) from country_count);

-- select distinct concat(first_value(games) over(order by countries_participated)
--       , ' - ',
--       first_value(countries_participated) over(order by countries_participated)) as Lowest_Countries
--       , concat(first_value(games) over(order by countries_participated desc)
--       , ' - ',first_value(countries_participated) over(order by countries_participated desc)) as Highest_Countries
--       from country_count
--       order by 1;

-- Which nation has participated in all of the olympic games?
with countries as
              (select games, region
              from athlete_events a
              join noc_regions nr 
              ON nr.noc=a.noc
              group by games, region),
game_count as (select region, count(*) games_participated 
from countries
group by 1)
select region participated_in_all_games from game_count 
where games_participated = (select count(distinct games) from athlete_events);

-- Identify the sport which was played in all summer olympics.
with game_count as (select sport, count(distinct games) games_participated
from athlete_events	
group by 1)
select sport played_in_all_games from game_count 
where games_participated = (select count(distinct games) from athlete_events where season = 'Summer');

-- Which Sports were just played only once in the olympics?
with game_count as (select sport, count(distinct games) games_participated
from athlete_events
group by 1)
select distinct g.sport played_only_in_one_game, games from game_count g
join athlete_events	a
on a.sport = g.sport
where games_participated = 1
order by 1;

-- Fetch the total no of sports played in each olympic games.
select games, count(distinct sport) sports
from athlete_events
group by 1
order by 2 desc;

-- Fetch details of the oldest athletes to win a gold medal.
select * from athlete_events
where medal = 'gold' and
age = (select max(age) from athlete_events where medal = 'gold');

-- Find the Ratio of male and female athletes participated in all olympic games.
select concat('1:',round(max(ath_count)/min(ath_count),2)) M_F_ratio
from
(select sex, count(*) ath_count
from athlete_events
group by 1) t;

-- Fetch the top 5 athletes who have won the most gold medals.
select name, team, gold_medals
from
(select *, dense_rank() over (order by gold_medals desc) rnk
from
(select name, team, count(medal) gold_medals
from athlete_events
where medal = 'gold'
group by 1,2) t) t1
where rnk <= 5;

-- Fetch the top 5 athletes who have won the most medals (gold/silver/bronze).
select name, team, medals
from
(select *, dense_rank() over (order by medals desc) rnk
from
(select name, team, count(medal) medals
from athlete_events
where medal <> 'NA'
group by 1,2) t) t1
where rnk <= 5;

-- Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won.
select region, medals
from
(select *, dense_rank() over (order by medals desc) rnk
from
(select region, count(medal) medals
from athlete_events a
join noc_regions nr
on a.noc = nr.noc
where medal <> 'NA'
group by 1) t) t1
where rnk <= 5;

-- List down total gold, silver and bronze medals won by each country.
select region, 
sum(case when medal = 'gold' then 1 else 0 end) gold_medals,
sum(case when medal = 'silver' then 1 else 0 end) silver_medals,
sum(case when medal = 'bronze' then 1 else 0 end) bronze_medals
from athlete_events a
join noc_regions nr
on a.noc = nr.noc
group by 1
order by 2 desc;

-- List down total gold, silver and broze medals won by each country corresponding to each olympic games.
select games, region, 
sum(case when medal = 'gold' then 1 else 0 end) gold_medals,
sum(case when medal = 'silver' then 1 else 0 end) silver_medals,
sum(case when medal = 'bronze' then 1 else 0 end) bronze_medals
from athlete_events a
join noc_regions nr
on a.noc = nr.noc
group by 1,2
order by 1,2;

-- Identify which country won the most gold, most silver and most bronze medals in each olympic games.
with medal_calc as (select games, region, 
sum(case when medal = 'gold' then 1 else 0 end) gold,
sum(case when medal = 'silver' then 1 else 0 end) silver,
sum(case when medal = 'bronze' then 1 else 0 end) bronze
from athlete_events a
join noc_regions nr
on a.noc = nr.noc
group by 1,2)
select distinct games, 
concat(first_value(region) over(partition by games order by gold desc), ' - ', first_value(gold) over(partition by games order by gold desc)) as Max_Gold,
concat(first_value(region) over(partition by games order by silver desc), ' - ', first_value(silver) over(partition by games order by silver desc)) as Max_Silver,
concat(first_value(region) over(partition by games order by bronze desc), ' - ', first_value(bronze) over(partition by games order by bronze desc)) as Max_Bronze
from medal_calc;

-- Identify which country won the most gold, most silver, most bronze medals and the most medals in each olympic games.
with medal_calc as (select games, region, 
sum(case when medal = 'gold' then 1 else 0 end) gold,
sum(case when medal = 'silver' then 1 else 0 end) silver,
sum(case when medal = 'bronze' then 1 else 0 end) bronze,
sum(case when medal <> 'NA' then 1 else 0 end) total_medals
from athlete_events a
join noc_regions nr
on a.noc = nr.noc
group by 1,2)
select distinct games, 
concat(first_value(region) over(partition by games order by gold desc), ' - ', first_value(gold) over(partition by games order by gold desc)) as Max_Gold,
concat(first_value(region) over(partition by games order by silver desc), ' - ', first_value(silver) over(partition by games order by silver desc)) as Max_Silver,
concat(first_value(region) over(partition by games order by bronze desc), ' - ', first_value(bronze) over(partition by games order by bronze desc)) as Max_Bronze,
concat(first_value(region) over(partition by games order by total_medals desc), ' - ', first_value(total_medals) over(partition by games order by total_medals desc)) as Max_medals
from medal_calc;

-- Which countries have never won gold medal but have won silver/bronze medals?
with medal_calc as (select region, 
sum(case when medal = 'gold' then 1 else 0 end) gold,
sum(case when medal = 'silver' then 1 else 0 end) silver,
sum(case when medal = 'bronze' then 1 else 0 end) bronze
from athlete_events a
join noc_regions nr
on a.noc = nr.noc
group by 1)
select *
from medal_calc
where gold = 0 and (silver > 0 or bronze > 0)
order by 1;

-- In which Sport/event, India has won highest medals.
select sport, count(medal) medals
from athlete_events a
join noc_regions nr
on a.noc = nr.noc
where medal <> 'NA' 
and region = 'India'
group by 1
order by 2 desc
limit 1;

-- Break down all olympic games where india won medal for Hockey and how many medals in each olympic games.
select games, count(medal) medals
from athlete_events a
join noc_regions nr
on a.noc = nr.noc
where medal <> 'NA' 
and region = 'India'
and sport = 'Hockey'
group by 1
order by 2 desc;