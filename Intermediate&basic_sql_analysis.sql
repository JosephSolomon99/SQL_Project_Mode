/* Self joining tables */
SELECT DISTINCT japan_investments.company_name,
	   japan_investments.company_permalink
  FROM tutorial.crunchbase_investments_part1 japan_investments
  JOIN tutorial.crunchbase_investments_part1 gb_investments
    ON japan_investments.company_name = gb_investments.company_name
   AND gb_investments.investor_country_code = 'GBR'
   AND gb_investments.funded_at > japan_investments.funded_at
 WHERE japan_investments.investor_country_code = 'JPN'
 ORDER BY 1;

/* SQL joins on multiple keys */
SELECT companies.permalink,
       companies.name,
       investments.company_name,
       investments.company_permalink
  FROM tutorial.crunchbase_companies companies
  LEFT JOIN tutorial.crunchbase_investments_part1 investments
    ON companies.permalink = investments.company_permalink
   AND companies.name = investments.company_name;

/*. Write a query that shows 3 columns. The first indicates which dataset (part 1 or 2) the data comes from, 
the second shows company status, and the third is a count of the number of investors. */

SELECT 'investments_part1' AS dataset_name,
       companies.status,
       COUNT(DISTINCT investments.investor_permalink) AS investors
  FROM tutorial.crunchbase_companies companies
  LEFT JOIN tutorial.crunchbase_investments_part1 investments
    ON companies.permalink = investments.company_permalink
 GROUP BY 1,2

 UNION ALL
 
 SELECT 'investments_part2' AS dataset_name,
       companies.status,
       COUNT(DISTINCT investments.investor_permalink) AS investors
  FROM tutorial.crunchbase_companies companies
  LEFT JOIN tutorial.crunchbase_investments_part2 investments
    ON companies.permalink = investments.company_permalink
 GROUP BY 1,2;

/* Write a query that appends the two crunchbase_investments datasets(including duplicate values). 
Filter the first dataset to only companies with names that start with the letter "T", 
and filter the second to companies with names starting with "M" (both not case-sensitive). 
Only include the company_permalink, company_name, and investor_name columns. */

SELECT company_permalink,
       company_name,
       investor_name
  FROM tutorial.crunchbase_investments_part1
 WHERE company_name ILIKE 'T%'
 tutorial.crunchbase_investments_part1
 
 UNION ALL

SELECT company_permalink,
       company_name,
       investor_name
  FROM tutorial.crunchbase_investments_part2
 WHERE company_name ILIKE 'M%';

/* Write a query that joins tutorial.crunchbase_companies and tutorial.crunchbase_investments_part1 using a FULL JOIN.
Count up the number of rows that are matched/unmatched as in the previous example */

SELECT COUNT(CASE WHEN companies.permalink IS NOT NULL AND investments.company_permalink IS NULL
                  THEN companies.permalink ELSE NULL END) AS companies_only,
       COUNT(CASE WHEN companies.permalink IS NOT NULL AND investments.company_permalink IS NOT NULL
                  THEN companies.permalink ELSE NULL END) AS both_tables,
       COUNT(CASE WHEN companies.permalink IS NULL AND investments.company_permalink IS NOT NULL
                  THEN investments.company_permalink ELSE NULL END) AS investments_only
  FROM tutorial.crunchbase_companies companies
  FULL OUTER JOIN tutorial.crunchbase_investments_part1 investments
    ON companies.permalink = investments.company_permalink;

/* Count the number of unique companies (don't double-count companies) and unique acquired companies by state. 
Do not include results for which there is no state data, and order by the number of acquired companies from highest to lowest. */
SELECT companies.state_code,
       COUNT(DISTINCT companies.permalink) AS unique_companies,
       COUNT(DISTINCT acquisitions.company_permalink) AS unique_companies_acquired
  FROM tutorial.crunchbase_companies companies
  LEFT JOIN tutorial.crunchbase_acquisitions acquisitions
    ON companies.permalink = acquisitions.company_permalink
 WHERE companies.state_code IS NOT NULL
 GROUP BY 1
 ORDER BY 3 DESC;

    
