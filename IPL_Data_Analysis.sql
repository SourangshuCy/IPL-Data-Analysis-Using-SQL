# Top 5 Rows from ball_by_Ball Table

select * from ipl_data.ball_by_ball
limit 5;

# Top 5 Rows from matches Table

select * from ipl_data.matches
limit 5;

# Top 5 Rows from player Table

select * from ipl_data.player
limit 5;

# Top 5 Rows from season Table

select * from ipl_data.season
limit 5;

# Top 5 Rows from team Table
select * from ipl_data.team
limit 5;

# Find the top 10 batsman based on number of centuries.

select Player_name,
count(Player_name) as Centuries
from
(
select 
ipl_data.player.Player_Name as Player_name,
sum(ball_by_ball.Batsman_Scored) as Batsman_Scored
from ipl_data.player
right join ipl_data.ball_by_ball
on Player_Id=Striker_Id
group by Player_Name,Match_Id
having sum(Batsman_Scored)>=100
order by Batsman_Scored desc) as Batman_scored
group by Player_name
order by Centuries desc
limit 10;

# Find the top 10 batsman based on batting average (which is total runs by total matches played)

select Player_Name,
round(Batsman_Scored/Total_Matches,2) as Batting_Average
from
(select 
ipl_data.player.Player_Name as Player_name,
count(distinct(ball_by_ball.Match_Id)) as Total_Matches,
sum(ball_by_ball.Batsman_Scored) as Batsman_Scored
from ipl_data.player
right join ipl_data.ball_by_ball
on Player_Id=Striker_Id
group by Player_Name
order by Batsman_Scored desc) as Players_Runs
group by Player_Name
order by Batting_Average desc
limit 10;


#. What is the percentage of matches won by team winning the toss

select
Total_Match_Toss.Team_Name as Team_name,
Total_Match_Toss.Toss_won_Match as Toss_won_Match,
Toss_won_match_won.Toss_won_Match_Won as Toss_won_Match_Won,
round((Toss_won_Match_Won/Toss_won_Match)*100,2) as Match_win_perc
from
(select
ipl_data.team.Team_Id as Team_Id,
ipl_data.team.Team_Name as Team_Name,
count(ipl_data.matches.Toss_Winner_Id) as Toss_won_Match
from 
ipl_data.team
right join ipl_data.matches
on Team_Id=Toss_Winner_Id
group by Team_Name ) as Total_Match_Toss
inner join
(select 
ipl_data.team.Team_Id as Team_Id,
ipl_data.team.Team_Name as Team_Name,
count(Team_Name) as Toss_won_Match_Won
from 
ipl_data.team
right join ipl_data.matches
on Team_Id=Match_Winner_Id
where Toss_Winner_Id=Match_Winner_Id
group by Team_Name) as Toss_won_match_won
on Total_Match_Toss.Team_Id=Toss_won_match_won.Team_Id
group by Team_name
order by Match_win_perc desc;

# Find the total number of IPL title win for each team

select 
Team_Name,
count(Team_Name) as IPL_title_win
from
(select
ipl_data.matches.Season_Id,
ipl_data.team.Team_Name
from
ipl_data.matches
inner join 
ipl_data.team
on Team_Id=Match_Winner_Id
where Match_Date in (
select Final_Date from
(select 
ipl_data.matches.Season_Id as Season_Id,
max(ipl_data.matches.Match_Date) as Final_Date
from
ipl_data.matches
where Season_Id in (select Season_Id from ipl_data.season)
group by Season_Id) as Final)
) as Team_won
group by Team_Name
order by IPL_title_win desc;

# Considering that a match score of greater than 300 is treated as "High Scoring Match",
# and match score less than or equal to 300 is treated as "Low scoring match".

select 
ipl_data.ball_by_ball.Match_Id as Match_ID,
sum(ipl_data.ball_by_ball.Batsman_Scored) as Match_Score,
if(sum(ipl_data.ball_by_ball.Batsman_Scored)<=300,"Low scoring match","High Scoring Match") as Match_type
from
ipl_data.ball_by_ball
group by Match_ID
order by Match_Score desc;

# which season has the highest percentage of high scoring matches?

