/* Advanced SQL */

/* Write a query that shows the duration of each ride as a percentage of the total time accrued by riders from each start_terminal */
SELECT start_terminal,
       duration_seconds,
       SUM(duration_seconds) OVER (PARTITION BY start_terminal) AS start_terminal_sum,
       (duration_seconds/SUM(duration_seconds) OVER (PARTITION BY start_terminal))*100 AS pct_of_total_time
  FROM tutorial.dc_bikeshare_q1_2012
 WHERE start_time < '2012-01-08'
 ORDER BY 1, 4 DESC

 /* Write a query that shows a running total of the duration of bike rides, 
 grouped by end_terminal, and with ride duration sorted in descending order. */
 SELECT start_terminal,
      end_terminal,
      duration_seconds,
       SUM(duration_seconds) OVER
         (PARTITION BY end_terminal ORDER BY duration_seconds DESC)
         AS running_total
  FROM tutorial.dc_bikeshare_q1_2012
 WHERE start_time < '2012-01-08'
 
 /* ROW_NUMBER() */
SELECT start_terminal,
       start_time,
       duration_seconds,
       ROW_NUMBER() OVER (PARTITION BY start_terminal
                          ORDER BY start_time)
                    AS row_number
  FROM tutorial.dc_bikeshare_q1_2012
 WHERE start_time < '2012-01-08'

/* RANK() */
SELECT start_terminal,
       duration_seconds,
      RANK() OVER (PARTITION BY start_terminal
                    ORDER BY start_time)
              AS rank
  FROM tutorial.dc_bikeshare_q1_2012
 WHERE start_time < '2012-01-08'
 
 /* Write a query that shows the 5 longest rides from each starting terminal, ordered by terminal, 
 and longest to shortest rides within each terminal. Limit to rides that occurred before Jan. 8, 2012.*/
SELECT *
FROM (
  SELECT start_terminal,
      duration_seconds,
      DENSE_RANK() OVER (PARTITION BY start_terminal ORDER BY start_terminal, duration_seconds DESC) AS rank
  FROM tutorial.dc_bikeshare_q1_2012
  WHERE start_time < '2012-01-08') AS sub
WHERE sub.rank <= 5

/* Write a query that shows only the duration of the trip and the percentile into which 
that duration falls (across the entire dataset). */
SELECT start_terminal,
       duration_seconds,
       NTILE(100) OVER (ORDER BY duration_seconds) AS percentile
  FROM tutorial.dc_bikeshare_q1_2012
 WHERE start_time < '2012-01-08'
 ORDER BY start_terminal, duration_seconds

/* LAG and LEAD - 1 */
SELECT start_terminal,
       duration_seconds,
       LAG(duration_seconds, 1) OVER
         (PARTITION BY start_terminal ORDER BY duration_seconds) AS lag,
       LEAD(duration_seconds, 1) OVER
         (PARTITION BY start_terminal ORDER BY duration_seconds) AS lead
  FROM tutorial.dc_bikeshare_q1_2012
 WHERE start_time < '2012-01-08'
 ORDER BY start_terminal, duration_seconds
 
/* LAG and LEAD - 2 */
SELECT start_terminal,
       duration_seconds,
       duration_seconds - LAG(duration_seconds, 1) OVER
         (PARTITION BY start_terminal ORDER BY duration_seconds)
         AS difference
  FROM tutorial.dc_bikeshare_q1_2012
 WHERE start_time < '2012-01-08'
 ORDER BY start_terminal, duration_seconds
 
 SELECT *
  FROM (
    SELECT start_terminal,
           duration_seconds,
           duration_seconds -LAG(duration_seconds, 1) OVER
             (PARTITION BY start_terminal ORDER BY duration_seconds)
             AS difference
      FROM tutorial.dc_bikeshare_q1_2012
     WHERE start_time < '2012-01-08'
     ORDER BY start_terminal, duration_seconds
       ) sub
 WHERE sub.difference IS NOT NULL

/* Window Alias Definition */
SELECT start_terminal,
       duration_seconds,
       NTILE(4) OVER ntile_window AS quartile,
       NTILE(5) OVER ntile_window AS quintile,
       NTILE(100) OVER ntile_window AS percentile
  FROM tutorial.dc_bikeshare_q1_2012
 WHERE start_time < '2012-01-08'