/* Count the number of unique companies (don't double-count companies) and unique acquired companies by state. 
Do not include results for which there is no state data, and order by the number of acquired companies from highest to lowest. */
SELECT companies.state_code,
       COUNT(DISTINCT companies.permalink) AS unique_companies,
       COUNT(DISTINCT acquisitions.company_permalink) AS unique_companies_acquired
  FROM tutorial.crunchbase_companies companies
  RIGHT JOIN tutorial.crunchbase_acquisitions acquisitions
    ON companies.permalink = acquisitions.company_permalink
 WHERE companies.state_code IS NOT NULL
 GROUP BY 1
 ORDER BY 3 DESC;

/* Write a query that performs an inner join between the tutorial.crunchbase_acquisitions table 
and the tutorial.crunchbase_companies table, but instead of listing individual rows, count the number of non-null rows in each table. */
SELECT COUNT(companies.permalink) AS companies_rowcount,
       COUNT(acquisitions.company_permalink) AS acquisitions_rowcount
  FROM tutorial.crunchbase_companies companies
  INNER JOIN tutorial.crunchbase_acquisitions acquisitions
    ON companies.permalink = acquisitions.company_permalink;

/* Write a query that displays player names, school names and conferences for schools in the "FBS (Division I-A Teams)" division */
SELECT players.player_name, players.school_name, teams.conference
  FROM benn.college_football_players players
  INNER JOIN benn.college_football_teams teams
  ON teams.school_name = players.school_name
  WHERE teams.division = 'FBS (Division I-A Teams)';
/* Write a query that selects the school name, player name, position, and weight for every player in Georgia, ordered by weight (heaviest to lightest). */
SELECT players.school_name,
       players.player_name,
       players.position,
       players.weight
  FROM benn.college_football_players AS players
 WHERE players.state = 'GA'
 ORDER BY players.weight DESC;
 
/* Write a query that separately counts the number of unique values in the month column 
and the number of unique values in the `year` column */
SELECT COUNT(DISTINCT year) AS years_count,
       COUNT(DISTINCT month) AS months_count
  FROM tutorial.aapl_historical_stock_price;
  
/* Write a query that returns the unique values in the year column, in chronological order. */
SELECT DISTINCT year
  FROM tutorial.aapl_historical_stock_price
  ORDER BY 1 ASC;
  
/*  Write a query that counts the number of unique values in the month column for each year. */
SELECT year,
       COUNT(DISTINCT month) AS months_count
  FROM tutorial.aapl_historical_stock_price
 GROUP BY year
 ORDER BY year;

/* Write a query that shows the number of players at schools with names that start with A through M, 
and the number at schools with names starting with N - Z. */
SELECT state,
       COUNT(CASE WHEN year = 'FR' THEN 1 ELSE NULL END) AS fr_count,
       COUNT(CASE WHEN year = 'SO' THEN 1 ELSE NULL END) AS so_count,
       COUNT(CASE WHEN year = 'JR' THEN 1 ELSE NULL END) AS jr_count,
       COUNT(CASE WHEN year = 'SR' THEN 1 ELSE NULL END) AS sr_count,
       COUNT(state) AS total_players
  FROM benn.college_football_players
  GROUP BY state
  ORDER BY total_players DESC;

/* Write a query that shows the number of players at schools with names that start with A through M, 
and the number at schools with names starting with N - Z. */
SELECT CASE WHEN school_name < 'n' THEN 'A-M'
            WHEN school_name >= 'n' THEN 'N-Z'
            ELSE NULL END AS school_name_group,
       COUNT(1) AS players
  FROM benn.college_football_players
  GROUP BY 1;

/* Write a query that displays the number of players in each state, with FR, SO, JR, and SR players 
in separate columns and another column for the total number of players. Order results such that states with the most players come first.*/
SELECT state,
       COUNT(CASE WHEN year = 'FR' THEN 1 ELSE NULL END) AS fr_count,
       COUNT(CASE WHEN year = 'SO' THEN 1 ELSE NULL END) AS so_count,
       COUNT(CASE WHEN year = 'JR' THEN 1 ELSE NULL END) AS jr_count,
       COUNT(CASE WHEN year = 'SR' THEN 1 ELSE NULL END) AS sr_count,
       COUNT(state) AS total_players
  FROM benn.college_football_players
  GROUP BY state
  ORDER BY total_players DESC;
 