select
Total_matches.Season as Season,
Total_matches.Total_match as Total_match,
Total_High_Scoring_matches.Total_High_Scoring_match as Total_High_Scoring_match,
round((Total_High_Scoring_match/Total_match)*100,2) as High_Scoring_match_perc
from
(select
Season,
count(Match_ID) as Total_match
from
(select 
ipl_data.ball_by_ball.Season_Id as Season,
ipl_data.ball_by_ball.Match_Id as Match_ID,
sum(ipl_data.ball_by_ball.Batsman_Scored) as Match_Score,
if(sum(ipl_data.ball_by_ball.Batsman_Scored)<=300,"Low scoring match","High Scoring Match") as Match_type
from
ipl_data.ball_by_ball
group by Match_ID
order by Match_Score desc) as Match_Score_Type
group by Season) as Total_matches
inner join
(select
Season,
count(Match_type) as Total_High_Scoring_match
from
(select 
ipl_data.ball_by_ball.Season_Id as Season,
ipl_data.ball_by_ball.Match_Id as Match_ID,
sum(ipl_data.ball_by_ball.Batsman_Scored) as Match_Score,
if(sum(ipl_data.ball_by_ball.Batsman_Scored)<=300,"Low scoring match","High Scoring Match") as Match_type
from
ipl_data.ball_by_ball
group by Match_ID
order by Match_Score desc) as Match_Score_Type
where Match_type="High Scoring Match"
group by Season) as Total_High_Scoring_matches
on Total_matches.Season=Total_High_Scoring_matches.Season
order by High_Scoring_match_perc desc;

# Find the percentage match win for Winning the toss and fielding first.

select
Total_Match_TossWon_Field.Team_Name as Team_name,
Total_Match_TossWon_Field.Total_matches as Total_Match_TossWon_Field,
Toss_won_match_won_Field.TossWon_MatchWon_FieldFirst as TossWon_MatchWon_FieldFirst,
round((TossWon_MatchWon_FieldFirst/Total_Matches)*100,2) as Match_win_perc
from
(select
ipl_data.team.Team_Id as Team_Id,
ipl_data.team.Team_Name as Team_Name,
count(ipl_data.team.Team_Name) as Total_matches
from 
ipl_data.team
right join ipl_data.matches
on Team_Id=Toss_Winner_Id
where Toss_Decision="field"
group by Team_Name ) as Total_Match_TossWon_Field
inner join
(select 
ipl_data.team.Team_Id as Team_Id,
ipl_data.team.Team_Name as Team_Name,
count(Team_Name) as TossWon_MatchWon_FieldFirst
from 
ipl_data.team
right join ipl_data.matches
on Team_Id=Match_Winner_Id
where Toss_Winner_Id=Match_Winner_Id and Toss_Decision="field"
group by Team_Name) as Toss_won_match_won_Field
on Total_Match_TossWon_Field.Team_Id=Toss_won_match_won_Field.Team_Id
group by Team_name
order by Match_win_perc desc;

# Find the percentage match win for playing at home ground.

select
Home_Match.Team_Name as Team_name,
Home_Match.Total_Matches_home as Total_Matches_home,
Home_win.Match_won_Home as Match_won_Home,
round((Match_won_Home/Total_Matches_home)*100,2) as Match_win_perc
from
(select
ipl_data.team.Team_Name as Team_Name,
max(home_match.Total_Matches) as Total_Matches_home
from
ipl_data.team
inner join
(select
ipl_data.ball_by_ball.Team_Batting_Id as Team,
ipl_data.matches.City_Name as City,
count(distinct(ball_by_ball.Match_Id)) as Total_Matches
from 
ipl_data.matches
right join ipl_data.ball_by_ball
on matches.Match_Id=ball_by_ball.Match_Id
group by Team,City) as home_match
on Team_Id=Team
group by Team_Name) as Home_Match
inner join
(select 
ipl_data.team.Team_Name as Team_Name,
count(ipl_data.team.Team_Name) as Match_won_Home
from
ipl_data.team
right join ipl_data.matches
on Team_Id=Match_Winner_Id
where City_Name=
case
when Team_Name ="Kolkata Knight Riders" then "Kolkata"           
when Team_Name ="Royal Challengers Bangalore" then "Bangalore"
when Team_Name ="Chennai Super Kings" then "Chennai"
when Team_Name ="Kings XI Punjab" then "Chandigarh"
when Team_Name ="Rajasthan Royals" then "Jaipur"
when Team_Name ="Delhi Daredevils" then "Delhi"
when Team_Name ="Mumbai Indians" then "Mumbai"
when Team_Name ="Deccan Chargers" then "Hyderabad"
when Team_Name ="Kochi Tuskers Kerala" then "Kochi"
when Team_Name ="Pune Warriors" then "Pune"
when Team_Name ="Sunrisers Hyderabad" then "Hyderabad"
when Team_Name ="Rising Pune Supergiants" then "Pune"
when Team_Name ="Gujarat Lions" then "Rajkot"
end
group by Team_Name) as Home_win
on Home_Match.Team_Name=Home_win.Team_Name
order by Match_win_perc desc;

