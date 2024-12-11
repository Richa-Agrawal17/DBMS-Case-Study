-- 1.	Show the percentage of wins of each bidder in the order of highest to lowest percentage.
	-- Table Used
        select * from ipl_bidding_details;
		select * from ipl_bidder_details;
		select * from ipl_bidder_points;
	-- Query
		with bid_wins as (
			select bidding_d.bidder_id,count(bidding_d.bid_status) wins
			from ipl_bidding_details bidding_d
			where bidding_d.bid_status = 'Won'
			group by bidding_d.bidder_id
		)
		select bidder_d.*,(bid_wins.wins/bidder_p.no_of_bids)*100 percentage from bid_wins
		join ipl_bidder_points bidder_p on bid_wins.bidder_id = bidder_p.bidder_id
		join ipl_bidder_details bidder_d on bidder_p.bidder_id = bidder_d.bidder_id
		order by percentage desc;

-- 2.	Display the number of matches conducted at each stadium with the stadium name and city.
	-- Table Used
		select * from ipl_match_schedule;
		select * from ipl_stadium;
	-- Query
		select ms.STADIUM_ID,s.STADIUM_NAME,s.CITY,count(ms.MATCH_ID) total_matches_played
		from ipl_match_schedule ms join ipl_stadium s 
		on ms.STADIUM_ID = s.STADIUM_ID
		group by ms.STADIUM_ID,s.STADIUM_NAME,s.CITY;

-- 3.	In a given stadium, what is the percentage of wins by a team that has won the toss?
	-- Table Used
		select * from ipl_match;
		select * from ipl_stadium;
		select * from ipl_match_schedule;
	-- Query
        select s.STADIUM_NAME,
        (sum(case 
			when m.TOSS_WINNER = m.MATCH_WINNER
            then 1 else 0
            end)/count(*))*100 percentage_of_wins
        from ipl_match m join ipl_match_schedule ms on m.MATCH_ID = ms.MATCH_ID
        join ipl_stadium s on ms.STADIUM_ID = s.STADIUM_ID
        group by s.STADIUM_NAME
        order by 1;

-- 4.	Show the total bids along with the bid team and team name.
	-- Table Used
		select * from ipl_team;
		select * from ipl_bidder_points;
		select * from ipl_bidding_details;
	-- Query
        select bd.BID_TEAM,t.TEAM_NAME,sum(bp.no_of_bids)
        from ipl_bidder_points bp join ipl_bidding_details bd on bp.bidder_id = bd.bidder_id
        join ipl_team t on bd .BID_TEAM = t.TEAM_ID
        group by bd.BID_TEAM,t.TEAM_NAME;

-- 5.	Show the team ID who won the match as per the win details.
	-- Table Used
		select * from ipl_team;
		select * from ipl_match;
	-- Query
		SELECT
			m.MATCH_ID,
			m.TEAM_ID1,
			t1.TEAM_NAME AS TEAM1_NAME,
			m.TEAM_ID2,
			t2.TEAM_NAME AS TEAM2_NAME,
			m.MATCH_WINNER AS WINNER_TEAM_IDS
		FROM
			ipl_match m
		LEFT JOIN
			ipl_team t1 ON m.TEAM_ID1 = t1.TEAM_ID
		LEFT JOIN
			ipl_team t2 ON m.TEAM_ID2 = t2.TEAM_ID;

-- 6.	Display the total matches played, total matches won and total matches lost by the team along with its team name.
	-- Table Used
		select * from ipl_team;
        select * from ipl_team_standings;
	-- Query
		select t.TEAM_ID,t.TEAM_NAME,sum(MATCHES_PLAYED) total_matches_played,sum(MATCHES_WON) total_match_won,sum(MATCHES_LOST) total_match_lost
        from ipl_team t join ipl_team_standings ts
        on t.TEAM_ID = ts.TEAM_ID
        group by TEAM_ID;

-- 7.	Display the bowlers for the Mumbai Indians team.
	-- Table Used
        select * from ipl_team;
        select * from ipl_team_players;
        select * from ipl_player;
	-- Query
        select t.team_name,tp.Player_ID,p.Player_name
        from ipl_team t join ipl_team_players tp
        on t.TEAM_ID = tp.TEAM_ID
        join ipl_player p on tp.Player_id = p.Player_id
        where t.TEAM_ID = (select team_id from ipl_team where team_name = 'Mumbai Indians') and tp.Player_Role = 'Bowler';
        
