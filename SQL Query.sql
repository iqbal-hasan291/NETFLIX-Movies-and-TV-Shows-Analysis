-- Netflix Analysis

DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
	show_id	VARCHAR(5),
	type    VARCHAR(10),
	title	VARCHAR(250),
	director VARCHAR(550),
	casts	VARCHAR(1050),
	country	VARCHAR(550),
	date_added	VARCHAR(55),
	release_year	INT,
	rating	VARCHAR(15),
	duration	VARCHAR(15),
	listed_in	VARCHAR(250),
	description VARCHAR(550)
);

-- Show Table
SELECT
	*
FROM
	NETFLIX;

-- Total Count
SELECT
	COUNT(*) AS TOTAL_CONTENT
FROM
	NETFLIX;

-- How many content we have?
SELECT
	COUNT(distinct type) AS Types
FROM
	NETFLIX;


-- 15 Business Problems & Solutions:

-- 1. Count the number of Movies vs TV Shows
SELECT
	TYPE,
	COUNT(SHOW_ID)
FROM
	NETFLIX
GROUP BY TYPE;


--2. Find the most common rating for movies and TV shows
WITH COMMON_RATING AS
	(
		SELECT
			RATING,
			TYPE,
			COUNT(*),
			RANK() OVER (PARTITION BY TYPE ORDER BY COUNT(*) DESC) AS RANK_RATING
		FROM
			NETFLIX
		GROUP BY 1,2
	)
SELECT
	TYPE,
	RATING
FROM
	COMMON_RATING
WHERE
	RANK_RATING = 1;


-- 3. List all movies released in a specific year (e.g., 2020)
SELECT
	*
FROM
	NETFLIX
WHERE
	RELEASE_YEAR = 2020
	AND TYPE = 'Movie';


--4. Find the top 5 countries with the most content on Netflix
WITH
	MOST_COUNTRIES AS
	(
		SELECT
			TRIM(UNNEST(STRING_TO_ARRAY(COUNTRY, ','))) AS NEW_COUNTRY,
			COUNT(SHOW_ID) AS TOTAL_CONTENT
		FROM
			NETFLIX
		GROUP BY 1
	)
SELECT
	*
FROM MOST_COUNTRIES
WHERE NEW_COUNTRY IS NOT NULL
ORDER BY TOTAL_CONTENT DESC
LIMIT 5;


-- 5. Identify the longest movie with title
WITH movie_durations AS (
    SELECT type,title, duration,
           CAST(SPLIT_PART(duration, ' ', 1) AS INTEGER) AS duration_minutes
    FROM netflix
    WHERE type = 'Movie' AND duration IS NOT NULL
)
SELECT type,title,duration_minutes
FROM movie_durations
ORDER BY duration_minutes DESC
LIMIT 1;



--6. Find content added in the last 5 years
SELECT
	*
FROM
	NETFLIX
WHERE
	EXTRACT(
		YEAR FROM
			TO_DATE(DATE_ADDED, 'Month DD,YYYY')) >= CURRENT_DATE -INTERVAL '5 years' 


--7. Write queryto find the top 3 directors who have directed the most number of movies on Netflix.
SELECT director_name, COUNT(*) AS movie_count
FROM (
    SELECT TRIM(unnest(string_to_array(director, ','))) AS director_name
    FROM netflix
    WHERE type = 'Movie'
      AND director IS NOT NULL
) AS sub
GROUP BY director_name
ORDER BY movie_count DESC
LIMIT 3;



-- 8. List all TV shows with more than 5 seasons
SELECT
	TYPE,
	DURATION
FROM
	NETFLIX
WHERE
	TYPE = 'TV Show'
	AND CAST(SPLIT_PART(DURATION, ' ', 1) AS INTEGER) > 5;


-- 9. Count the number of content items in each genre
SELECT
	UNNEST(STRING_TO_ARRAY(LISTED_IN, ',')) AS GENRE,
	COUNT(*) AS TOTAL_CONTENT
FROM
	NETFLIX
GROUP BY 1
ORDER BY TOTAL_CONTENT DESC
LIMIT 5;


/* 10. Find each year and the average numbers of content release in India on netflix. 
    return top 5 year with highest avg content release!*/

SELECT
	COUNTRY,
	RELEASE_YEAR,
	COUNT(SHOW_ID) AS TOTAL_RELEASE,
	ROUND(
		COUNT(SHOW_ID)::NUMERIC / (SELECT COUNT(SHOW_ID) FROM NETFLIX
			WHERE
				COUNTRY = 'India')::NUMERIC * 100,2) AS AVG_RELEASE
FROM NETFLIX
WHERE
	COUNTRY = 'India'
GROUP BY
	COUNTRY,2
ORDER BY AVG_RELEASE DESC
LIMIT 5;


	
-- 11. Write a SQL query to display the list of Bangladeshi movies available on Netflix.

SELECT title, country
	FROM netflix
WHERE type = 'Movie'
  AND country ILIKE '%Bangladesh%';


-- 12. Count all content without a director

SELECT Count(*) As No_Director FROM netflix
WHERE director IS NULL

-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
SELECT * FROM
	(
	SELECT *,
	UNNEST(STRING_TO_ARRAY(CASTS, ',')) AS CASTS_NAME
	FROM NETFLIX
	) T1
WHERE 	TRIM(CASTS_NAME) = 'Salman Khan'
		AND TYPE = 'Movie'
		AND RELEASE_YEAR >= EXTRACT(YEAR FROM CURRENT_DATE) - 10;


-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

SELECT 
	UNNEST(STRING_TO_ARRAY(casts, ',')) as actor,
	COUNT(*)
FROM netflix
WHERE country = 'India'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10


/* 15. Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
    the description field. Label content containing these keywords as 'Bad' and all other 
    content as 'Good'. Count how many items fall into each category. */
SELECT 
    category,
	TYPE,
    COUNT(*) AS content_count
FROM (
    SELECT 
		*,
        CASE 
            WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
) AS categorized_content
GROUP BY 1,2
ORDER BY 2



-- End of reports