/* Write a query that calculates the combined weight of all underclass players (FR/SO) in California as well
as the combined weight of all upperclass players (JR/SR) in California */
SELECT CASE WHEN year IN ('FR','SO') THEN 'underclass_players'
            WHEN year IN ('JR','SR') THEN 'upperclass_players'
            ELSE NULL END AS class_group,
            SUM(weight) AS combined_weight
 FROM benn.college_football_players
 WHERE state = 'CA'
 GROUP BY 1;

/* Write a query that counts the number of 300lb+ players for each of the following regions: 
West Coast (CA, OR, WA), Texas, and Other (everywhere else) */
SELECT CASE WHEN state IN ('CA', 'OR', 'WA') THEN 'West Coast'
            WHEN state = 'TX' THEN 'Texas'
            ELSE 'Other' END AS regions,
            COUNT(1) AS players_count
  FROM benn.college_football_players
  WHERE weight > 300
  GROUP BY 1;
 
/* Write a query that selects all columns from benn.college_football_players and 
adds an additional column that displays the player's name if that player is a junior or senior */
SELECT *,
       CASE WHEN year IN ('JR', 'SR') THEN player_name ELSE NULL END AS upperclass_player_name
  FROM benn.college_football_players;
 
/* Write a query that includes players' names and a column that classifies them into four categories based on height. */
SELECT player_name,
       height,
       CASE WHEN height > 80 THEN 'over 80'
            WHEN height >= 70 AND height <= 80 THEN '70-80'
            WHEN height >= 60 AND height <= 70 THEN '60-70'
            ELSE '69 or under' END AS height_group
  FROM benn.college_football_players;
 
 /* Write a query that includes a column that is flagged "yes" when a player is from California, 
 and sort the results with those players first */
SELECT player_name,
       state,
       CASE WHEN state = 'CA' THEN 'yes'
            ELSE 'no' END AS is_cali
  FROM benn.college_football_players
  ORDER BY 3 DESC;
 
/* Write a query that calculates the lowest and highest prices that Apple stock achieved each month */
SELECT year,
    month,
    MIN(low) AS lowest_price,
    MAX(high) AS highest_price,
    MAX(high) - MIN(low) AS difference
  FROM tutorial.aapl_historical_stock_price
  GROUP BY 1,2
  ORDER BY 1,2;

/* Write a query to calculate the average daily price change in Apple stock, grouped by year */
SELECT year,
      AVG(close - open) AS price_change 
  FROM tutorial.aapl_historical_stock_price
  GROUP BY 1
  ORDER BY 1;
 
/* Calculate the total number of shares traded each month. */
SELECT year,
      month,
      SUM(volume) AS vol_total
 FROM tutorial.aapl_historical_stock_price
 GROUP BY year, month
 ORDER BY year, month;
 
/* Write a query that calculates the average daily trade volume for Apple stock */
SELECT AVG(volume) AS avg_volume
  FROM tutorial.aapl_historical_stock_price;
 
/* What was the highest single-day increase in Apple's share value */
SELECT MAX(close - open)
  FROM tutorial.aapl_historical_stock_price;
 
/* What was Apple's lowest stock price (at the time of this data collection) */
SELECT MIN(low) AS lowest_stock_price
  FROM tutorial.aapl_historical_stock_price;

/* Write a query to calculate the average opening price */
SELECT SUM(open)/COUNT(open) AS avg_open_price
  FROM tutorial.aapl_historical_stock_price;

SELECT AVG(open) AS avg_open_price
  FROM tutorial.aapl_historical_stock_price;