-- 8.	How many all-rounders are there in each team, Display the teams with more than 4 all-rounders in descending order.
	-- Table Used	
        select * from ipl_team;
        select * from ipl_team_players;
	-- Query
        select t.TEAM_ID,count(*) No_of_ALLROUNDER from ipl_team t join ipl_team_players tp
        on t.TEAM_ID = tp.TEAM_ID
        where tp.Player_Role = 'All-Rounder'
        group by t.TEAM_ID
        having count(*) > 4
        order by No_of_ALLROUNDER desc;
        
-- 9.	 Write a query to get the total bidders' points for each bidding status of those bidders who bid on CSK when they won the match in M. Chinnaswamy Stadium bidding year-wise.
--  Note the total bidders’ points in descending order and the year is the bidding year.
--                Display columns: bidding status, bid date as year, total bidder’s points
	-- Table Used
		select * from ipl_stadium;
		select * from ipl_match_schedule;
		select * from ipl_match;
		select * from ipl_Bidding_Details;
		select * from ipl_bidder_points;
		select * from ipl_Bidder_Details;
	-- Query
		select bd.bid_status,year(bid_date),sum(Total_Points) bidder_points
		from ipl_stadium s join ipl_match_schedule ms
		on s.stadium_ID = ms.stadium_ID 
		join ipl_match m on ms.Match_id = m.Match_id
		join ipl_Bidding_Details bd on ms.SCHEDULE_ID = bd.SCHEDULE_ID
		join ipl_bidder_points bp on bd.Bidder_ID = bp.Bidder_ID
		join ipl_Bidder_Details bidderD on bd.Bidder_id = bidderD.Bidder_id
		where s.STADIUM_NAME = 'M. Chinnaswamy Stadium' and m.win_details like '%CSK won%'
		group by bd.bid_status,year(bid_date)
		order by bidder_points desc;

-- 10.	Extract the Bowlers and All-Rounders that are in the 5 highest number of wickets.
-- Note 
-- 1. Use the performance_dtls column from ipl_player to get the total number of wickets
--  2. Do not use the limit method because it might not give appropriate results when players have the same number of wickets
-- 3.	Do not use joins in any cases.
-- 4.	Display the following columns teamn_name, player_name, and player_role.
	-- Table Used	
		select * from IPL_TEAM;
		select * from IPL_TEAM_PLAYERS;
		select * from IPL_PLAYER;
	-- Query
		with temp as (
        SELECT 
			T.TEAM_NAME,
			P.PLAYER_NAME,
			TP.PLAYER_ROLE,
			substr(P.PERFORMANCE_DTLS,instr(P.PERFORMANCE_DTLS,'Wkt-')+4,2) AS WICKETS,
			DENSE_RANK() OVER (ORDER BY substr(P.PERFORMANCE_DTLS,instr(P.PERFORMANCE_DTLS,'Wkt-')+4,2) DESC) AS max_RANK
		FROM 
			IPL_TEAM T,
			IPL_TEAM_PLAYERS TP,
			IPL_PLAYER P
		WHERE 
			T.TEAM_ID = TP.TEAM_ID
			AND TP.PLAYER_ID = P.PLAYER_ID
			AND (TP.PLAYER_ROLE = 'Bowler' OR TP.PLAYER_ROLE = 'All-Rounder')
		)
        select TEAM_NAME,
			PLAYER_NAME,
			PLAYER_ROLE,WICKETS,max_RANK from temp where max_RANK <= 5;

-- 11.	show the percentage of toss wins of each bidder and display the results in descending order based on the percentage
	-- Table Used
		select * from ipl_bidding_details;
		select * from ipl_match;
		select * from ipl_match_schedule;
	-- Query
		with temp as (
		select bd.bidder_ID,count(m.TOSS_WINNER) toss_won_count_of_each_bidder
		from ipl_bidding_details bd join ipl_match_schedule ms 
		on bd.Schedule_ID = ms.Schedule_ID
		join ipl_match m on ms.MATCH_ID = m.MATCH_ID
		group by bd.bidder_ID
		)
		select bidder_ID,sum(toss_won_count_of_each_bidder) as total_toss_won_count,
        (sum(toss_won_count_of_each_bidder) * 100/ sum(toss_won_count_of_each_bidder) over()) as percentage
        from temp 
        group by bidder_ID order by percentage desc;

