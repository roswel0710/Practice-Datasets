CREATE TABLE Netflix
(
show_id VARCHAR(5),
type VARCHAR(10),
title VARCHAR(250),
director VARCHAR(550),
casts VarCHAR (1050),
country VARCHAR(550),
date_added VARCHAR (55),
release_year INT,
rating VARCHAR(15),
duration VARCHAR (15),
listed_in VARCHAR(250),
description VARCHAR(550)
);

SELECT *
FROM Netflix

SELECT COUNT(*)
FROM Netflix

--1. Count the number of Movies vs TV Shows
SELECT type,
COUNT(DISTINCT TITLE) as total_number
FROM netflix
GROUP BY 1

--2. Find the most common rating for movies and TV shows
WITH CTE AS 
(
SELECT type,
rating,
COUNT(*) count_of_rating,
RANK() OVER (PARTITION BY type ORDER BY COUNT(*)DESC) AS rank
FROM netflix
GROUP BY 1,2
)
SELECT type,
rating,
Count_of_rating
FROM CTE
WHERE rank = 1

3. List all movies released in a specific year (e.g., 2020)
SELECT *
FROM netflix
WHERe TYPE = 'Movie' AND release_year = 2020


--4. Find the top 5 countries with the most content on Netflix
 SELECT TRIM(UNNEST(STRING_TO_ARRAY(country, ','))) as new_country,
COUNT(show_id) AS total_content
FROM netflix
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

--5. Identify the longest movie
SELECT 
  title, 
  duration, 
  type,
  CAST(SUBSTRING(duration FROM '^[0-9]+') AS INTEGER) AS duration_minutes
FROM netflix
WHERE type = 'Movie'
  AND duration ~ '^[0-9]+\s*mins?$'
ORDER BY duration_minutes DESC
LIMIT 5;

--6. Find content added in the last 5 years
SELECT *
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years'

--7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
SELECT*
FROM netflix
WHERE director LIKE '%Rajiv Chilaka%'

--8. List all TV shows with more than 5 seasons
SELECT *,
CAST(SPLIT_PART(duration, ' ',1) AS INTEGER) as season
FROM netflix
WHERE type = 'TV Show' AND 
	CAST(SPLIT_PART(duration, ' ',1) AS INTEGER) > 5


--9. Count the number of content items in each genre
SELECT
TRIM(UNNEST(STRING_TO_ARRAY(listed_in, ','))) as genre,
COUNT(*)
FROM netflix
GROUP BY TRIM(UNNEST(STRING_TO_ARRAY(listed_in, ',')))
ORDER BY 2 DESC

--10.Find each year and the average numbers of content release in India on netflix. 
--return top 5 year with highest avg content release!
SELECT
EXTRACT(YEAR FROM TO_DATE(date_added,'MONTH DD, YYYY')) as year,
COUNT(*),
COUNT(*)::numeric/(SELECT COUNT(*) FROM netflix where country = 'India') *100 as Avg_content_per_year
FROM netflix
WHERE country = 'India'
GROUP BY 1
ORDER BY 1
11. List all movies that are documentaries
SELECT* FROM netflix
WHERE listed_in ILIKE '%Documentaries%'
12. Find all content without a director
SELECT *
FROM netflix
WHERE director IS NULL
13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
SELECT*,
EXTRACT(YEAR FROM (TO_DATE(date_added, 'MONTH DD, YYYY'))) as release_year
FROM netflix
WHERE casts ILIKE '%Salman Khan%' AND 
release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 11

14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
SELECT
TRIM(UNNEST(STRING_TO_ARRAY(casts,','))) as cast,
COUNT(*) as count
FROM netflix
WHERE country ILIKE '%India%'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10

/*15. Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.*/
WITH CTE AS
(
	SELECT*,
	CASE WHEN description ~* '\mkill\M' OR description ~* '\mviolence\M' THEN 'Bad'
	ELSE 'Good'
	END AS comment
	FROM netflix
)

SELECT comment,
COUNT (*)
FROM CTE
GROUP BY 1