/* Write a query that determines counts of every single column. 
With these counts, can you tell which column has the most null values */
SELECT COUNT(date) AS date_count,
    COUNT(close) AS close_count,
    COUNT(high) AS high_count,
    COUNT(id) AS id_count,
    COUNT(low) AS low_count,
    COUNT(month) AS month_count,
    COUNT(open) AS open_count,
    COUNT(volume) AS volume_count,
    COUNT(year) AS year_count
FROM tutorial.aapl_historical_stock_price;

/* Write a query to count the number of non-null rows in the low column */
SELECT COUNT(low)
FROM tutorial.aapl_historical_stock_price;

/* Write a query that returns songs that ranked between 10 and 20 (inclusive) in 1993, 2003, or 2013. 
Order the results by year and rank, and leave a comment on each line of the WHERE clause to indicate what that line does */
SELECT *
  FROM tutorial.billboard_top_100_year_end
  WHERE year_rank BETWEEN 10 AND 20 
  AND year IN (1993, 2003, 2013) 
  ORDER BY year, year_rank;
  
/* Write a query that shows all rows for which T-Pain was a group member, 
ordered by rank on the charts, from lowest to highest rank (from 100 to 1) */
SELECT *
  FROM tutorial.billboard_top_100_year_end
  WHERE group_name ILIKE '%t-pain%'
  ORDER BY year_rank DESC;

/*Write a query that returns all rows from 2010 ordered by rank, with artists ordered alphabetically for each song */
SELECT *
  FROM tutorial.billboard_top_100_year_end
  WHERE year = 2010
  ORDER BY year_rank, artist;

/* Write a query that lists all top-100 recordings that feature Dr. Dre before 2001 or after 2009 */
SELECT *
  FROM tutorial.billboard_top_100_year_end
  WHERE group_name ILIKE '%Dr. Dre%'
  AND (year < 2001 OR year > 2009);

/* Write a query that returns all songs with titles that contain the word "California" in either the 1970s or 1990s */
SELECT *
  FROM tutorial.billboard_top_100_year_end
  WHERE song_name ILIKE '%california%'
  AND (year BETWEEN 1970 AND 1979 OR year BETWEEN 1990 AND 1999);
  
/* Write a query that returns all rows for top-10 songs that featured either Katy Perry or Bon Jovi. */
SELECT *
  FROM tutorial.billboard_top_100_year_end
  WHERE year_rank <= 10
  AND (artist ILIKE '%katy perry%' OR artist ILIKE '%bon jovi%');
  
/* Write a query that surfaces the top-ranked records in 1990, 2000, and 2010 */
SELECT *
  FROM tutorial.billboard_top_100_year_end
  WHERE year_rank = 1 
  AND year IN (1990, 2000, 2010);
  
/* Write a query that surfaces all rows for top-10 hits for which Ludacris is part of the Group */
SELECT *
  FROM tutorial.billboard_top_100_year_end
  WHERE year_rank <= 10 
  AND group_name ILIKE '%ludacris%';
  
/* Write a query that shows all of the rows for which song_name is null */
SELECT *
  FROM tutorial.billboard_top_100_year_end
  WHERE song_name IS NULL;

/* Write a query that shows all top 100 songs from January 1, 1985 through December 31, 1990 */
SELECT *
  FROM tutorial.billboard_top_100_year_end
  WHERE year BETWEEN 1985 AND 1990;
  
SELECT *
  FROM tutorial.billboard_top_100_year_end
  WHERE year >= 1985 AND year <= 1990;

/* Write a query that shows all of the entries for Elvis and M.C. Hammer */
SELECT *
  FROM tutorial.billboard_top_100_year_end
  WHERE artist IN ('Elvis Presley','M.C. Hammer','Hammer');
  
/* Write a query that calculates the percentage of all houses completed in the United States represented by each region. Only return results from the year 2000 and later */
SELECT year,
       month,
       (west/(west + northeast + south + midwest))* 100 AS West_perc, 
       (northeast/(west + northeast + south + midwest)) * 100 AS NorthEast_perc, 
       (south/(west + northeast + south + midwest)) * 100 AS South_perc, 
       (midwest/(west + northeast + south + midwest)) * 100 AS Midwest_perc
  FROM tutorial.us_housing_units
  WHERE year > 1999;