WINDOW ntile_window AS
         (PARTITION BY start_terminal ORDER BY duration_seconds)
 ORDER BY start_terminal, duration_seconds

/* Performance Tuning SQL Queries - Explain */
EXPLAIN
SELECT *
  FROM benn.sample_event_table
 WHERE event_date >= '2014-03-01'
   AND event_date < '2014-04-01'
 LIMIT 100

/* Pivoting rows to columns */
SELECT conference,
       SUM(players) AS total_players,
       SUM(CASE WHEN year = 'FR' THEN players ELSE NULL END) AS fr,
       SUM(CASE WHEN year = 'SO' THEN players ELSE NULL END) AS so,
       SUM(CASE WHEN year = 'JR' THEN players ELSE NULL END) AS jr,
       SUM(CASE WHEN year = 'SR' THEN players ELSE NULL END) AS sr
  FROM (
        SELECT teams.conference AS conference,
               players.year,
               COUNT(1) AS players
          FROM benn.college_football_players players
          JOIN benn.college_football_teams teams
            ON teams.school_name = players.school_name
         GROUP BY 1,2
       ) sub
 GROUP BY 1
 ORDER BY 2 DESC
 
/* Pivoting columns to rows */
SELECT years.*,
       earthquakes.magnitude,
       CASE year
         WHEN 2000 THEN year_2000
         WHEN 2001 THEN year_2001
         WHEN 2002 THEN year_2002
         WHEN 2003 THEN year_2003
         WHEN 2004 THEN year_2004
         WHEN 2005 THEN year_2005
         WHEN 2006 THEN year_2006
         WHEN 2007 THEN year_2007
         WHEN 2008 THEN year_2008
         WHEN 2009 THEN year_2009
         WHEN 2010 THEN year_2010
         WHEN 2011 THEN year_2011
         WHEN 2012 THEN year_2012
         ELSE NULL END
         AS number_of_earthquakes
  FROM tutorial.worldwide_earthquakes earthquakes
 CROSS JOIN (
       SELECT year
         FROM (VALUES (2000),(2001),(2002),(2003),(2004),(2005),(2006),
                      (2007),(2008),(2009),(2010),(2011),(2012)) v(year)
       ) years
       
/* Write a query that selects all Warrant Arrests from the tutorial.sf_crime_incidents_2014_01 dataset, 
then wrap it in an outer query that only displays unresolved incidents. */
SELECT sub.*
  FROM (
        SELECT *
        FROM tutorial.sf_crime_incidents_2014_01
        WHERE descript = 'WARRANT ARREST'
        ) AS sub
  WHERE sub.resolution = 'NONE'

/* Write a query that displays the average number of monthly incidents for each category. */
SELECT sub.category,
       FLOOR(AVG(sub.incidents)) AS avg_incidents_per_month
  FROM (
        SELECT EXTRACT('month' FROM cleaned_date) AS month,
               category,
               COUNT(incidnt_num) AS incidents
          FROM tutorial.sf_crime_incidents_cleandate
         GROUP BY 1,2
       ) sub
 GROUP BY 1
 ORDER BY 2 DESC
 
/* Write a query that displays all rows from the three categories with the fewest incidents reported. */
SELECT incidents.*,
       sub.incident_counts AS total_incidents_counts_in_category
  FROM tutorial.sf_crime_incidents_2014_01 incidents
  JOIN  (SELECT category,
          COUNT(incidnt_num) AS incident_counts
          FROM tutorial.sf_crime_incidents_2014_01 incidents
          GROUP BY 1
          ORDER BY 2
          LIMIT 3 ) AS sub
    ON incidents.category = sub.category
    
/* Write a query that counts the number of companies founded and acquired by quarter starting in Q1 2012.
Create the aggregations in two separate queries, then join them. */
SELECT COALESCE(company.quarter, acquisitions.quarter) AS quarter,
       company.founded_company_count,
       acquisitions.acquired_company_count
  FROM ( 
      SELECT founded_quarter AS quarter,
            COUNT(DISTINCT permalink) AS founded_company_count
      FROM tutorial.crunchbase_companies
      WHERE founded_year >= 2012
      GROUP BY 1) AS company
