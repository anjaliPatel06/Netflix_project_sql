-- Netflix project

DROP TABLE IF EXISTS netflix;

CREATE TABLE netflix(
	show_id VARCHAR(6),
	type VARCHAR(10),
	title VARCHAR (150),
	director VARCHAR(208),
	casts VARCHAR(1000),
	country VARCHAR(150),
	date_added VARCHAR(50),
	release_year INT,
	rating VARCHAR(10),
	duration VARCHAR(15),
	listed_in VARCHAR(100),
	description VARCHAR(250)
);

SELECT * FROM netflix;

SELECT 
    COUNT(*) AS Total_content
FROM netflix;

-- Business Problems

-- 1. Count the number of movies vs TV shows
SELECT
    type,
    COUNT(type) AS total_content
FROM netflix
GROUP BY type;

-- 2. Find the most common rating for movies and TV shows
SELECT 
    type,
	rating
FROM
(
SELECT 
    type,
	rating,
	COUNT(*),
	RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) AS ranking
FROM netflix
GROUP BY 1, 2
) AS t1
WHERE ranking = 1

-- 3. List all movies released in specific year (eg.2020)
SELECT * FROM netflix
WHERE
  type = 'Movie'
  AND 
  release_year = 2020;

-- 4. Find the top 5 countries with the most content on netflix
SELECT 
    UNNEST(STRING_TO_ARRAY(country,',')) as new_country, 
    COUNT(show_id) AS total_content
FROM netflix
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

-- 5. Identify the longest movie ?
SELECT * FROM netflix
WHERE
   type = 'Movie'
   AND 
   duration = (SELECT MAX(duration) FROM netflix)

-- 6. Find the content added in the last 5 year?
SELECT *
FROM netflix
WHERE 
    TO_DATE(date_added,'Month DD,YYYY')>= CURRENT_DATE - INTERVAL '5 years'

-- 7. Find all the movies/tv shows by director 'peter segal'
SELECT * FROM netflix
WHERE director = 'Peter Segal'

-- 8. List all TV shows more than 5 seasons
SELECT * FROM netflix
WHERE 
   type = 'TV Show'
   AND
   SPLIT_PART(duration,' ',1):: numeric > 5 

-- 9. count the number of content items in each genre
SELECT UNNEST(STRING_TO_ARRAY(listed_in,',')) AS genre,
       COUNT(show_id)
FROM netflix
GROUP BY 1;

-- 10. find each year and the average number of content release by india on netflix.
-- return top 5 year with highest avg content release

SELECT 
   EXTRACT(YEAR FROM TO_DATE(date_added,'Month DD,YYYY')) as year,
   COUNT(*) as yearly_content,
   ROUND(
   COUNT(*)::numeric/(SELECT COUNT(*) FROM netflix WHERE country = 'India')::numeric * 100 , 2) 
   as avg_content
FROM netflix
WHERE country = 'India'
GROUP BY 1
ORDER BY avg_content DESC
LIMIT 5;	

-- 11. List all movies that are documentaries
SELECT * FROM netflix
WHERE type = 'Movie' AND listed_in LIKE '%Documentaries%'

-- 12. find the content without a director
SELECT * FROM netflix
WHERE director IS NULL;

-- 13. Find how many movies actor 'salman khan' appeared in last 10 years
SELECT * FROM netflix
WHERE 
   casts ILIKE '%Salman Khan%' 
   AND 
   release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10

-- 14. Find the top 10 actor who have appeared in the highest number of movie produced in india.
SELECT 
    UNNEST(STRING_TO_ARRAY(casts,',')) as actors,
    COUNT(*) AS total_content
FROM netflix
WHERE country = 'India'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10


-- 15. categorize the content based on the presence of the keywords 'Kill' and 'violence' in description
-- field. label content containing these keywords as 'Bad' and all other content as 'Good'.Count how many items fall into each category.

WITH new_table
AS
(
SELECT *,
CASE
    WHEN description ILIKE '%kill%' 
	OR 
	description ILIKE '%violence%' THEN 'Bad'
	ELSE 'Good'
END AS content_type
FROM netflix
)
SELECT 
    content_type,
    COUNT(*) AS total_content
FROM new_table
GROUP BY 1