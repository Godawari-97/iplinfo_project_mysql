create database ipl_info;
use ipl_info;

show variables like 'secure_file_priv';

show global variables like 'local_infile';
set global local_infile=1;
set global local_infile=0;
CREATE TABLE ipl_info (
    id INT,
    inning INT,
    ball_over INT,
    ball INT,
    batsman VARCHAR(255),
    non_striker VARCHAR(255),
    bowler VARCHAR(255),
    batsman_runs INT,
    extra_runs INT,
    total_runs INT,
    non_boundary INT,
    is_wicket INT,
    dismissal_kind VARCHAR(255),
    player_dismissed VARCHAR(255),
    fielder VARCHAR(255),
    extras_type VARCHAR(255),
    batting_team VARCHAR(255),
    bowling_team VARCHAR(255)
);
describe ipl_info;


LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\IPL_Ball-by-Ball_2008-2020.csv'
INTO TABLE ipl_info
FIELDS TERMINATED  BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

select * from ipl_info;
--- Basic Questions;

create index bat_ipl on ipl_info (batsman);
-- Filter rows where the batsman is 'BB McCullum'.
select * from ipl_info where batsman = 'BB McCullum';

-- Find all deliveries bowled by 'Z Khan'
select * from ipl_info  where bowler = 'Z Khan';

-- List distinct bowling teams
select distinct bowling_team from ipl_info;

-- Count the total number of deliveries in the dataset.
select  count(*) as total_deliveries from ipl_info;

-- Intermediate Questions

-- Calculate total runs scored by each batsman.
select batsman, sum(batsman_runs) as total_score from ipl_info
 group by batsman order by total_score desc;
 
--  Find the number of wickets taken by each bowler
 select bowler, count(is_wicket) as num__of_wicket from 
 ipl_info group by bowler order by num__of_wicket desc;
 
 select * from ipl_info;
 -- Get the total extras conceded by each bowling team.
 select bowling_team, sum(extra_runs) as total_extra_run from ipl_info 
 group by  bowling_team order by total_extra_run desc;
 
 
--  Retrieve data for the 6th over of the first inning.
select  * from ipl_info  where inning = 1 and ball_over = 6 limit 5;

create index index_ball on ipl_info (total_runs);
-- Identify bowlers who gave more than 10 runs in a single over
select bowler, ball_over, count(total_runs) as more_runs from ipl_info group by  bowler, ball_over
having count(total_runs) >10;


-- Advanced Questions

-- Find the strike rate of each batsman
select batsman, sum(batsman_runs) as total_runs , count(*) as total_ball,
round(sum(batsman_runs) * 100.0 / count(*) ,2) as strike_rate  from ipl_info 
group by batsman order by strike_rate desc;

-- Calculate the economy rate of each bowler.
select bowler, sum(total_runs) as total_runs from ipl_info
 group by bowler order by total_runs desc;
 
 
 SELECT bowler, 
       SUM(total_runs) AS runs_conceded, 
       COUNT(*) / 6 AS overs_bowled, 
       ROUND(SUM(total_runs) / (COUNT(*) / 6), 1) AS economy_rate
FROM ipl_info 
GROUP BY bowler 
ORDER BY economy_rate ASC;


-- Identify the top 3 batsmen with the highest boundaries (4s and 6s)
select batsman, sum(non_boundary) as highest_boundry from ipl_info  
group by batsman
having  sum(non_boundary) >3
order by highest_boundry desc;



-- Find the most common dismissal kind
select max(dismissal_kind) as most_diskind from ipl_info
 order by most_diskind desc;  


-- Identify the match-winning team by comparing total runs scored
 select bowling_team, batting_team, sum(total_runs) as total_runs from ipl_info  
 group by bowling_team, batting_team order by total_runs  desc;


-- Which batsman has scored the most runs in the given data?
select batsman, sum(batsman_runs) as total_runs from ipl_info group by batsman
order by   total_runs desc limit 1;


--  Find the number of balls each batsman faced in the first innings.
select batsman, count(ball) as ball_face from ipl_info where inning = 1
group by batsman order by ball_face  desc;

 

-- Which batsman faced the most balls in a single over?
select batsman, ball_over, count(ball) as ball_face from ipl_info  
group by batsman, ball_over order by ball_face desc limit 1;


--  Find the number of runs scored by batsmen, excluding boundaries (runs > 4)?
select batsman,
sum(case when batsman_runs > 4 then 0 else batsman_runs end) as runs_without_boundrie
from ipl_info group by batsman order by runs_without_boundrie desc limit 5;


-- Find the difference in runs between two consecutive deliveries faced by a batsman?
select batsman, ball, batsman_runs,  lead(batsman_runs,1,0),
 over(partition by batsman order by ball desc) as runs_dirrence from ipl_info;
 
 create index ball_over on ipl_info (ball_over);
--  Find the highest and lowest runs scored by a batsman in a single over?
select batsman, ball_over, max(batsman_runs) highest_runs, min(batsman_runs) as lowest_runs from ipl_info
group by batsman, ball_over;


--  Identify the overs in which a batsman scored the maximum number of runs?
select batsman, ball_over, batsman_runs,
rank() over(partition by batsman order by batsman_runs) as rank_runs
from ipl_info where batsman_runs = 1;


--  Calculate the absolute difference between runs scored in consecutive balls for each batsman?
 select batsman, ball, abs(batsman_runs - lead(batsman_runs, 1,0) over(partition by batsman order by ball)) as abc_run_differrence
 from ipl_info;



--  Identify if a batsman faced more than 10 balls in an over using CASE statement
select batsman, ball_over,
case when count(ball) > 10 then 'more than 10 ball'
else  'less than 10 ball'
end as ball_over_status
from ipl_info
group by batsman, ball_over;
 select * from ipl_info;
 
 
 -- Calculate the number of deliveries between two consecutive wickets for a batsman
 select batsman, ball,
 case when is_wicket = 1 then 
 ball - (lead(batsman,1,0) over(partition by batsman order by ball))
else null end  as delliveri_between_wickets  from ipl_info;
 

 select * from ipl_info;



-- Find the top run-scorers or wicket-takers?

SELECT player_name, SUM(runs_scored) AS total_runs
FROM players
GROUP BY player_name
ORDER BY total_runs DESC
LIMIT 5;
select batsman,sum(batsman_runs) as total_runs 
from ipl_info 
group by batsman order by total_runs desc limit 20;

select max(is_wicket)as maximum_wicket
from ipl_info
ORDER BY is_wicket desc
limit 5; 
select * from ipl_info;
-- Calculate the total runs scored and wickets taken by a specific team ?
SELECT batting_team,SUM(total_runs) AS total_runs,
    SUM(is_wicket) AS total_wicket
    from ipl_info
    group by batting_team
    order by total_runs,total_wicket desc;
    
select * from  ipl_info;


-- Identify the teams with the highest and lowest averages in a particular year.
SELECT BATTING_team, avg(extra_runs) average_extra_runs
FROM ipl_info
group by batting_team
ORDER BY batting_team DESC
LIMIT 1;
select * from ipl_info;
select batsman,sum(batsman_runs) as sum_batsmam
from ipl_info
group by batsman, count(batsman_runs);