FULL JOIN (
        SELECT acquired_quarter AS quarter,
              COUNT(DISTINCT company_permalink) AS acquired_company_count
        FROM tutorial.crunchbase_acquisitions 
        WHERE acquired_year >= 2012
        GROUP BY 1) AS acquisitions
    ON company.quarter = acquisitions.quarter
  ORDER BY 1;
  
/* Write a query that ranks investors from the combined dataset by the total number of investments they have made. */
SELECT sub.investor_name,
       COUNT(sub.investor_permalink) AS total_num_investments
  FROM (
        SELECT *
          FROM tutorial.crunchbase_investments_part1

         UNION ALL

        SELECT *
          FROM tutorial.crunchbase_investments_part2
       ) sub
  
  GROUP BY 1
  ORDER BY 2 DESC;
  
/* Write a query that ranks investors from the combined dataset by the total number of investments 
they have made but for companies that are still operating.*/
SELECT sub.investor_name,
       COUNT(sub.investor_permalink) AS total_num_investments
  FROM (
        SELECT *
          FROM tutorial.crunchbase_investments_part1

         UNION ALL

        SELECT *
          FROM tutorial.crunchbase_investments_part2
       ) sub
  JOIN tutorial.crunchbase_companies AS companies
  ON sub.company_permalink = companies.permalink
  WHERE companies.status = 'operating'
  GROUP BY 1
  ORDER BY 2 DESC;
/* Alternative to above */  
SELECT investments.investor_name,
       COUNT(investments.*) AS investments
  FROM tutorial.crunchbase_companies companies
  JOIN (
        SELECT *
          FROM tutorial.crunchbase_investments_part1
         
         UNION ALL
        
         SELECT *
           FROM tutorial.crunchbase_investments_part2
       ) investments
    ON investments.company_permalink = companies.permalink
 WHERE companies.status = 'operating'
 GROUP BY 1
 ORDER BY 2 DESC
 
 /* Concatenate the lat and lon fields to form a field that is equivalent to the location field. 
(Note that the answer will have a different decimal precision.) */
SELECT location,
      lat,
      lon,
      CONCAT('(',lat, ',',lon,')') AS lat_long
  FROM tutorial.sf_crime_incidents_2014_01;

/* Create the same concatenated location field, but using the || syntax instead of CONCAT. */
SELECT location,
      lat,
      lon,
      '(' || lat || ',' || lon || ')' AS lat_long
  FROM tutorial.sf_crime_incidents_2014_01;
  
/* Write a query that creates a date column formatted YYYY-MM-DD. */
SELECT date,
    SUBSTR(date, 7, 4)||'-'||SUBSTR(date, 4, 2)||'-'||SUBSTR(date, 1, 2) AS formatted_date
  FROM tutorial.sf_crime_incidents_2014_01;
  
SELECT incidnt_num,
       address,
       UPPER(address) AS address_upper,
       LOWER(address) AS address_lower
  FROM tutorial.sf_crime_incidents_2014_01;
  
/* Write a query that returns the `category` field, but with the first letter capitalized and the rest of the letters in lower-case */
SELECT category,
      UPPER(SUBSTR(category, 1, 1)) || LOWER(SUBSTR(category, 2, LENGTH(category)-1)) AS cap_category
  FROM tutorial.sf_crime_incidents_2014_01;

/* Write a query that creates an accurate timestamp using the date and time columns in tutorial.sf_crime_incidents_2014_01. 
Include a field that is exactly 1 week later as well. */

SELECT incidnt_num,
       (SUBSTR(date, 7, 4) || '-' || LEFT(date, 2) ||
        '-' || SUBSTR(date, 4, 2) || ' ' || time || ':00')::timestamp AS timestamp,
       (SUBSTR(date, 7, 4) || '-' || LEFT(date, 2) ||
        '-' || SUBSTR(date, 4, 2) || ' ' || time || ':00')::timestamp
        + INTERVAL '1 week' AS timestamp_plus_interval
  FROM tutorial.sf_crime_incidents_2014_01
  
/* Write a query that counts the number of incidents reported by week. 
Cast the week as a date */
SELECT (DATE_TRUNC('week', cleaned_date)) ::date AS week,
  COUNT(incidnt_num) AS incidents
  FROM tutorial.sf_crime_incidents_cleandate
  GROUP BY 1
  ORDER BY 1;