#Find the bowler who has given maximum extra runs in IPL History

select 
ipl_data.player.Player_Name as Baller_name,
sum(ipl_data.ball_by_ball.Extra_Runs) as Total_Extra_runs
from
ipl_data.player
right join
ipl_data.ball_by_ball
on Player_Id=Bowler_Id
group by Baller_name
order by Total_Extra_runs desc
limit 10;

#percentage of matches won by CSK (Chennai Super King) under the following 
#conditions: Suresh Raina scoring a fifty and above

select
AllMatches_CSK_Skraina.Team_Name,
AllMatches_CSK_Skraina.AllMatches_CSK_SkrainaScMrTh50 as AllMatches_CSK_SkrainaScMrTh50,
CSK_Wins.CSK_win as Matches_won,
round((CSK_Wins.CSK_win/AllMatches_CSK_Skraina.AllMatches_CSK_SkrainaScMrTh50)*100,2) as Match_win_per
from
(select
CSK_all_matches.Team_Name as Team_Name,
count(CSK_all_matches.Team_Name) as AllMatches_CSK_SkrainaScMrTh50
from
(select
distinct
ipl_data.team.Team_Id as Team_Id,
ipl_data.team.Team_Name as Team_Name,
ipl_data.ball_by_ball.Match_ID as matches
from
ipl_data.team
right join
ipl_data.ball_by_ball
on Team_Id=Team_Batting_Id
where ipl_data.team.Team_Name="Chennai Super Kings" ) as CSK_all_matches
inner join
(select
ipl_data.ball_by_ball.Match_ID as matches, 
ipl_data.player.Player_Name as Player_Name,
sum(ipl_data.ball_by_ball.Batsman_Scored) as Batsman_Scored
from ipl_data.player
right join ipl_data.ball_by_ball
on Player_Id=Striker_Id
where Player_Name="SK Raina"
group by matches,Player_Name) as SKRaina_all_matches
on CSK_all_matches.matches=SKRaina_all_matches.matches
where SKRaina_all_matches.Batsman_Scored>=50) as AllMatches_CSK_Skraina
inner join
(select
CSK_wins.Team_Name as Team_Name,
count(CSK_wins.Team_Name) as CSK_win
from
(select
ipl_data.matches.Match_ID as Match_ID,
ipl_data.team.Team_Name as Team_Name
from
ipl_data.team
right join
ipl_data.matches
on Team_Id=Match_Winner_Id
where Team_Name="Chennai Super Kings") CSK_wins
inner join
(select
ipl_data.ball_by_ball.Match_ID as matches, 
ipl_data.player.Player_Name as Player_Name,
sum(ipl_data.ball_by_ball.Batsman_Scored) as Batsman_Scored
from ipl_data.player
right join ipl_data.ball_by_ball
on Player_Id=Striker_Id
where Player_Name="SK Raina"
group by matches,Player_Name
having sum(ipl_data.ball_by_ball.Batsman_Scored)>=50) as Raina_Matches
on CSK_wins.Match_ID=Raina_Matches.matches
group by Team_Name) as CSK_Wins
on AllMatches_CSK_Skraina.Team_Name=CSK_Wins.Team_Name;