-- 12.	find the IPL season which has a duration and max duration.
-- 	Output columns should be like the below:
--  Tournment_ID, Tourment_name, Duration column, Duration
	-- Table Used
		select * from ipl_tournament;
    -- Query
		with temp as (
		select TOURNMT_ID, TOURNMT_NAME,datediff(To_date,From_date) Duration_Column from ipl_tournament
		) select TOURNMT_ID, TOURNMT_NAME,Duration_Column,first_value(Duration_Column) over(order by Duration_Column desc) from temp;

-- 13.	Write a query to display to calculate the total points month-wise for the 2017 bid year. sort the results based on total points in descending order and month-wise in ascending order.
-- Note: Display the following columns:
-- 1.	Bidder ID, 2. Bidder Name, 3. Bid date as Year, 4. Bid date as Month, 5. Total points
-- Only use joins for the above query queries.
	-- Table Used
		select * from ipl_bidding_details;
		select * from ipl_bidder_points;
		select * from ipl_bidder_details;
	-- Query
		select bidder_d.bidder_id Bidder_ID, bidder_d.BIDDER_NAME Bidder_Name , year(Bid_date) Bid_Year,month(bid_date) Bid_Month,sum(bp.total_points) total_point
        from ipl_bidding_details bd join ipl_bidder_points bp
		on bd.bidder_id = bp.bidder_id
        join ipl_bidder_details bidder_d
        on bp.bidder_id = bidder_d.bidder_id
        where year(bid_date) = 2017
        group by bidder_d.bidder_id,bidder_d.BIDDER_NAME,year(Bid_date),month(bid_date)
        order by total_point desc, month(bid_date) asc;

-- 14.	Write a query for the above question using sub-queries by having the same constraints as the above question.
		-- Table Used
			select * from ipl_bidding_details;
			select * from ipl_bidder_points;
			select * from ipl_bidder_details;
        -- Query
			SELECT 
				bidder_d.bidder_id AS Bidder_ID,
				bidder_d.BIDDER_NAME AS Bidder_Name,
				inner_query_result.Bid_Year,
				inner_query_result.Bid_Month,
				inner_query_result.total_point
			FROM (
				SELECT 
					bd.bidder_id,
					YEAR(bd.Bid_date) AS Bid_Year,
					MONTH(bd.Bid_date) AS Bid_Month,
					SUM(bp.total_points) AS total_point
				FROM ipl_bidding_details bd
				JOIN ipl_bidder_points bp ON bd.bidder_id = bp.bidder_id
				WHERE YEAR(bd.Bid_date) = 2017
				GROUP BY bd.bidder_id, YEAR(bd.Bid_date), MONTH(bd.Bid_date)
			) AS inner_query_result
			JOIN ipl_bidder_details bidder_d ON inner_query_result.bidder_id = bidder_d.bidder_id
			ORDER BY inner_query_result.total_point DESC, inner_query_result.Bid_Month ASC;
        
-- 15.	Write a query to get the top 3 and bottom 3 bidders based on the total bidding points for the 2018 bidding year.
-- Output columns should be:
-- like
-- Bidder Id, Ranks (optional), Total points, Highest_3_Bidders --> columns contains name of bidder, Lowest_3_Bidders  --> columns contains name of bidder;
		-- Table Used
			select * from ipl_bidder_points;
			select * from ipl_bidding_details;
			select * from ipl_bidder_details;
		-- Query
			SELECT DISTINCT bidder_id, total_point, Highest_to_Lowest_rank
			FROM (
					select bd.bidder_id,sum(total_points) total_point, dense_rank() over(order by sum(total_points) desc) Highest_to_Lowest_rank
					from ipl_bidder_points bp join ipl_bidding_details bidding_d 
					on bp.bidder_id = bidding_d.bidder_id
					join ipl_bidder_details bd
					on bidding_d.bidder_id = bd.bidder_id
					where year(bidding_d.bid_date) = 2018
					group by bd.bidder_id
				) 
			as temp where Highest_to_Lowest_rank <= 3
			union 
			SELECT DISTINCT bidder_id, total_point, Lowest_to_Highest_rank
			FROM (
					select bd.bidder_id,sum(total_points) total_point, dense_rank() over(order by sum(total_points)) Lowest_to_Highest_rank
					from ipl_bidder_points bp join ipl_bidding_details bidding_d 
					on bp.bidder_id = bidding_d.bidder_id
					join ipl_bidder_details bd
					on bidding_d.bidder_id = bd.bidder_id
					where year(bidding_d.bid_date) = 2018
					group by bd.bidder_id
				) 
				as temp1 
				where Lowest_to_Highest_rank <= 3;
        
        
		
		