/* Date & Time */
SELECT CURRENT_DATE AS date,
       CURRENT_TIME AS time,
       CURRENT_TIMESTAMP AS timestamp,
       LOCALTIME AS localtime,
       LOCALTIMESTAMP AS localtimestamp,
       NOW() AS now
SELECT CURRENT_TIME AS time,
       CURRENT_TIME AT TIME ZONE 'PST' AS time_pst

/* Write a query that shows exactly how long ago each indicent was reported. 
Assume that the dataset is in Pacific Standard Time (UTC - 8). */

SELECT incidnt_num,
       cleaned_date,
       NOW() AT TIME ZONE 'PST' AS now,
       NOW() AT TIME ZONE 'PST' - cleaned_date AS time_ago 
  FROM tutorial.sf_crime_incidents_cleandate
  ORDER BY 2

/* Coalesce */
SELECT incidnt_num,
       descript,
       COALESCE(descript, 'No Description')
  FROM tutorial.sf_crime_incidents_cleandate
 ORDER BY descript DESC

/* Write a query that separates the `location` field into separate fields for latitude and longitude. */
SELECT location,
       TRIM(leading '(' FROM LEFT(location, POSITION(',' IN location) - 1)) AS lattitude,
       TRIM(trailing ')' FROM RIGHT(location, LENGTH(location) - POSITION(',' IN location) ) ) AS longitude
  FROM tutorial.sf_crime_incidents_2014_01

/* Write a query that counts the number of companies acquired within 3 years, 5 years, and 10 years of being founded (in 3 separate columns). 
Include a column for total companies acquired as well. Group by category and limit to only rows with a founding date. */
SELECT companies.category_code,
       COUNT(CASE WHEN acquisitions.acquired_at_cleaned <= companies.founded_at_clean::timestamp + INTERVAL '3 years'
                       THEN 1 ELSE NULL END) AS three_yrs,
       COUNT(CASE WHEN acquisitions.acquired_at_cleaned <= companies.founded_at_clean::timestamp + INTERVAL '5 years'
                       THEN 1 ELSE NULL END) AS five_yrs,
       COUNT(CASE WHEN acquisitions.acquired_at_cleaned <= companies.founded_at_clean::timestamp + INTERVAL '10 years'
                       THEN 1 ELSE NULL END) AS ten_yrs,
       COUNT(DISTINCT companies.permalink) AS total_companies
  FROM tutorial.crunchbase_companies_clean_date companies
  INNER JOIN tutorial.crunchbase_acquisitions_clean_date acquisitions
  ON companies.permalink  = acquisitions.company_permalink
  WHERE companies.permalink IS NOT NULL
  GROUP BY 1
  ORDER BY 5 DESC;
 
 /* Dealing with Dates */
SELECT companies.permalink,
       companies.founded_at_clean,
       NOW() - companies.founded_at_clean::timestamp AS founded_time_ago
  FROM tutorial.crunchbase_companies_clean_date companies
 WHERE founded_at_clean IS NOT NULL
 ORDER BY 3 DESC;
 
 /* Dealing with Dates */
SELECT companies.permalink,
       companies.founded_at_clean,
       companies.founded_at_clean::timestamp +
         INTERVAL '1 week' AS plus_one_week
  FROM tutorial.crunchbase_companies_clean_date companies
 WHERE founded_at_clean IS NOT NULL

/* Dealing with Dates */
 SELECT companies.permalink,
       companies.founded_at_clean,
       acquisitions.acquired_at_cleaned,
       acquisitions.acquired_at_cleaned -
         companies.founded_at_clean::timestamp AS time_to_acquisition
  FROM tutorial.crunchbase_companies_clean_date companies
  JOIN tutorial.crunchbase_acquisitions_clean_date acquisitions
    ON acquisitions.company_permalink = companies.permalink
 WHERE founded_at_clean IS NOT NULL

/* Convert the funding_total_usd and founded_at_clean columns in the tutorial.crunchbase_companies_clean_date table
to strings (varchar format)*/
  SELECT CAST(funding_total_usd AS varchar) AS funding_total_usd_string,
       founded_at_clean::varchar AS founded_at_string
  FROM tutorial.crunchbase_companies_clean_date






 
 
 




